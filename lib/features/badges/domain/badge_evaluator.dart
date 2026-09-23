import 'badge_definition.dart';
import 'badge_metrics_snapshot.dart';
import 'badge_progress.dart';

/// Pure mapping from a [BadgeDefinition.key] to its live value inside a
/// [BadgeMetricsSnapshot] — the only place that needs updating when a new
/// badge is added to `badge_catalog.dart`.
int _currentValueFor(String key, BadgeMetricsSnapshot s) {
  return switch (key) {
    'first_transaction' || 'transactions_50' || 'transactions_250' ||
    'transactions_1000' =>
      s.transactionCount,
    'categories_8' => s.distinctCategoryCount,
    'streak_7' || 'streak_30' => s.currentStreakDays,
    'wallets_3' || 'wallets_5' => s.walletCount,
    'transfers_5' => s.transferCount,
    'goal_first' => s.goalCount,
    'goal_halfway' => s.bestGoalProgressPercent,
    'goal_completed_1' || 'goal_completed_3' => s.goalsCompletedCount,
    'budget_first' => s.budgetCount,
    'savings_rate_20' => s.savingsRatePercent,
    'debt_paid_1' => s.debtsPaidCount,
    'receivable_paid_1' => s.receivablesPaidCount,
    'installment_completed_1' => s.installmentsCompletedCount,
    'net_worth_10jt' => s.netWorthCents,
    _ => 0,
  };
}

/// Evaluates the whole [badgeCatalog] against a metrics snapshot and the set
/// of already-earned badge keys (from `EarnedBadges`). A badge already in
/// [earnedAt] stays [BadgeProgress.isUnlocked] regardless of its live value
/// (sticky achievements); one not yet earned unlocks the moment its current
/// value reaches its target.
List<BadgeProgress> evaluateBadges(
  BadgeMetricsSnapshot snapshot,
  Map<String, DateTime> earnedAt, {
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  return [
    for (final definition in badgeCatalog)
      _evaluateOne(definition, snapshot, earnedAt, reference),
  ];
}

BadgeProgress _evaluateOne(
  BadgeDefinition definition,
  BadgeMetricsSnapshot snapshot,
  Map<String, DateTime> earnedAt,
  DateTime now,
) {
  final currentValue = _currentValueFor(definition.key, snapshot);
  final alreadyEarnedAt = earnedAt[definition.key];
  final meetsTargetNow = currentValue >= definition.target;

  return BadgeProgress(
    definition: definition,
    currentValue: currentValue,
    isUnlocked: alreadyEarnedAt != null || meetsTargetNow,
    unlockedAt: alreadyEarnedAt ?? (meetsTargetNow ? now : null),
  );
}
