import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/database/app_database.dart';
import '../data/reports_repository.dart';
import '../domain/report_models.dart';

const monthSelectorSpan = 5;

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReportsRepository(db);
});

/// The month currently shown on the statistics screen (day-of-month ignored).
final selectedReportMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// Which side of the ledger the statistics screen is currently showing
/// (expense, income, or net).
final selectedReportModeProvider = StateProvider<ReportMode>((ref) {
  return ReportMode.expense;
});

/// The [monthSelectorSpan] months available in the month-selector pill row,
/// oldest first, ending at the current calendar month.
List<DateTime> reportMonthOptions() {
  final now = DateTime.now();
  return [
    for (var i = monthSelectorSpan - 1; i >= 0; i--)
      DateTime(now.year, now.month - i),
  ];
}

final netWorthProvider = StreamProvider.autoDispose<int>((ref) {
  return ref.watch(reportsRepositoryProvider).watchNetWorth();
});

/// The 7 days ending on the last day of the selected month, or today when
/// the selected month is the current one.
(DateTime, DateTime) _weekWindowFor(DateTime month) {
  final now = DateTime.now();
  final isCurrentMonth = month.year == now.year && month.month == now.month;
  final end = isCurrentMonth
      ? DateTime(now.year, now.month, now.day)
      : DateTime(month.year, month.month + 1, 0);
  final start = end.subtract(const Duration(days: 6));
  return (start, end.add(const Duration(days: 1)));
}

final dailySpendingProvider =
    StreamProvider.autoDispose<List<DailySpending>>((ref) {
  final month = ref.watch(selectedReportMonthProvider);
  final mode = ref.watch(selectedReportModeProvider);
  final (start, endExclusive) = _weekWindowFor(month);
  return ref
      .watch(reportsRepositoryProvider)
      .watchDailyExpense(start, endExclusive, mode: mode);
});

final weeklyTotalProvider = StreamProvider.autoDispose<int>((ref) {
  final month = ref.watch(selectedReportMonthProvider);
  final mode = ref.watch(selectedReportModeProvider);
  final (start, endExclusive) = _weekWindowFor(month);
  return ref
      .watch(reportsRepositoryProvider)
      .watchTotal(start, endExclusive, mode: mode);
});

final categoryBreakdownProvider =
    StreamProvider.autoDispose<List<CategorySpending>>((ref) {
  final month = ref.watch(selectedReportMonthProvider);
  final mode = ref.watch(selectedReportModeProvider);
  final start = DateTime(month.year, month.month);
  final endExclusive = DateTime(month.year, month.month + 1);
  return ref
      .watch(reportsRepositoryProvider)
      .watchCategoryBreakdown(start, endExclusive, mode: mode);
});

final monthlyTrendProvider =
    StreamProvider.autoDispose<List<MonthlySpending>>((ref) {
  final month = ref.watch(selectedReportMonthProvider);
  final mode = ref.watch(selectedReportModeProvider);
  return ref.watch(reportsRepositoryProvider).watchMonthlyTrend(
        month,
        monthsCount: monthSelectorSpan,
        mode: mode,
      );
});

/// Selected report month's total income, expense, and net (income minus
/// expense) — independent of [selectedReportModeProvider], for summary rows
/// that show all three side by side regardless of the active chart mode.
final selectedMonthIncomeProvider = StreamProvider.autoDispose<int>((ref) {
  final month = ref.watch(selectedReportMonthProvider);
  final start = DateTime(month.year, month.month);
  final endExclusive = DateTime(month.year, month.month + 1);
  return ref
      .watch(reportsRepositoryProvider)
      .watchTotal(start, endExclusive, mode: ReportMode.income);
});

final selectedMonthExpenseProvider = StreamProvider.autoDispose<int>((ref) {
  final month = ref.watch(selectedReportMonthProvider);
  final start = DateTime(month.year, month.month);
  final endExclusive = DateTime(month.year, month.month + 1);
  return ref
      .watch(reportsRepositoryProvider)
      .watchTotal(start, endExclusive, mode: ReportMode.expense);
});

final selectedMonthNetProvider = StreamProvider.autoDispose<int>((ref) {
  final month = ref.watch(selectedReportMonthProvider);
  final start = DateTime(month.year, month.month);
  final endExclusive = DateTime(month.year, month.month + 1);
  return ref
      .watch(reportsRepositoryProvider)
      .watchTotal(start, endExclusive, mode: ReportMode.net);
});

/// Current calendar month's total income (for dashboard and summaries).
final thisMonthIncomeProvider = StreamProvider.autoDispose<int>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month);
  final endExclusive = DateTime(now.year, now.month + 1);
  return ref
      .watch(reportsRepositoryProvider)
      .watchTotalIncome(start, endExclusive);
});

/// Current calendar month's total expense (for dashboard and summaries).
final thisMonthExpenseProvider = StreamProvider.autoDispose<int>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month);
  final endExclusive = DateTime(now.year, now.month + 1);
  return ref
      .watch(reportsRepositoryProvider)
      .watchTotalExpense(start, endExclusive);
});

/// Current calendar month's expense per day, one entry per day of the
/// month (index 0 = the 1st), zero for days with no expense — for the
/// dashboard balance card's per-day bar strip.
final thisMonthDailyExpenseProvider =
    StreamProvider.autoDispose<List<int>>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month);
  final endExclusive = DateTime(now.year, now.month + 1);
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  return ref
      .watch(reportsRepositoryProvider)
      .watchDailyExpense(start, endExclusive)
      .map((rows) {
    final totals = List<int>.filled(daysInMonth, 0);
    for (final row in rows) {
      totals[row.date.day - 1] = row.totalCents;
    }
    return totals;
  });
});
