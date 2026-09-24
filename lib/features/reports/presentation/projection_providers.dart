import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/report_models.dart';
import 'reports_providers.dart';

/// One day's balance curve value: `actualCents` is set for days up to and
/// including today (a solid line in the UI), `projectedCents` for today
/// onward (a dashed line) — they overlap on today itself so the two lines
/// visually connect.
class MonthProjectionPoint {
  const MonthProjectionPoint({
    required this.day,
    this.actualCents,
    this.projectedCents,
  });

  final int day;
  final int? actualCents;
  final int? projectedCents;
}

/// Everything the Proyeksi screen needs, computed live from this month's
/// transactions/accounts/budgets — nothing here is persisted, it's a plain
/// computed view-model (same convention as `BudgetItem`).
class MonthProjection {
  const MonthProjection({
    required this.healthScore,
    required this.cashflowScore,
    required this.balanceDirectionScore,
    required this.budgetComplianceScore,
    required this.currentBalanceCents,
    required this.projectedEndBalanceCents,
    required this.incomeThisMonthCents,
    required this.expenseThisMonthCents,
    required this.avgDailySpendCents,
    required this.projectedRemainingSpendCents,
    required this.dailySafeAllowanceCents,
    required this.daysInMonth,
    required this.today,
    required this.daysRemaining,
    required this.curve,
    required this.budgetHealth,
  });

  /// 0–100, sum of the three score components below.
  final int healthScore;

  /// 0–40: how healthy this month's income vs. expense is so far.
  final int cashflowScore;

  /// 0–30: whether the projected end-of-month balance holds up vs. today's.
  final int balanceDirectionScore;

  /// 0–30: derived from [budgetHealth]'s `complianceScore`.
  final int budgetComplianceScore;

  final int currentBalanceCents;
  final int projectedEndBalanceCents;
  final int incomeThisMonthCents;
  final int expenseThisMonthCents;

  /// This month's total expense divided by the number of days in the month.
  final int avgDailySpendCents;

  /// [avgDailySpendCents] times [daysRemaining] — an expense-only estimate
  /// for the rest of the month (no further income is assumed).
  final int projectedRemainingSpendCents;

  /// Safe-to-spend-per-day for the rest of the month: today's balance spread
  /// evenly across [daysRemaining] (or all of it, if today is the last day).
  final int dailySafeAllowanceCents;

  final int daysInMonth;
  final int today;
  final int daysRemaining;
  final List<MonthProjectionPoint> curve;
  final BudgetComplianceSummary budgetHealth;

  int get deltaFromNowCents => projectedEndBalanceCents - currentBalanceCents;

  String get healthLabel {
    if (healthScore >= 80) return 'Sehat';
    if (healthScore >= 50) return 'Waspada';
    return 'Kritis';
  }
}

/// Current calendar month's daily net (income minus expense), one entry per
/// day of the month (index 0 = the 1st), zero for days with no activity —
/// mirrors `thisMonthDailyExpenseProvider`'s shape but for [ReportMode.net].
final thisMonthDailyNetProvider = StreamProvider.autoDispose<List<int>>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month);
  final endExclusive = DateTime(now.year, now.month + 1);
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  return ref
      .watch(reportsRepositoryProvider)
      .watchDailyExpense(start, endExclusive, mode: ReportMode.net)
      .map((rows) {
    final totals = List<int>.filled(daysInMonth, 0);
    for (final row in rows) {
      totals[row.date.day - 1] = row.totalCents;
    }
    return totals;
  });
});

/// A category's budget vs. this month's spend so far, or `null` if it has no
/// budget — for the "Boleh nggak beli sesuatu?" simulator.
final categoryBudgetInfoProvider =
    StreamProvider.autoDispose.family<CategoryBudgetInfo?, int>((ref, categoryId) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month);
  final endExclusive = DateTime(now.year, now.month + 1);
  return ref
      .watch(reportsRepositoryProvider)
      .watchBudgetForCategory(categoryId, start, endExclusive);
});

