import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' as db;
import '../domain/bank_notification_mapping.dart';
import '../domain/bank_notification_parser.dart';
import '../domain/captured_bank_notification.dart';
import 'bank_notification_bridge.dart';

/// Wraps the `BankNotificationMappings` and `CapturedBankNotifications`
/// Drift tables — widgets and providers never query them directly.
///
/// `confirmCapture` deliberately re-implements
/// `TransactionRepository.insert`'s "update wallet balance + insert
/// Transaction, in one DB transaction" logic against the shared
/// `AppDatabase` rather than importing the `transactions` feature's
/// repository — this project queries the shared tables directly for
/// cross-feature data needs instead of importing another feature's
/// internals (see `reports_repository.dart` for the same pattern).
class BankNotificationRepository {
  BankNotificationRepository(this._db, this._bridge);

  final db.AppDatabase _db;
  final BankNotificationBridge _bridge;

  Stream<List<BankNotificationMapping>> watchMappings() {
    return (_db.select(
      _db.bankNotificationMappings,
    )..orderBy([(m) => OrderingTerm.asc(m.appLabel)])).watch().map(
      (rows) => rows.map(_mappingToDomain).toList(),
    );
  }

  Future<int> insertMapping(BankNotificationMappingDraft draft) {
    return _db
        .into(_db.bankNotificationMappings)
        .insert(
          db.BankNotificationMappingsCompanion.insert(
            packageName: draft.packageName,
            appLabel: draft.appLabel,
            accountId: draft.accountId,
            isEnabled: Value(draft.isEnabled),
          ),
        );
  }

  Future<void> updateMapping(int id, BankNotificationMappingDraft draft) {
    return (_db.update(
      _db.bankNotificationMappings,
    )..where((m) => m.id.equals(id))).write(
      db.BankNotificationMappingsCompanion(
        packageName: Value(draft.packageName),
        appLabel: Value(draft.appLabel),
        accountId: Value(draft.accountId),
        isEnabled: Value(draft.isEnabled),
      ),
    );
  }

  Future<void> deleteMapping(int id) => (_db.delete(
    _db.bankNotificationMappings,
  )..where((m) => m.id.equals(id))).go();

  /// Package names the native listener should watch for — every currently
  /// saved mapping, enabled or not (disabled mappings still get queued so
  /// re-enabling doesn't lose anything posted in between).
  Future<List<String>> watchedPackageNames() async {
    final rows = await _db.select(_db.bankNotificationMappings).get();
    return rows.map((m) => m.packageName).toSet().toList();
  }

  Stream<List<CapturedBankNotification>> watchPendingCaptures() {
    return (_db.select(_db.capturedBankNotifications)
          ..where((c) => c.status.equals('pending'))
          ..orderBy([(c) => OrderingTerm.desc(c.postedAt)]))
        .watch()
        .map((rows) => rows.map(_captureToDomain).toList());
  }

  /// Drains the native bridge's queue, parses each entry, matches it to an
  /// enabled mapping's wallet, and inserts it as a pending capture.
  /// Notifications from packages with no saved mapping are skipped —
  /// nothing to map them to yet.
  Future<void> syncFromBridge() async {
    final raw = await _bridge.drainPendingNotifications();
    if (raw.isEmpty) return;

    final mappings = await (_db.select(
      _db.bankNotificationMappings,
    )..where((m) => m.isEnabled.equals(true))).get();
    final accountByPackage = {
      for (final mapping in mappings) mapping.packageName: mapping.accountId,
    };

    for (final entry in raw) {
      final accountId = accountByPackage[entry.packageName];
      if (accountId == null) continue;

      final dedupeKey =
          '${entry.packageName}|${entry.postedAt.millisecondsSinceEpoch}|${entry.content.hashCode}';

      final existing = await (_db.select(_db.capturedBankNotifications)
            ..where((c) => c.dedupeKey.equals(dedupeKey)))
          .getSingleOrNull();
      if (existing != null) continue;

      await _db
          .into(_db.capturedBankNotifications)
          .insert(
            db.CapturedBankNotificationsCompanion.insert(
              packageName: entry.packageName,
              appLabel: entry.appLabel,
              title: Value(entry.title),
              content: entry.content,
              parsedAmountCents: Value(parseAmountCents(entry.content)),
              direction: Value(detectDirection(entry.content)),
              accountId: Value(accountId),
              dedupeKey: dedupeKey,
              postedAt: entry.postedAt,
            ),
          );
    }
  }

  /// Confirms a capture into a real transaction via the same
  /// `TransactionRepository.insert` path manual entry uses (updates the
  /// wallet balance atomically), then marks the capture as confirmed.
  Future<void> confirmCapture(
    int id, {
    required int accountId,
    required int categoryId,
    required int amountCents,
    required DateTime date,
    String? note,
  }) async {
    await _db.transaction(() async {
      final category = await (_db.select(
        _db.categories,
      )..where((c) => c.id.equals(categoryId))).getSingle();
      final isIncome = category.type == 'income';
      final account = await (_db.select(
        _db.accounts,
      )..where((a) => a.id.equals(accountId))).getSingle();

      final newBalance = isIncome
          ? account.initialBalanceCents + amountCents
          : account.initialBalanceCents - amountCents;

      await (_db.update(
        _db.accounts,
      )..where((a) => a.id.equals(accountId))).write(
        db.AccountsCompanion(initialBalanceCents: Value(newBalance)),
      );

      final transactionId = await _db
          .into(_db.transactions)
          .insert(
            db.TransactionsCompanion.insert(
              accountId: accountId,
              categoryId: categoryId,
              amountCents: amountCents,
              note: Value(note),
              date: date,
            ),
          );

      await (_db.update(
        _db.capturedBankNotifications,
      )..where((c) => c.id.equals(id))).write(
        db.CapturedBankNotificationsCompanion(
          status: const Value('confirmed'),
          transactionId: Value(transactionId),
        ),
      );
    });
  }

  Future<void> dismissCapture(int id) {
    return (_db.update(
      _db.capturedBankNotifications,
    )..where((c) => c.id.equals(id))).write(
      const db.CapturedBankNotificationsCompanion(status: Value('dismissed')),
    );
  }

  BankNotificationMapping _mappingToDomain(db.BankNotificationMapping row) =>
      BankNotificationMapping(
        id: row.id,
        packageName: row.packageName,
        appLabel: row.appLabel,
        accountId: row.accountId,
        isEnabled: row.isEnabled,
      );

  CapturedBankNotification _captureToDomain(db.CapturedBankNotification row) =>
      CapturedBankNotification(
        id: row.id,
        packageName: row.packageName,
        appLabel: row.appLabel,
        title: row.title,
        content: row.content,
        parsedAmountCents: row.parsedAmountCents,
        direction: row.direction,
        accountId: row.accountId,
        status: CapturedNotificationStatus.fromRaw(row.status),
        transactionId: row.transactionId,
        postedAt: row.postedAt,
        createdAt: row.createdAt,
      );
}
