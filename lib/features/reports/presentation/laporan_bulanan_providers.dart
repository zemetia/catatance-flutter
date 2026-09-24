import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../domain/report_models.dart';
import 'reports_providers.dart';

/// The month currently shown on the "Laporan bulanan" detail screen —
/// deliberately separate from [selectedReportMonthProvider] (the Statistik
/// screen's own month pill row) so navigating this screen's prev/next
/// arrows doesn't also move the parent Statistik screen's selection.
final laporanBulananMonthProvider = StateProvider.autoDispose<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// Pengeluaran/Pemasukan toggle for the category & tag breakdown cards.
/// [ReportMode.net] is never used here — this screen always shows one side
/// of the ledger at a time, never the combined net.
final laporanBulananModeProvider = StateProvider.autoDispose<ReportMode>((ref) {
  return ReportMode.expense;
});

(DateTime, DateTime) _monthRange(DateTime month) {
  return (DateTime(month.year, month.month), DateTime(month.year, month.month + 1));
}

final laporanIncomeProvider = StreamProvider.autoDispose<int>((ref) {
  final month = ref.watch(laporanBulananMonthProvider);
  final (start, end) = _monthRange(month);
  return ref.watch(reportsRepositoryProvider).watchTotalIncome(start, end);
});

final laporanExpenseProvider = StreamProvider.autoDispose<int>((ref) {
  final month = ref.watch(laporanBulananMonthProvider);
  final (start, end) = _monthRange(month);
  return ref.watch(reportsRepositoryProvider).watchTotalExpense(start, end);
});

final laporanTransactionCountProvider = StreamProvider.autoDispose<int>((ref) {
  final month = ref.watch(laporanBulananMonthProvider);
  final (start, end) = _monthRange(month);
  return ref.watch(reportsRepositoryProvider).watchTransactionCount(start, end);
});

final laporanDailySpendingProvider =
    StreamProvider.autoDispose<List<DailySpending>>((ref) {
  final month = ref.watch(laporanBulananMonthProvider);
  final mode = ref.watch(laporanBulananModeProvider);
  final (start, end) = _monthRange(month);
  return ref
      .watch(reportsRepositoryProvider)
      .watchDailyExpense(start, end, mode: mode);
});

final laporanCategoryBreakdownProvider =
    StreamProvider.autoDispose<List<CategorySpending>>((ref) {
  final month = ref.watch(laporanBulananMonthProvider);
  final mode = ref.watch(laporanBulananModeProvider);
  final (start, end) = _monthRange(month);
  return ref
      .watch(reportsRepositoryProvider)
      .watchCategoryBreakdown(start, end, mode: mode);
});

final laporanTagBreakdownProvider =
    StreamProvider.autoDispose<List<TagSpending>>((ref) {
  final month = ref.watch(laporanBulananMonthProvider);
  final mode = ref.watch(laporanBulananModeProvider);
  final (start, end) = _monthRange(month);
  return ref
      .watch(reportsRepositoryProvider)
      .watchTagBreakdown(start, end, mode: mode);
});
