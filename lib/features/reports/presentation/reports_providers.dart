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

final dailyExpenseProvider =
    StreamProvider.autoDispose<List<DailySpending>>((ref) {
  final month = ref.watch(selectedReportMonthProvider);
  final (start, endExclusive) = _weekWindowFor(month);
  return ref
      .watch(reportsRepositoryProvider)
      .watchDailyExpense(start, endExclusive);
});

final weeklyExpenseTotalProvider = StreamProvider.autoDispose<int>((ref) {
  final month = ref.watch(selectedReportMonthProvider);
  final (start, endExclusive) = _weekWindowFor(month);
  return ref
      .watch(reportsRepositoryProvider)
      .watchTotalExpense(start, endExclusive);
});

final categoryBreakdownProvider =
    StreamProvider.autoDispose<List<CategorySpending>>((ref) {
  final month = ref.watch(selectedReportMonthProvider);
  final start = DateTime(month.year, month.month);
  final endExclusive = DateTime(month.year, month.month + 1);
  return ref
      .watch(reportsRepositoryProvider)
      .watchCategoryBreakdown(start, endExclusive);
});

final monthlyTrendProvider =
    StreamProvider.autoDispose<List<MonthlySpending>>((ref) {
  final month = ref.watch(selectedReportMonthProvider);
  return ref.watch(reportsRepositoryProvider).watchMonthlyTrend(
        month,
        monthsCount: monthSelectorSpan,
      );
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
