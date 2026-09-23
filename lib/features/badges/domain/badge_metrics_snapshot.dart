/// Raw, DB-derived numbers [BadgeEvaluator] (`badge_evaluator.dart`) reads
/// to compute every badge's progress. One snapshot backs the whole catalog,
/// so it only ever needs to be assembled once per badge-progress recompute.
class BadgeMetricsSnapshot {
  const BadgeMetricsSnapshot({
    required this.transactionCount,
    required this.distinctCategoryCount,
    required this.currentStreakDays,
    required this.walletCount,
    required this.transferCount,
    required this.goalCount,
    required this.goalsCompletedCount,
    required this.bestGoalProgressPercent,
    required this.budgetCount,
    required this.savingsRatePercent,
    required this.debtsPaidCount,
    required this.receivablesPaidCount,
    required this.installmentsCompletedCount,
    required this.netWorthCents,
  });

  final int transactionCount;
  final int distinctCategoryCount;

  /// Consecutive days up to and including today (or yesterday, so a streak
  /// doesn't reset the instant the clock passes midnight) with at least one
  /// recorded transaction.
  final int currentStreakDays;

  final int walletCount;
  final int transferCount;

  final int goalCount;
  final int goalsCompletedCount;

  /// Highest `currentAmountCents / targetAmountCents` among all savings
  /// goals, as a whole percent (0-100, not clamped above 100).
  final int bestGoalProgressPercent;

  final int budgetCount;

  /// `(income - expense) / income` for the current calendar month, as a
  /// whole percent. 0 when there is no income yet this month.
  final int savingsRatePercent;

  final int debtsPaidCount;
  final int receivablesPaidCount;
  final int installmentsCompletedCount;

  /// Sum of every wallet's current balance, in cents.
  final int netWorthCents;
}
