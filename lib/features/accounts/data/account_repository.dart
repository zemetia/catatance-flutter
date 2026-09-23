import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' as db;
import '../domain/account.dart';

/// A new wallet, before it has an id (see [AccountRepository.insert]).
class AccountDraft {
  const AccountDraft({
    required this.name,
    required this.type,
    required this.initialBalanceCents,
    required this.colorValue,
    required this.isDefault,
    this.currencyCode = 'IDR',
  });

  final String name;
  final AccountType type;
  final int initialBalanceCents;
  final int colorValue;
  final bool isDefault;
  final String currencyCode;
}

/// Wraps the `Accounts` Drift table — widgets and providers never query
/// the table directly, only through this repository.
class AccountRepository {
  AccountRepository(this._db);

  final db.AppDatabase _db;

  Stream<List<Account>> watchAll() {
    return (_db.select(_db.accounts)..orderBy([(a) => OrderingTerm.asc(a.id)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  Future<int> insert(AccountDraft draft) {
    return _db.transaction(() async {
      if (draft.isDefault) {
        await _clearDefaultFlag();
      }
      return _db
          .into(_db.accounts)
          .insert(
            db.AccountsCompanion.insert(
              name: draft.name,
              type: draft.type.raw,
              currencyCode: Value(draft.currencyCode),
              initialBalanceCents: Value(draft.initialBalanceCents),
              colorValue: Value(draft.colorValue),
              isDefault: Value(draft.isDefault),
            ),
          );
    });
  }

  Future<void> update(int id, AccountDraft draft) {
    return _db.transaction(() async {
      if (draft.isDefault) {
        await _clearDefaultFlag();
      }
      await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
        db.AccountsCompanion(
          name: Value(draft.name),
          type: Value(draft.type.raw),
          currencyCode: Value(draft.currencyCode),
          initialBalanceCents: Value(draft.initialBalanceCents),
          colorValue: Value(draft.colorValue),
          isDefault: Value(draft.isDefault),
        ),
      );
    });
  }

  Future<void> delete(int id) =>
      _db.delete(_db.accounts).delete(db.AccountsCompanion(id: Value(id)));

  /// Moves [amountCents] out of [fromId]'s balance (in the source wallet's
  /// own currency) and credits [convertedAmountCents] into [toId]'s balance
  /// (in the destination wallet's currency) — atomically. When both wallets
  /// share a currency, [convertedAmountCents] should just equal [amountCents];
  /// the caller (the presentation layer, which already has the live exchange
  /// rate for its preview) is responsible for the conversion, not this
  /// repository, since fetching a live rate is an external/async concern.
  ///
  /// The transfer is recorded as a single `Transactions` row — `accountId`
  /// = [fromId], `toAccountId` = [toId], `amountCents` = [amountCents], and
  /// `toAmountCents` = [convertedAmountCents] only when it differs (a
  /// cross-currency transfer) — instead of a `transfer_out`/`transfer_in`
  /// pair, so the ledger shows one "Transfer dari A ke B" entry, not two.
  ///
  /// When [feeCents] is > 0, also deducts it from [fromId] (in the source
  /// wallet's currency) and records it as an expense `Transaction` (via
  /// [feeCategoryId]) so it shows up in Transaksi/Laporan like any other
  /// spending — same reasoning as why `installments`/`split_bills` write
  /// straight to `Transactions` instead of depending on the `transactions`
  /// feature's own repository.
  Future<void> transfer({
    required int fromId,
    required int toId,
    required int amountCents,
    required int convertedAmountCents,
    int feeCents = 0,
    int? feeCategoryId,
  }) {
    return _db.transaction(() async {
      final from = await (_db.select(
        _db.accounts,
      )..where((a) => a.id.equals(fromId))).getSingle();
      final to = await (_db.select(
        _db.accounts,
      )..where((a) => a.id.equals(toId))).getSingle();

      await (_db.update(_db.accounts)..where((a) => a.id.equals(fromId))).write(
        db.AccountsCompanion(
          initialBalanceCents: Value(
            from.initialBalanceCents - amountCents - feeCents,
          ),
        ),
      );
      await (_db.update(_db.accounts)..where((a) => a.id.equals(toId))).write(
        db.AccountsCompanion(
          initialBalanceCents: Value(
            to.initialBalanceCents + convertedAmountCents,
          ),
        ),
      );

      final now = DateTime.now();
      final transferCategoryId = await _categoryIdByName('Transfer');

      await _db.into(_db.transactions).insert(
            db.TransactionsCompanion.insert(
              accountId: fromId,
              categoryId: transferCategoryId,
              amountCents: amountCents,
              toAccountId: Value(toId),
              toAmountCents: Value(
                convertedAmountCents != amountCents ? convertedAmountCents : null,
              ),
              date: now,
            ),
          );

      if (feeCents > 0 && feeCategoryId != null) {
        await _db.into(_db.transactions).insert(
              db.TransactionsCompanion.insert(
                accountId: fromId,
                categoryId: feeCategoryId,
                amountCents: feeCents,
                note: Value('Biaya admin transfer ke ${to.name}'),
                date: now,
              ),
            );
      }
    });
  }

  Future<int> _categoryIdByName(String name) async {
    final row = await (_db.select(
      _db.categories,
    )..where((c) => c.name.equals(name))).getSingle();
    return row.id;
  }

  Future<void> _clearDefaultFlag() {
    return (_db.update(_db.accounts)..where((a) => a.isDefault.equals(true)))
        .write(const db.AccountsCompanion(isDefault: Value(false)));
  }

  Account _toDomain(db.Account row) => Account(
    id: row.id,
    name: row.name,
    type: AccountType.fromRaw(row.type),
    balanceCents: row.initialBalanceCents,
    colorValue: row.colorValue,
    isDefault: row.isDefault,
    currencyCode: row.currencyCode,
  );
}