final budgetComplianceProvider =
    StreamProvider.autoDispose<BudgetComplianceSummary>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month);
  final endExclusive = DateTime(now.year, now.month + 1);
  return ref
      .watch(reportsRepositoryProvider)
      .watchBudgetCompliance(start, endExclusive);
});

/// `null` while any of its underlying streams hasn't produced a first value
/// yet — the screen shows its shimmer/loading state in that case.
final monthProjectionProvider = Provider.autoDispose<MonthProjection?>((ref) {
  final currentBalance = ref.watch(netWorthProvider).value;
  final income = ref.watch(thisMonthIncomeProvider).value;
  final expense = ref.watch(thisMonthExpenseProvider).value;
  final dailyNet = ref.watch(thisMonthDailyNetProvider).value;
  final budgetHealth = ref.watch(budgetComplianceProvider).value;

  if (currentBalance == null ||
      income == null ||
      expense == null ||
      dailyNet == null ||
      budgetHealth == null) {
    return null;
  }

  final now = DateTime.now();
  final daysInMonth = dailyNet.length;
  final today = now.day.clamp(1, daysInMonth);
  final daysRemaining = daysInMonth - today;

  var cumulative = 0;
  final cumulativeByDay = List<int>.filled(daysInMonth, 0);
  for (var i = 0; i < daysInMonth; i++) {
    cumulative += dailyNet[i];
    cumulativeByDay[i] = cumulative;
  }
  final netSoFar = cumulativeByDay[today - 1];
  final startOfMonthBalance = currentBalance - netSoFar;
  final avgDailyNet = netSoFar / today;

  final curve = <MonthProjectionPoint>[
    for (var day = 1; day <= daysInMonth; day++)
      MonthProjectionPoint(
        day: day,
        actualCents: day <= today
            ? startOfMonthBalance + cumulativeByDay[day - 1]
            : null,
        projectedCents: day >= today
            ? currentBalance + (avgDailyNet * (day - today)).round()
            : null,
      ),
  ];
  final projectedEndBalance = curve.last.projectedCents!;

  final avgDailySpend = (expense / daysInMonth).round();
  final projectedRemainingSpend = avgDailySpend * daysRemaining;
  final allowanceDays = daysRemaining > 0 ? daysRemaining : 1;
  final dailySafeAllowance = (currentBalance / allowanceDays).round();

  final cashflowRatio = income <= 0
      ? (income - expense >= 0 ? 1.0 : 0.0)
      : ((income - expense) / income).clamp(0.0, 1.0);
  final cashflowScore = (cashflowRatio * 40).round();

  final delta = projectedEndBalance - currentBalance;
  double balanceDirectionRatio;
  if (delta >= 0 || currentBalance <= 0) {
    balanceDirectionRatio = 1.0;
  } else {
    final declinePct = (-delta) / currentBalance;
    balanceDirectionRatio = (1 - (declinePct * 10).clamp(0.0, 1.0));
  }
  final balanceDirectionScore = (balanceDirectionRatio * 30).round();

  final budgetComplianceScore = (budgetHealth.complianceScore * 30).round();

  return MonthProjection(
    healthScore: (cashflowScore + balanceDirectionScore + budgetComplianceScore)
        .clamp(0, 100),
    cashflowScore: cashflowScore,
    balanceDirectionScore: balanceDirectionScore,
    budgetComplianceScore: budgetComplianceScore,
    currentBalanceCents: currentBalance,
    projectedEndBalanceCents: projectedEndBalance,
    incomeThisMonthCents: income,
    expenseThisMonthCents: expense,
    avgDailySpendCents: avgDailySpend,
    projectedRemainingSpendCents: projectedRemainingSpend,
    dailySafeAllowanceCents: dailySafeAllowance,
    daysInMonth: daysInMonth,
    today: today,
    daysRemaining: daysRemaining,
    curve: curve,
    budgetHealth: budgetHealth,
  );
});
