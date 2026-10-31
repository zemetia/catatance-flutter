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
    int? accountId,
  }) {
    final String selectExpr;
    final String modeFilter;

    switch (mode) {
      case ReportMode.expense:
        selectExpr = 'IFNULL(SUM(t.amount_cents), 0)';
        modeFilter = "AND c.type = 'expense'";
      case ReportMode.income:
        selectExpr = 'IFNULL(SUM(t.amount_cents), 0)';
        modeFilter = "AND c.type = 'income'";
      case ReportMode.net:
        selectExpr =
            "IFNULL(SUM(CASE WHEN c.type = 'income' THEN t.amount_cents WHEN c.type = 'expense' THEN -t.amount_cents ELSE 0 END), 0)";
        modeFilter = '';
    }

    final sql = '''
      SELECT $selectExpr AS total
      FROM transactions t
      INNER JOIN categories c ON c.id = t.category_id
      WHERE t.date >= ? AND t.date < ? $modeFilter
      ${accountId != null ? 'AND t.account_id = ?' : ''}
    ''';

    return _db
        .customSelect(
          sql,
          variables: [
            Variable.withDateTime(start),
            Variable.withDateTime(endExclusive),
            if (accountId != null) Variable.withInt(accountId),
          ],
          readsFrom: {_db.transactions, _db.categories},
        )
        .watchSingle()
        .map((row) => row.read<int>('total'));
  }

  /// Total expense in `[start, endExclusive)`.
  Stream<int> watchTotalExpense(
    DateTime start,
    DateTime endExclusive, {
    int? accountId,
  }) {
    return watchTotal(
      start,
      endExclusive,
      mode: ReportMode.expense,
      accountId: accountId,
    );
  }

  /// Total income in `[start, endExclusive)`.
  Stream<int> watchTotalIncome(
    DateTime start,
    DateTime endExclusive, {
    int? accountId,
  }) {
    return watchTotal(
      start,
      endExclusive,
      mode: ReportMode.income,
      accountId: accountId,
    );
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
    final String modeFilter;
    switch (mode) {
      case ReportMode.expense:
        modeFilter = "AND c.type = 'expense'";
      case ReportMode.income:
        modeFilter = "AND c.type = 'income'";
      case ReportMode.net:
        modeFilter = "AND c.type IN ('expense', 'income')";
    }

    final sql = '''
      SELECT 
        c.id AS category_id,
        c.name AS category_name,
        c.icon AS category_icon,
        c.color_value AS category_color_value,
        c.type AS category_type,
        SUM(t.amount_cents) AS total_cents,
        COUNT(t.id) AS tx_count
      FROM transactions t
      INNER JOIN categories c ON c.id = t.category_id
      WHERE t.date >= ? AND t.date < ? $modeFilter
      GROUP BY c.id
    ''';

    return _db
        .customSelect(
          sql,
          variables: [
            Variable.withDateTime(start),
            Variable.withDateTime(endExclusive),
          ],
          readsFrom: {_db.transactions, _db.categories},
        )
        .watch()
        .map((rows) {
          var grandTotal = 0;
          final items = <CategorySpending>[];
          for (final row in rows) {
            final categoryId = row.read<int>('category_id');
            final name = row.read<String>('category_name');
            final icon = row.read<String>('category_icon');
            final colorValue = row.read<int>('category_color_value');
            final type = row.read<String>('category_type');
            final amount = row.read<int>('total_cents');
            final count = row.read<int>('tx_count');

            final signedAmount = (type == 'expense' && mode == ReportMode.net)
                ? -amount
                : amount;
            grandTotal += amount.abs();
            items.add(
              CategorySpending(
                categoryId: categoryId,
                name: name,
                icon: icon,
                colorValue: colorValue,
                totalCents: signedAmount,
                share: 0,
                count: count,
              ),
            );
          }

          items.sort((a, b) => b.totalCents.abs().compareTo(a.totalCents.abs()));

          return [
            for (final item in items)
              CategorySpending(
                categoryId: item.categoryId,
                name: item.name,
                icon: item.icon,
                colorValue: item.colorValue,
                totalCents: item.totalCents,
                share: grandTotal == 0 ? 0 : item.totalCents.abs() / grandTotal,
                count: item.count,
              ),
          ];
        });
  }

  /// Totals grouped by `#tag` parsed out of each matching transaction's
  /// `note` (a transaction with multiple tags contributes its full amount to
  /// each one, same as the category breakdown contributes to exactly one
  /// category — tags are just a free-form secondary grouping on top of it).
  /// `share` is each tag's fraction of the same grand total the category
  /// breakdown uses (every matching transaction's absolute amount, not just
  /// tagged ones), so it reads as "what portion of this month's spending
  /// carries this tag."
  static final _tagPattern = RegExp(r'#(\w+)');

  Stream<List<TagSpending>> watchTagBreakdown(
    DateTime start,
    DateTime endExclusive, {
    ReportMode mode = ReportMode.expense,
  }) {
    return _watchRows(start, endExclusive, mode).map((rows) {
      final totals = <String, int>{};
      final counts = <String, int>{};
      var grandTotal = 0;
      for (final row in rows) {
        final tx = row.readTable(_db.transactions);
        final category = row.readTable(_db.categories);
        final amount = _signedAmount(tx.amountCents, category.type, mode);
        grandTotal += amount.abs();
        if (amount == 0) continue;
        final note = tx.note;
        if (note == null) continue;
        for (final match in _tagPattern.allMatches(note)) {
          final tag = match.group(1)!;
          totals[tag] = (totals[tag] ?? 0) + amount;
          counts[tag] = (counts[tag] ?? 0) + 1;
        }
      }
      final entries = totals.entries.toList()
        ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
      return [
        for (final entry in entries)
          TagSpending(
            tag: entry.key,
            totalCents: entry.value,
            share: grandTotal == 0 ? 0 : entry.value.abs() / grandTotal,
            count: counts[entry.key] ?? 0,
          ),
      ];
    });
  }

  /// Number of transactions in `[start, endExclusive)`, regardless of
  /// category type (income, expense, or any other).
  Stream<int> watchTransactionCount(DateTime start, DateTime endExclusive) {
    const sql = '''
      SELECT COUNT(*) AS tx_count
      FROM transactions t
      WHERE t.date >= ? AND t.date < ?
    ''';

    return _db
        .customSelect(
          sql,
          variables: [
            Variable.withDateTime(start),
            Variable.withDateTime(endExclusive),
          ],
          readsFrom: {_db.transactions},
        )
        .watchSingle()
        .map((row) => row.read<int>('tx_count'));
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

  /// Income and expense totals for `date` in `[start, endExclusive)`, one
  /// entry per day with at least one matching (non-transfer) transaction —
  /// backs the "Kalender Cashflow" calendar grid.
  Stream<List<DailyCashflow>> watchDailyCashflow(
    DateTime start,
    DateTime endExclusive, {
    int? accountId,
  }) {
    return _watchRows(start, endExclusive, ReportMode.net,
            accountId: accountId)
        .map((rows) {
      final income = <DateTime, int>{};
      final expense = <DateTime, int>{};
      for (final row in rows) {
        final tx = row.readTable(_db.transactions);
        final category = row.readTable(_db.categories);
        final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
        if (category.type == 'income') {
          income[day] = (income[day] ?? 0) + tx.amountCents;
        } else if (category.type == 'expense') {
          expense[day] = (expense[day] ?? 0) + tx.amountCents;
        }
      }
      final days = {...income.keys, ...expense.keys}.toList()..sort();
      return [
        for (final day in days)
          DailyCashflow(
            date: day,
            incomeCents: income[day] ?? 0,
            expenseCents: expense[day] ?? 0,
          ),
      ];
    });
  }

  /// Every transaction on a single calendar [day], newest first — backs the
  /// "Kalender Cashflow" screen's selected-day detail list.
  Stream<List<CashflowTransaction>> watchTransactionsForDate(
    DateTime day, {
    int? accountId,
  }) {
    final start = DateTime(day.year, day.month, day.day);
    final endExclusive = start.add(const Duration(days: 1));
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
      ..where(
        _db.transactions.date.isBiggerOrEqualValue(start) &
            _db.transactions.date.isSmallerThanValue(endExclusive),
      )
      ..orderBy([
        OrderingTerm.desc(_db.transactions.date),
        OrderingTerm.desc(_db.transactions.id),
      ]);
    if (accountId != null) {
      query.where(_db.transactions.accountId.equals(accountId));
    }

    return query.watch().map((rows) {
      return rows.map((row) {
        final tx = row.readTable(_db.transactions);
        final account = row.readTable(_db.accounts);
        final category = row.readTable(_db.categories);
        final destination = row.readTableOrNull(toAccount);
        final isTransfer = category.type == 'transfer' ||
            category.type == 'transfer_in' ||
            category.type == 'transfer_out';
        final title = category.type == 'transfer' && destination != null
            ? 'Transfer dari ${account.name} ke ${destination.name}'
            : (tx.note != null && tx.note!.isNotEmpty ? tx.note! : category.name);
        return CashflowTransaction(
          id: tx.id,
          title: title,
          categoryName: category.name,
          categoryIcon: category.icon,
          categoryColorValue: category.colorValue,
          accountName: account.name,
          amountCents: tx.amountCents,
          date: tx.date,
          isIncome: category.type == 'income' || category.type == 'transfer_in',
          isTransfer: isTransfer,
        );
      }).toList();
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

  /// Per-budget spend vs. limit for [monthStart, monthEndExclusive), used by
  /// the Proyeksi screen's "Kepatuhan budget" score component. Every
  /// [Budgets] row is compared against its category's spend in that plain
  /// calendar-month range regardless of its own `periodType`/custom dates —
  /// a simplification appropriate for an approximate health score; the exact
  /// per-period spend (carry-over, weekly/custom periods) used by the
  /// Anggaran screen itself lives in
  /// `features/budget/presentation/budget_providers.dart` and is not
  /// duplicated here, to avoid a cross-feature import.
  Stream<BudgetComplianceSummary> watchBudgetCompliance(
    DateTime monthStart,
    DateTime monthEndExclusive,
  ) {
    const sql =
        'SELECT b.id AS budget_id, b.limit_cents AS limit_cents, '
        'IFNULL(SUM(CASE WHEN t.date >= ? AND t.date < ? THEN t.amount_cents '
        'END), 0) AS spent_cents '
        'FROM budgets b '
        'LEFT JOIN transactions t ON t.category_id = b.category_id '
        'GROUP BY b.id';

    return _db
        .customSelect(
          sql,
          variables: [
            Variable.withDateTime(monthStart),
            Variable.withDateTime(monthEndExclusive),
          ],
          readsFrom: {_db.budgets, _db.transactions},
        )
        .watch()
        .map((rows) {
      if (rows.isEmpty) {
        return const BudgetComplianceSummary(
          total: 0,
          safeCount: 0,
          cautionCount: 0,
          overCount: 0,
          complianceScore: 1,
        );
      }
      var safe = 0, caution = 0, over = 0;
      for (final row in rows) {
        final limitCents = row.read<int>('limit_cents');
        final spentCents = row.read<int>('spent_cents');
        final progress = limitCents == 0 ? 0.0 : spentCents / limitCents;
        if (spentCents >= limitCents) {
          over++;
        } else if (progress >= 0.8) {
          caution++;
        } else {
          safe++;
        }
      }
      final total = rows.length;
      final score = (safe + caution * 0.6 + over * 0.0) / total;
      return BudgetComplianceSummary(
        total: total,
        safeCount: safe,
        cautionCount: caution,
        overCount: over,
        complianceScore: score,
      );
    });
  }

  /// The most-recently-created savings goal that isn't fully funded yet —
  /// backs the Proyeksi screen's "Yang perlu diperhatian" goal-progress
  /// insight. `null` when there are no such goals. Queries the shared
  /// `SavingsGoals` table directly rather than importing
  /// `features/savings_goals`, same convention as [watchBudgetCompliance].
  Stream<SavingsGoalInsight?> watchNearestSavingsGoal() {
    final query = _db.select(_db.savingsGoals)
      ..where((g) => g.currentAmountCents.isSmallerThan(g.targetAmountCents))
      ..orderBy([(g) => OrderingTerm.desc(g.createdAt)])
      ..limit(1);

    return query.watchSingleOrNull().map((goal) {
      if (goal == null) return null;
      final target = goal.targetAmountCents;
      final progress = target <= 0
          ? 0
          : ((goal.currentAmountCents / target) * 100).round().clamp(0, 100);
      final remaining = (target - goal.currentAmountCents).clamp(0, target);
      return SavingsGoalInsight(
        name: goal.name,
        progressPercent: progress,
        remainingCents: remaining,
      );
    });
  }

  /// [categoryId]'s configured budget limit vs. its spend in
  /// [monthStart, monthEndExclusive), or `null` if that category has no
  /// budget row at all — backs the "Boleh nggak beli sesuatu?" simulator's
  /// per-category check (does this hypothetical purchase blow the budget).
  Stream<CategoryBudgetInfo?> watchBudgetForCategory(
    int categoryId,
    DateTime monthStart,
    DateTime monthEndExclusive,
  ) {
    const sql =
        'SELECT b.limit_cents AS limit_cents, '
        'IFNULL(SUM(CASE WHEN t.date >= ? AND t.date < ? THEN t.amount_cents '
        'END), 0) AS spent_cents '
        'FROM budgets b '
        'LEFT JOIN transactions t ON t.category_id = b.category_id '
        'WHERE b.category_id = ? '
        'GROUP BY b.id';

    return _db
        .customSelect(
          sql,
          variables: [
            Variable.withDateTime(monthStart),
            Variable.withDateTime(monthEndExclusive),
            Variable.withInt(categoryId),
          ],
          readsFrom: {_db.budgets, _db.transactions},
        )
        .watchSingleOrNull()
        .map((row) {
      if (row == null) return null;
      return CategoryBudgetInfo(
        limitCents: row.read<int>('limit_cents'),
        spentCents: row.read<int>('spent_cents'),
      );
    });
  }

  Stream<List<TypedResult>> _watchRows(
    DateTime start,
    DateTime endExclusive,
    ReportMode mode, {
    int? accountId,
  }) {
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
    if (accountId != null) {
      query.where(_db.transactions.accountId.equals(accountId));
    }
    return query.watch();
  }

  /// Category comparison and flow analysis overview for the selected [month].
  /// Computes each category's total, count, previous month's total, and budget.
  Stream<List<CategoryAnalysisItem>> watchCategoryAnalysisList(
    DateTime month, {
    ReportMode mode = ReportMode.expense,
  }) {
    final start = DateTime(month.year, month.month, 1);
    final endExclusive = DateTime(month.year, month.month + 1, 1);
    final prevStart = DateTime(month.year, month.month - 1, 1);
    final prevEndExclusive = start;

    final String modeFilter;
    switch (mode) {
      case ReportMode.expense:
        modeFilter = "WHERE c.type = 'expense'";
      case ReportMode.income:
        modeFilter = "WHERE c.type = 'income'";
      case ReportMode.net:
        modeFilter = "WHERE c.type IN ('expense', 'income')";
    }

    final sql = '''
      SELECT 
        c.id AS category_id,
        c.name AS category_name,
        c.icon AS category_icon,
        c.color_value AS category_color_value,
        c.type AS category_type,
        IFNULL((
          SELECT SUM(t.amount_cents)
          FROM transactions t
          WHERE t.category_id = c.id
            AND t.date >= ? AND t.date < ?
        ), 0) AS total_cents,
        IFNULL((
          SELECT COUNT(t.id)
          FROM transactions t
          WHERE t.category_id = c.id
            AND t.date >= ? AND t.date < ?
        ), 0) AS tx_count,
        IFNULL((
          SELECT SUM(t.amount_cents)
          FROM transactions t
          WHERE t.category_id = c.id
            AND t.date >= ? AND t.date < ?
        ), 0) AS prev_total_cents,
        (
          SELECT b.limit_cents
          FROM budgets b
          WHERE b.category_id = c.id
          LIMIT 1
        ) AS budget_limit_cents
      FROM categories c
      $modeFilter
    ''';

    return _db
        .customSelect(
          sql,
          variables: [
            Variable.withDateTime(start),
            Variable.withDateTime(endExclusive),
            Variable.withDateTime(start),
            Variable.withDateTime(endExclusive),
            Variable.withDateTime(prevStart),
            Variable.withDateTime(prevEndExclusive),
          ],
          readsFrom: {_db.categories, _db.transactions, _db.budgets},
        )
        .watch()
        .map((rows) {
          var grandTotal = 0;
          final rawItems = <({
            int id,
            String name,
            String icon,
            int colorValue,
            String type,
            int total,
            int count,
            int prevTotal,
            int? budgetLimit,
          })>[];

          for (final row in rows) {
            final total = row.read<int>('total_cents');
            final prevTotal = row.read<int>('prev_total_cents');
            final budgetLimit = row.readNullable<int>('budget_limit_cents');

            // Only include categories that either have activity this month, last month, or a budget configured
            if (total == 0 && prevTotal == 0 && budgetLimit == null) continue;

            grandTotal += total.abs();
            rawItems.add((
              id: row.read<int>('category_id'),
              name: row.read<String>('category_name'),
              icon: row.read<String>('category_icon'),
              colorValue: row.read<int>('category_color_value'),
              type: row.read<String>('category_type'),
              total: total,
              count: row.read<int>('tx_count'),
              prevTotal: prevTotal,
              budgetLimit: budgetLimit,
            ));
          }

          rawItems.sort((a, b) {
            final cmp = b.total.abs().compareTo(a.total.abs());
            if (cmp != 0) return cmp;
            return a.name.compareTo(b.name);
          });

          return [
            for (final item in rawItems)
              CategoryAnalysisItem(
                categoryId: item.id,
                name: item.name,
                icon: item.icon,
                colorValue: item.colorValue,
                type: item.type,
                totalCents: item.total,
                previousMonthTotalCents: item.prevTotal,
                share: grandTotal == 0 ? 0.0 : item.total.abs() / grandTotal,
                count: item.count,
                budgetLimitCents: item.budgetLimit,
                budgetSpentCents: item.budgetLimit != null ? item.total : null,
              ),
          ];
        });
  }

  /// In-depth category flow detail for [categoryId] in [month]:
  /// provides complete breakdown including wallet source flow, 6-month historical trend,
  /// tag patterns, transaction list, and budget status.
  Stream<CategoryFlowDetail?> watchCategoryFlowDetail({
    required int categoryId,
    required DateTime month,
  }) {
    final start = DateTime(month.year, month.month, 1);
    final endExclusive = DateTime(month.year, month.month + 1, 1);
    final prevStart = DateTime(month.year, month.month - 1, 1);
    final prevEndExclusive = start;
    final trendStart = DateTime(month.year, month.month - 5, 1);

    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _db.categories,
            _db.transactions,
            _db.accounts,
            _db.budgets,
          },
        )
        .watch()
        .asyncMap((_) async {
          final category = await (_db.select(_db.categories)
                ..where((c) => c.id.equals(categoryId)))
              .getSingleOrNull();

          if (category == null) return null;

          final toAccount = _db.accounts.createAlias('to_account');
          final txRows = await (_db.select(_db.transactions).join([
            innerJoin(
              _db.accounts,
              _db.accounts.id.equalsExp(_db.transactions.accountId),
            ),
            leftOuterJoin(
              toAccount,
              toAccount.id.equalsExp(_db.transactions.toAccountId),
            ),
          ])
                ..where(
                  _db.transactions.categoryId.equals(categoryId) &
                      _db.transactions.date.isBiggerOrEqualValue(start) &
                      _db.transactions.date.isSmallerThanValue(endExclusive),
                )
                ..orderBy([
                  OrderingTerm.desc(_db.transactions.date),
                  OrderingTerm.desc(_db.transactions.id),
                ]))
              .get();

          var totalCents = 0;
          final walletTotals = <int, ({String name, int total, int count})>{};
          final tagTotals = <String, int>{};
          final tagCounts = <String, int>{};
          CashflowTransaction? biggestTx;
          final txList = <CashflowTransaction>[];

          for (final row in txRows) {
            final tx = row.readTable(_db.transactions);
            final account = row.readTable(_db.accounts);
            final dest = row.readTableOrNull(toAccount);

            totalCents += tx.amountCents;

            final currentWallet = walletTotals[account.id];
            walletTotals[account.id] = (
              name: account.name,
              total: (currentWallet?.total ?? 0) + tx.amountCents,
              count: (currentWallet?.count ?? 0) + 1,
            );

            if (tx.note != null && tx.note!.isNotEmpty) {
              for (final match in _tagPattern.allMatches(tx.note!)) {
                final tag = match.group(1)!;
                tagTotals[tag] = (tagTotals[tag] ?? 0) + tx.amountCents;
                tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
              }
            }

            final isTransfer = category.type == 'transfer' ||
                category.type == 'transfer_in' ||
                category.type == 'transfer_out';
            final title = category.type == 'transfer' && dest != null
                ? 'Transfer dari ${account.name} ke ${dest.name}'
                : (tx.note != null && tx.note!.isNotEmpty ? tx.note! : category.name);

            final cfTx = CashflowTransaction(
              id: tx.id,
              title: title,
              categoryName: category.name,
              categoryIcon: category.icon,
              categoryColorValue: category.colorValue,
              accountName: account.name,
              amountCents: tx.amountCents,
              date: tx.date,
              isIncome: category.type == 'income' || category.type == 'transfer_in',
              isTransfer: isTransfer,
            );

            txList.add(cfTx);

            if (biggestTx == null || tx.amountCents > biggestTx.amountCents) {
              biggestTx = cfTx;
            }
          }

          final prevRow = await _db
              .customSelect(
                'SELECT IFNULL(SUM(amount_cents), 0) AS prev_total '
                'FROM transactions '
                'WHERE category_id = ? AND date >= ? AND date < ?',
                variables: [
                  Variable.withInt(categoryId),
                  Variable.withDateTime(prevStart),
                  Variable.withDateTime(prevEndExclusive),
                ],
              )
              .getSingle();
          final prevTotalCents = prevRow.read<int>('prev_total');

          final grandRow = await _db
              .customSelect(
                'SELECT IFNULL(SUM(t.amount_cents), 0) AS grand_total '
                'FROM transactions t '
                'INNER JOIN categories c ON c.id = t.category_id '
                'WHERE c.type = ? AND t.date >= ? AND t.date < ?',
                variables: [
                  Variable.withString(category.type),
                  Variable.withDateTime(start),
                  Variable.withDateTime(endExclusive),
                ],
              )
              .getSingle();
          final grandTotalCents = grandRow.read<int>('grand_total');

          final budget = await (_db.select(_db.budgets)
                ..where((b) => b.categoryId.equals(categoryId)))
              .getSingleOrNull();

          final walletEntries = walletTotals.entries.toList()
            ..sort((a, b) => b.value.total.compareTo(a.value.total));
          final wallets = [
            for (final entry in walletEntries)
              CategoryWalletSpending(
                accountId: entry.key,
                accountName: entry.value.name,
                totalCents: entry.value.total,
                share: totalCents == 0 ? 0.0 : entry.value.total / totalCents,
                count: entry.value.count,
              ),
          ];

          final tagEntries = tagTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final tags = [
            for (final entry in tagEntries)
              TagSpending(
                tag: entry.key,
                totalCents: entry.value,
                share: totalCents == 0 ? 0.0 : entry.value / totalCents,
                count: tagCounts[entry.key] ?? 0,
              ),
          ];

          final trendRows = await (_db.select(_db.transactions)
                ..where(
                  (t) =>
                      t.categoryId.equals(categoryId) &
                      t.date.isBiggerOrEqualValue(trendStart) &
                      t.date.isSmallerThanValue(endExclusive),
                ))
              .get();

          final monthlyBuckets = <DateTime, int>{};
          for (final tx in trendRows) {
            final m = DateTime(tx.date.year, tx.date.month);
            monthlyBuckets[m] = (monthlyBuckets[m] ?? 0) + tx.amountCents;
          }

          final monthlyTrends = <CategoryMonthlyTrend>[];
          for (var i = 5; i >= 0; i--) {
            final m = DateTime(month.year, month.month - i);
            monthlyTrends.add(
              CategoryMonthlyTrend(
                month: m,
                totalCents: monthlyBuckets[m] ?? 0,
              ),
            );
          }

          final txCount = txRows.length;
          final averageCents = txCount == 0 ? 0 : totalCents ~/ txCount;
          final shareOfTotal = grandTotalCents == 0 ? 0.0 : totalCents / grandTotalCents;

          return CategoryFlowDetail(
            categoryId: category.id,
            categoryName: category.name,
            categoryIcon: category.icon,
            categoryColorValue: category.colorValue,
            categoryType: category.type,
            totalCents: totalCents,
            previousMonthTotalCents: prevTotalCents,
            shareOfTotal: shareOfTotal,
            transactionCount: txCount,
            averageCents: averageCents,
            budgetLimitCents: budget?.limitCents,
            budgetSpentCents: budget != null ? totalCents : null,
            wallets: wallets,
            tags: tags,
            monthlyTrends: monthlyTrends,
            transactions: txList,
            biggestTransaction: biggestTx,
          );
        });
  }
}
