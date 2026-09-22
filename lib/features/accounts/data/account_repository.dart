import '../../../core/database/app_database.dart' as db;
import '../domain/account.dart';

/// Wraps the `Accounts` Drift table — widgets and providers never query
/// the table directly, only through this repository.
class AccountRepository {
  AccountRepository(this._db);

  final db.AppDatabase _db;

  Stream<List<Account>> watchAll() {
    return _db.select(_db.accounts).watch().map(
      (rows) => rows.map(_toDomain).toList(),
    );
  }

  Account _toDomain(db.Account row) => Account(
    id: row.id,
    name: row.name,
    type: AccountType.fromRaw(row.type),
    balanceCents: row.initialBalanceCents,
  );
}
