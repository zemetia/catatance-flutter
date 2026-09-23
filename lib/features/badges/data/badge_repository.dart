import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/badge_evaluator.dart';
import '../domain/badge_metrics_snapshot.dart';
import '../domain/badge_progress.dart';
import '../domain/badge_streak.dart';

/// Computes live progress for every badge in `badgeCatalog` straight from
/// the shared tables it depends on (transactions, accounts, savings goals,
/// budgets, debts, installments) — queried directly rather than through
/// each feature's own repository, the same convention `ReportsRepository`
/// already established for cross-feature aggregation.
class BadgeRepository {
  BadgeRepository(this._db);

  final AppDatabase _db;

  /// Live badge progress, recomputed whenever any table a badge depends on
  /// changes. Newly-unlocked badges are persisted to `EarnedBadges` as a
  /// side effect of each recompute, so they stay unlocked even if the
  /// underlying metric later regresses.
  Stream<List<BadgeProgress>> watchAll() {
    return _watchCoreCounts().asyncMap(_evaluateAndPersist);
  }

  Future<List<BadgeProgress>> _evaluateAndPersist(QueryRow core) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);

    final monthRows = await (_db.select(_db.transactions).join([
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ])..where(_db.transactions.date.isBiggerOrEqualValue(monthStart))).get();

    var incomeThisMonth = 0;
    var expenseThisMonth = 0;
    for (final row in monthRows) {
      final tx = row.readTable(_db.transactions);
      final category = row.readTable(_db.categories);
      if (category.type == 'income') incomeThisMonth += tx.amountCents;
      if (category.type == 'expense') expenseThisMonth += tx.amountCents;
    }
    final savingsRatePercent = incomeThisMonth <= 0
        ? 0
        : (((incomeThisMonth - expenseThisMonth) * 100) / incomeThisMonth)
            .round();

    final dateRows = await (_db.selectOnly(_db.transactions)
          ..addColumns([_db.transactions.date]))
        .map((row) => row.read(_db.transactions.date)!)
        .get();
    final streakDays = computeStreakDays(dateRows, now);

    final snapshot = BadgeMetricsSnapshot(
      transactionCount: core.read<int>('transaction_count'),
      distinctCategoryCount: core.read<int>('distinct_category_count'),
      currentStreakDays: streakDays,
      walletCount: core.read<int>('wallet_count'),
      transferCount: core.read<int>('transfer_count'),
      goalCount: core.read<int>('goal_count'),
      goalsCompletedCount: core.read<int>('goals_completed_count'),
      bestGoalProgressPercent:
          core.read<double>('best_goal_progress_percent').round(),
      budgetCount: core.read<int>('budget_count'),
      savingsRatePercent: savingsRatePercent,
      debtsPaidCount: core.read<int>('debts_paid_count'),
      receivablesPaidCount: core.read<int>('receivables_paid_count'),
      installmentsCompletedCount:
          core.read<int>('installments_completed_count'),
      netWorthCents: core.read<int>('net_worth_cents'),
    );

    final earnedRows = await _db.select(_db.earnedBadges).get();
    final earnedAt = {
      for (final row in earnedRows) row.badgeKey: row.earnedAt,
    };

    final progress = evaluateBadges(snapshot, earnedAt, now: now);

    final newlyUnlocked = progress.where(
      (p) => p.isUnlocked && !earnedAt.containsKey(p.definition.key),
    );
    for (final p in newlyUnlocked) {
      await _db.into(_db.earnedBadges).insert(
            EarnedBadgesCompanion.insert(badgeKey: p.definition.key),
            mode: InsertMode.insertOrIgnore,
          );
    }

    return progress;
  }

  Stream<QueryRow> _watchCoreCounts() {
    const sql = '''
      SELECT
        (SELECT COUNT(*) FROM transactions) AS transaction_count,
        (SELECT COUNT(DISTINCT category_id) FROM transactions) AS distinct_category_count,
        (SELECT COUNT(*) FROM accounts) AS wallet_count,
        (SELECT COUNT(*) FROM transactions t JOIN categories c ON c.id = t.category_id WHERE c.type IN ('transfer', 'transfer_out')) AS transfer_count,
        (SELECT COUNT(*) FROM savings_goals) AS goal_count,
        (SELECT COUNT(*) FROM savings_goals WHERE target_amount_cents > 0 AND current_amount_cents >= target_amount_cents) AS goals_completed_count,
        (SELECT IFNULL(MAX(CAST(current_amount_cents AS REAL) * 100.0 / target_amount_cents), 0) FROM savings_goals WHERE target_amount_cents > 0) AS best_goal_progress_percent,
        (SELECT COUNT(*) FROM budgets) AS budget_count,
        (SELECT COUNT(*) FROM debts WHERE type = 'debt' AND status = 'paid') AS debts_paid_count,
        (SELECT COUNT(*) FROM debts WHERE type = 'receivable' AND status = 'paid') AS receivables_paid_count,
        (SELECT COUNT(*) FROM installments WHERE status = 'completed') AS installments_completed_count,
        (SELECT IFNULL(SUM(initial_balance_cents), 0) FROM accounts) AS net_worth_cents
    ''';

    return _db
        .customSelect(
          sql,
          readsFrom: {
            _db.transactions,
            _db.categories,
            _db.accounts,
            _db.savingsGoals,
            _db.budgets,
            _db.debts,
            _db.installments,
          },
        )
        .watchSingle();
  }
}
