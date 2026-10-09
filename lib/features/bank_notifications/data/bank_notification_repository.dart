import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' as db;
import '../domain/bank_notification_mapping.dart';
import '../domain/bank_notification_parser.dart';
import '../domain/captured_bank_notification.dart';
import '../domain/known_bank_apps.dart';
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
    final canonicalPkg = canonicalBankPackage(draft.packageName);
    return _db
        .into(_db.bankNotificationMappings)
        .insert(
          db.BankNotificationMappingsCompanion.insert(
            packageName: canonicalPkg,
            appLabel: draft.appLabel,
            accountId: draft.accountId,
            isEnabled: Value(draft.isEnabled),
          ),
        );
  }

  Future<void> updateMapping(int id, BankNotificationMappingDraft draft) {
    final canonicalPkg = canonicalBankPackage(draft.packageName);
    return (_db.update(
      _db.bankNotificationMappings,
    )..where((m) => m.id.equals(id))).write(
      db.BankNotificationMappingsCompanion(
        packageName: Value(canonicalPkg),
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
  /// saved mapping, enabled or not, plus known package aliases (e.g. blu & myBCA)
  /// so notifications from alternative/legacy package IDs are never missed.
  Future<List<String>> watchedPackageNames() async {
    await _migrateLegacyPackageNames();
    final rows = await _db.select(_db.bankNotificationMappings).get();
    final packages = <String>{};

    for (final row in rows) {
      final pkg = row.packageName;
      packages.add(pkg);
      final canonical = canonicalBankPackage(pkg);
      packages.add(canonical);

      // Expand known aliases so the native listener catches all variants
      if (canonical == 'id.co.bcadigital.blu') {
        packages.add('com.bcadigital.blu');
      } else if (canonical == 'com.bca.mybca') {
        packages.add('com.bca.mybca.omni.android');
      } else if (canonical == 'com.bca') {
        packages.add('com.bca.mybca');
      }
    }

    return packages.toList();
  }

  /// Automatically updates old/guessed package names in existing user databases
  /// to their verified canonical IDs (e.g. Blu BCA and myBCA).
  Future<void> _migrateLegacyPackageNames() async {
    for (final entry in bankPackageAliases.entries) {
      await (_db.update(_db.bankNotificationMappings)
            ..where((m) => m.packageName.equals(entry.key)))
          .write(
            db.BankNotificationMappingsCompanion(
              packageName: Value(entry.value),
            ),
          );
    }
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
  Future<void> syncFromBridge() async {
    await _migrateLegacyPackageNames();
    final raw = await _bridge.drainPendingNotifications();
    if (raw.isEmpty) return;

    final mappings = await (_db.select(
      _db.bankNotificationMappings,
    )..where((m) => m.isEnabled.equals(true))).get();

    // Map packages (both exact, canonical, and aliases) to target wallet account ID
    final accountByPackage = <String, int>{};
    for (final mapping in mappings) {
      final canonical = canonicalBankPackage(mapping.packageName);
      accountByPackage[mapping.packageName] = mapping.accountId;
      accountByPackage[canonical] = mapping.accountId;

      if (canonical == 'id.co.bcadigital.blu') {
        accountByPackage['com.bcadigital.blu'] = mapping.accountId;
      } else if (canonical == 'com.bca.mybca') {
        accountByPackage['com.bca.mybca.omni.android'] = mapping.accountId;
      } else if (canonical == 'com.bca') {
        accountByPackage.putIfAbsent('com.bca.mybca', () => mapping.accountId);
      }
    }

    for (final entry in raw) {
      final canonicalPkg = canonicalBankPackage(entry.packageName);
      final accountId =
          accountByPackage[entry.packageName] ?? accountByPackage[canonicalPkg];
      if (accountId == null) continue;

      // Combine title and content so amount and keywords in either field are parsed
      final fullText = [
        if (entry.title != null && entry.title!.trim().isNotEmpty)
          entry.title!.trim(),
        entry.content.trim(),
      ].join(' ');

      final dedupeKey =
          '${entry.packageName}|${entry.postedAt.millisecondsSinceEpoch}|${fullText.hashCode}';

      final existing = await (_db.select(_db.capturedBankNotifications)
            ..where((c) => c.dedupeKey.equals(dedupeKey)))
          .getSingleOrNull();
      if (existing != null) continue;

      await _db
          .into(_db.capturedBankNotifications)
          .insert(
            db.CapturedBankNotificationsCompanion.insert(
              packageName: canonicalPkg,
              appLabel: entry.appLabel.isNotEmpty ? entry.appLabel : canonicalPkg,
              title: Value(entry.title),
              content: entry.content,
              parsedAmountCents: Value(parseAmountCents(fullText)),
              direction: Value(detectDirection(fullText)),
              accountId: Value(accountId),
              dedupeKey: dedupeKey,
              postedAt: entry.postedAt,
            ),
          );
    }
  }

  /// Manually injects a test notification for diagnostics and user verification.
  Future<void> simulateNotification({
    required String packageName,
    required String appLabel,
    String? title,
    required String content,
  }) async {
    final mappings = await (_db.select(
      _db.bankNotificationMappings,
    )..where((m) => m.isEnabled.equals(true))).get();

    final canonical = canonicalBankPackage(packageName);
    int? accountId;
    for (final m in mappings) {
      if (m.packageName == packageName ||
          canonicalBankPackage(m.packageName) == canonical ||
          (canonical == 'com.bca.mybca' && m.packageName == 'com.bca')) {
        accountId = m.accountId;
        break;
      }
    }

    final fullText = [
      if (title != null && title.trim().isNotEmpty) title.trim(),
      content.trim(),
    ].join(' ');

    final now = DateTime.now();
    final dedupeKey = 'sim_${canonical}_${now.millisecondsSinceEpoch}';

    await _db
        .into(_db.capturedBankNotifications)
        .insert(
          db.CapturedBankNotificationsCompanion.insert(
            packageName: canonical,
            appLabel: appLabel,
            title: Value(title),
            content: content,
            parsedAmountCents: Value(parseAmountCents(fullText)),
            direction: Value(detectDirection(fullText)),
            accountId: Value(accountId),
            dedupeKey: dedupeKey,
            postedAt: now,
          ),
        );
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
