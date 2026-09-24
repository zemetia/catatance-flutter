import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/report_models.dart';
import 'reports_providers.dart';

/// The most-recently-created, not-yet-funded savings goal (or `null`) — for
/// the Proyeksi screen's goal-progress insight row.
final savingsGoalInsightProvider =
    StreamProvider.autoDispose<SavingsGoalInsight?>((ref) {
  return ref.watch(reportsRepositoryProvider).watchNearestSavingsGoal();
});

/// A single day's spend, used for the "hari terboros" (biggest-spend day)
/// insight.
class DailySpendInsight {
  const DailySpendInsight({required this.day, required this.amountCents});

  final int day;
  final int amountCents;
}

/// Everything the Proyeksi screen's "Yang perlu diperhatian" list needs,
/// derived from this month's dense daily-expense array
/// ([thisMonthDailyExpenseProvider]) — no separate DB query.
class SpendingInsights {
  const SpendingInsights({
    required this.todayExpenseCents,
    required this.worstDay,
    required this.daysWithExpense,
    required this.daysElapsed,
  });

  final int todayExpenseCents;
  final DailySpendInsight? worstDay;
  final int daysWithExpense;
  final int daysElapsed;
}

final spendingInsightsProvider = Provider.autoDispose<SpendingInsights?>((ref) {
  final dailyExpense = ref.watch(thisMonthDailyExpenseProvider).value;
  if (dailyExpense == null) return null;

  final now = DateTime.now();
  final daysElapsed = now.day.clamp(1, dailyExpense.length);
  final elapsed = dailyExpense.take(daysElapsed).toList();

  DailySpendInsight? worstDay;
  var daysWithExpense = 0;
  for (var i = 0; i < elapsed.length; i++) {
    if (elapsed[i] <= 0) continue;
    daysWithExpense++;
    if (worstDay == null || elapsed[i] > worstDay.amountCents) {
      worstDay = DailySpendInsight(day: i + 1, amountCents: elapsed[i]);
    }
  }

  return SpendingInsights(
    todayExpenseCents: elapsed.isEmpty ? 0 : elapsed.last,
    worstDay: worstDay,
    daysWithExpense: daysWithExpense,
    daysElapsed: daysElapsed,
  );
});
