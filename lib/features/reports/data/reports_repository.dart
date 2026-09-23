import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/report_models.dart';

/// Read-only aggregation queries backing the statistics screen: net worth,
/// and expense/income/net totals grouped by day/category/month. Never
/// touched directly by widgets — only through [ReportsRepository] methods.
class ReportsRepository {
  ReportsRepository(this._db);

  final AppDatabase _db;

  /// Net worth = sum of every account's current balance. Each account's
  /// `initial_balance_cents` is already kept live by
  /// `TransactionRepository.insert`, which adjusts it on every transaction —
  /// so this must not add/subtract transactions again on top of it.
  Stream<int> watchNetWorth() {
    const sql =
        'SELECT IFNULL(SUM(initial_balance_cents), 0) AS net_worth '
        'FROM accounts';

    return _db
        .customSelect(sql, readsFrom: {_db.accounts})
        .watchSingle()
        .map((row) => row.read<int>('net_worth'));
  }

  /// Daily totals for `date` in `[start, endExclusive)`, one entry per day
  /// that has at least one matching transaction. In [ReportMode.net], a
  /// day's total is income minus expense and may be negative.
  Stream<List<DailySpending>> watchDailyExpense(
    DateTime start,
    DateTime endExclusive, {
    ReportMode mode = ReportMode.expense,
  }) {
    return _watchRows(start, endExclusive, mode).map((rows) {
      final totals = <DateTime, int>{};
      for (final row in rows) {
        final tx = row.readTable(_db.transactions);
        final category = row.readTable(_db.categories);
        final amount = _signedAmount(tx.amountCents, category.type, mode);
        final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
        totals[day] = (totals[day] ?? 0) + amount;
      }
      final days = totals.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      return [
        for (final entry in days)
          DailySpending(date: entry.key, totalCents: entry.value),
      ];
    });
  }

  /// Total for `[start, endExclusive)`. In [ReportMode.net], income minus
  /// expense (may be negative).
  Stream<int> watchTotal(
    DateTime start,
    DateTime endExclusive, {
    ReportMode mode = ReportMode.expense,
  }) {
    return _watchRows(start, endExclusive, mode).map((rows) {
      var total = 0;
      for (final row in rows) {
        final tx = row.readTable(_db.transactions);
        final category = row.readTable(_db.categories);
        total += _signedAmount(tx.amountCents, category.type, mode);
      }
      return total;
    });
  }

  /// Total expense in `[start, endExclusive)`.
  Stream<int> watchTotalExpense(DateTime start, DateTime endExclusive) {
    return watchTotal(start, endExclusive, mode: ReportMode.expense);
  }

  /// Total income in `[start, endExclusive)`.
  Stream<int> watchTotalIncome(DateTime start, DateTime endExclusive) {
    return watchTotal(start, endExclusive, mode: ReportMode.income);
  }

  /// Totals grouped by category in `[start, endExclusive)`, sorted by
  /// magnitude descending. In [ReportMode.net], expense categories carry a
  /// negative total and income categories a positive one, and `share` is
  /// each category's fraction of the total absolute magnitude.
  Stream<List<CategorySpending>> watchCategoryBreakdown(
    DateTime start,
    DateTime endExclusive, {
    ReportMode mode = ReportMode.expense,
  }) {
    return _watchRows(start, endExclusive, mode).map((rows) {
      final totals = <int, int>{};
      final categories = <int, Category>{};
      var grandTotal = 0;
      for (final row in rows) {
        final tx = row.readTable(_db.transactions);
        final category = row.readTable(_db.categories);
        final amount = _signedAmount(tx.amountCents, category.type, mode);
        totals[category.id] = (totals[category.id] ?? 0) + amount;
        categories[category.id] = category;
        grandTotal += amount.abs();
      }
      final entries = totals.entries.toList()
        ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
      return [
        for (final entry in entries)
          CategorySpending(
            categoryId: entry.key,
            name: categories[entry.key]!.name,
            icon: categories[entry.key]!.icon,
            colorValue: categories[entry.key]!.colorValue,
            totalCents: entry.value,
            share: grandTotal == 0 ? 0 : entry.value.abs() / grandTotal,
          ),
      ];
    });
  }

  /// Total per calendar month for the `monthsCount` months ending at
  /// `referenceMonth` (inclusive), oldest first. Months with no matching
  /// transaction are included with a zero total. In [ReportMode.net], a
  /// month's total is income minus expense and may be negative.
  Stream<List<MonthlySpending>> watchMonthlyTrend(
    DateTime referenceMonth, {
    required int monthsCount,
    ReportMode mode = ReportMode.expense,
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

    return _watchRows(start, endExclusive, mode).map((rows) {
      final totals = <DateTime, int>{};
      for (final row in rows) {
        final tx = row.readTable(_db.transactions);
        final category = row.readTable(_db.categories);
        final amount = _signedAmount(tx.amountCents, category.type, mode);
        final month = DateTime(tx.date.year, tx.date.month);
        totals[month] = (totals[month] ?? 0) + amount;
      }
      return [
        for (var i = 0; i < monthsCount; i++)
          MonthlySpending(
            month: DateTime(start.year, start.month + i),
            totalCents: totals[DateTime(start.year, start.month + i)] ?? 0,
          ),
      ];
    });
  }

  /// Signed contribution of one transaction's amount towards [mode]:
  /// [ReportMode.expense]/[ReportMode.income] only count matching-type
  /// transactions (others are 0), while [ReportMode.net] counts income as
  /// positive and expense as negative. `transfer_out`/`transfer_in`
  /// categories (money moved between the user's own wallets, not actually
  /// earned or spent) never contribute to any mode.
  int _signedAmount(int amountCents, String categoryType, ReportMode mode) {
    switch (mode) {
      case ReportMode.expense:
        return categoryType == 'expense' ? amountCents : 0;
      case ReportMode.income:
        return categoryType == 'income' ? amountCents : 0;
      case ReportMode.net:
        if (categoryType == 'income') return amountCents;
        if (categoryType == 'expense') return -amountCents;
        return 0;
    }
  }

  Stream<List<TypedResult>> _watchRows(
    DateTime start,
    DateTime endExclusive,
    ReportMode mode,
  ) {
    final query = _db.select(_db.transactions).join([
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ])
      ..where(
        _db.transactions.date.isBiggerOrEqualValue(start) &
            _db.transactions.date.isSmallerThanValue(endExclusive),
      );
    if (mode == ReportMode.expense) {
      query.where(_db.categories.type.equals('expense'));
    } else if (mode == ReportMode.income) {
      query.where(_db.categories.type.equals('income'));
    }
    return query.watch();
  }
}
