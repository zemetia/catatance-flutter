import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../domain/report_models.dart';
import 'reports_providers.dart';

/// The month currently shown on the "Kalender Cashflow" screen (day-of-month
/// ignored) — deliberately separate from [selectedReportMonthProvider] so
/// navigating this screen never disturbs the main Statistik screen's month.
final kalenderCashflowMonthProvider = StateProvider.autoDispose<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// The day currently selected in the calendar grid, whose transactions show
/// in the detail list below it. Defaults to today.
final kalenderSelectedDateProvider = StateProvider.autoDispose<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final kalenderMonthCashflowProvider =
    StreamProvider.autoDispose<List<DailyCashflow>>((ref) {
  final month = ref.watch(kalenderCashflowMonthProvider);
  final start = DateTime(month.year, month.month);
  final endExclusive = DateTime(month.year, month.month + 1);
  return ref
      .watch(reportsRepositoryProvider)
      .watchDailyCashflow(start, endExclusive);
});

final kalenderMonthIncomeProvider = StreamProvider.autoDispose<int>((ref) {
  final month = ref.watch(kalenderCashflowMonthProvider);
  final start = DateTime(month.year, month.month);
  final endExclusive = DateTime(month.year, month.month + 1);
  return ref
      .watch(reportsRepositoryProvider)
      .watchTotalIncome(start, endExclusive);
});

final kalenderMonthExpenseProvider = StreamProvider.autoDispose<int>((ref) {
  final month = ref.watch(kalenderCashflowMonthProvider);
  final start = DateTime(month.year, month.month);
  final endExclusive = DateTime(month.year, month.month + 1);
  return ref
      .watch(reportsRepositoryProvider)
      .watchTotalExpense(start, endExclusive);
});

final kalenderMonthNetProvider = StreamProvider.autoDispose<int>((ref) {
  final month = ref.watch(kalenderCashflowMonthProvider);
  final start = DateTime(month.year, month.month);
  final endExclusive = DateTime(month.year, month.month + 1);
  return ref
      .watch(reportsRepositoryProvider)
      .watchTotal(start, endExclusive, mode: ReportMode.net);
});

final kalenderSelectedDateTransactionsProvider =
    StreamProvider.autoDispose<List<CashflowTransaction>>((ref) {
  final date = ref.watch(kalenderSelectedDateProvider);
  return ref.watch(reportsRepositoryProvider).watchTransactionsForDate(date);
});
