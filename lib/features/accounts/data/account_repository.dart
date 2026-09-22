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
  });

  final String name;
  final AccountType type;
  final int initialBalanceCents;
  final int colorValue;
  final bool isDefault;
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
              initialBalanceCents: Value(draft.initialBalanceCents),
              colorValue: Value(draft.colorValue),
              isDefault: Value(draft.isDefault),
            ),
          );
    });
  }

  Future<void> delete(int id) =>
      _db.delete(_db.accounts).delete(db.AccountsCompanion(id: Value(id)));

  /// Moves [amountCents] from [fromId]'s balance to [toId]'s, atomically.
  Future<void> transfer({
    required int fromId,
    required int toId,
    required int amountCents,
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
          initialBalanceCents: Value(from.initialBalanceCents - amountCents),
        ),
      );
      await (_db.update(_db.accounts)..where((a) => a.id.equals(toId))).write(
        db.AccountsCompanion(
          initialBalanceCents: Value(to.initialBalanceCents + amountCents),
        ),
      );
    });
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
  );
}
