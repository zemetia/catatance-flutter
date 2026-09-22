import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/transaction_item.dart';

class TransactionRepository {
  TransactionRepository(this._db);

  final AppDatabase _db;

  Stream<List<TransactionItem>> watchRecent({int limit = 50}) {
    final query = _db.select(_db.transactions).join([
      innerJoin(
        _db.accounts,
        _db.accounts.id.equalsExp(_db.transactions.accountId),
      ),
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ])
      ..orderBy([
        OrderingTerm.desc(_db.transactions.date),
        OrderingTerm.desc(_db.transactions.id),
      ])
      ..limit(limit);

    return query.watch().map((rows) {
      return rows.map((row) {
        final tx = row.readTable(_db.transactions);
        final account = row.readTable(_db.accounts);
        final category = row.readTable(_db.categories);
        return TransactionItem(
          id: tx.id,
          accountId: account.id,
          accountName: account.name,
          categoryId: category.id,
          categoryName: category.name,
          categoryIcon: category.icon,
          categoryType: category.type,
          categoryColorValue: category.colorValue,
          amountCents: tx.amountCents,
          note: tx.note,
          date: tx.date,
          createdAt: tx.createdAt,
        );
      }).toList();
    });
  }

  Future<int> insert({
    required int accountId,
    required int categoryId,
    required int amountCents,
    String? note,
    required DateTime date,
  }) {
    return _db.transaction(() async {
      final category = await (_db.select(_db.categories)
            ..where((c) => c.id.equals(categoryId)))
          .getSingle();
      final isIncome = category.type == 'income';
      final account = await (_db.select(_db.accounts)
            ..where((a) => a.id.equals(accountId)))
          .getSingle();

      final newBalance = isIncome
          ? account.initialBalanceCents + amountCents
          : account.initialBalanceCents - amountCents;

      await (_db.update(_db.accounts)..where((a) => a.id.equals(accountId))).write(
        AccountsCompanion(initialBalanceCents: Value(newBalance)),
      );

      return _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              categoryId: categoryId,
              amountCents: amountCents,
              note: Value(note),
              date: date,
            ),
          );
    });
  }

  Future<int> delete(int id) {
    return (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }
}
