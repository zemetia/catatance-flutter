import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/transaction_item.dart';

class TransactionRepository {
  TransactionRepository(this._db);

  final AppDatabase _db;

  Stream<List<TransactionItem>> watchRecent({int limit = 50}) {
    final toAccount = _db.accounts.createAlias('to_account');
    final query = _db.select(_db.transactions).join([
      innerJoin(
        _db.accounts,
        _db.accounts.id.equalsExp(_db.transactions.accountId),
      ),
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
      leftOuterJoin(
        toAccount,
        toAccount.id.equalsExp(_db.transactions.toAccountId),
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
        final destination = row.readTableOrNull(toAccount);
        return TransactionItem(
          id: tx.id,
          accountId: account.id,
          accountName: account.name,
          accountCurrencyCode: account.currencyCode,
          categoryId: category.id,
          categoryName: category.name,
          categoryIcon: category.icon,
          categoryType: category.type,
          categoryColorValue: category.colorValue,
          amountCents: tx.amountCents,
          note: tx.note,
          date: tx.date,
          createdAt: tx.createdAt,
          toAccountName: destination?.name,
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
    int? savingsGoalId,
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

      final id = await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              categoryId: categoryId,
              amountCents: amountCents,
              note: Value(note),
              date: date,
            ),
          );

      // Income earmarked for a savings target: credits the goal's saved
      // amount directly, on top of the wallet balance already credited
      // above — unlike SavingsGoalRepository.deposit, it never deducts the
      // wallet again, since this money was earned, not moved from savings.
      if (isIncome && savingsGoalId != null) {
        final goal = await (_db.select(_db.savingsGoals)
              ..where((s) => s.id.equals(savingsGoalId)))
            .getSingleOrNull();
        if (goal != null) {
          await (_db.update(_db.savingsGoals)
                ..where((s) => s.id.equals(savingsGoalId)))
              .write(
            SavingsGoalsCompanion(
              currentAmountCents: Value(goal.currentAmountCents + amountCents),
            ),
          );
        }
      }

      return id;
    });
  }

  Future<int> delete(int id) {
    return (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }
}
