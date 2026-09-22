import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/report_models.dart';

/// Read-only aggregation queries backing the statistics screen: net worth,
/// and expense totals grouped by day/category/month. Never touched directly
/// by widgets — only through [ReportsRepository] methods.
class ReportsRepository {
  ReportsRepository(this._db);

  final AppDatabase _db;

  /// Net worth = sum of every account's opening balance, plus all-time
  /// income, minus all-time expense.
  Stream<int> watchNetWorth() {
    const sql =
        'SELECT '
        '(SELECT IFNULL(SUM(initial_balance_cents), 0) FROM accounts) + '
        "(SELECT IFNULL(SUM(t.amount_cents), 0) FROM transactions t "
        "JOIN categories c ON c.id = t.category_id WHERE c.type = 'income') - "
        "(SELECT IFNULL(SUM(t.amount_cents), 0) FROM transactions t "
        "JOIN categories c ON c.id = t.category_id WHERE c.type = 'expense') "
        'AS net_worth';

    return _db
        .customSelect(
          sql,
          readsFrom: {_db.accounts, _db.transactions, _db.categories},
        )
        .watchSingle()
        .map((row) => row.read<int>('net_worth'));
  }

  /// Daily expense totals for `date` in `[start, endExclusive)`, one entry
  /// per day that has at least one expense transaction.
  Stream<List<DailySpending>> watchDailyExpense(
    DateTime start,
    DateTime endExclusive,
  ) {
    return _watchExpenseRows(start, endExclusive).map((rows) {
      final totals = <DateTime, int>{};
      for (final row in rows) {
        final tx = row.readTable(_db.transactions);
        final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
        totals[day] = (totals[day] ?? 0) + tx.amountCents;
      }
      final days = totals.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      return [
        for (final entry in days)
          DailySpending(date: entry.key, totalCents: entry.value),
      ];
    });
  }

  /// Total expense in `[start, endExclusive)`.
  Stream<int> watchTotalExpense(DateTime start, DateTime endExclusive) {
    return _watchExpenseRows(start, endExclusive).map((rows) {
      var total = 0;
      for (final row in rows) {
        total += row.readTable(_db.transactions).amountCents;
      }
      return total;
    });
  }

  /// Expense grouped by category in `[start, endExclusive)`, sorted by
  /// total descending.
  Stream<List<CategorySpending>> watchCategoryBreakdown(
    DateTime start,
    DateTime endExclusive,
  ) {
    return _watchExpenseRows(start, endExclusive).map((rows) {
      final totals = <int, int>{};
      final categories = <int, Category>{};
      var grandTotal = 0;
      for (final row in rows) {
        final tx = row.readTable(_db.transactions);
        final category = row.readTable(_db.categories);
        totals[category.id] = (totals[category.id] ?? 0) + tx.amountCents;
        categories[category.id] = category;
        grandTotal += tx.amountCents;
      }
      final entries = totals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return [
        for (final entry in entries)
          CategorySpending(
            categoryId: entry.key,
            name: categories[entry.key]!.name,
            icon: categories[entry.key]!.icon,
            colorValue: categories[entry.key]!.colorValue,
            totalCents: entry.value,
            share: grandTotal == 0 ? 0 : entry.value / grandTotal,
          ),
      ];
    });
  }

  /// Total expense per calendar month for the `monthsCount` months ending
  /// at `referenceMonth` (inclusive), oldest first. Months with no expense
  /// are included with a zero total.
  Stream<List<MonthlySpending>> watchMonthlyTrend(
    DateTime referenceMonth, {
    required int monthsCount,
  }) {
    final firstMonth = DateTime(
      referenceMonth.year,
      referenceMonth.month - (monthsCount - 1),
    );
    final start = DateTime(firstMonth.year, firstMonth.month);
    final endExclusive = DateTime(
      referenceMonth.year,
      referenceMonth.month + 1,
    );

    return _watchExpenseRows(start, endExclusive).map((rows) {
      final totals = <DateTime, int>{};
      for (final row in rows) {
        final tx = row.readTable(_db.transactions);
        final month = DateTime(tx.date.year, tx.date.month);
        totals[month] = (totals[month] ?? 0) + tx.amountCents;
      }
      return [
        for (var i = 0; i < monthsCount; i++)
          MonthlySpending(
            month: DateTime(start.year, start.month + i),
            totalCents:
                totals[DateTime(start.year, start.month + i)] ?? 0,
          ),
      ];
    });
  }

  Stream<List<TypedResult>> _watchExpenseRows(
    DateTime start,
    DateTime endExclusive,
  ) {
    final query = _db.select(_db.transactions).join([
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ])
      ..where(
        _db.categories.type.equals('expense') &
            _db.transactions.date.isBiggerOrEqualValue(start) &
            _db.transactions.date.isSmallerThanValue(endExclusive),
      );
    return query.watch();
  }
}
