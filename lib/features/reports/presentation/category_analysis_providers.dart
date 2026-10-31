import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../domain/report_models.dart';
import 'reports_providers.dart';

/// Month currently inspected on the "Analisis Kategori" screen.
final categoryAnalysisMonthProvider = StateProvider.autoDispose<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// Mode (Pengeluaran / Pemasukan) for the category analysis overview.
final categoryAnalysisModeProvider = StateProvider.autoDispose<ReportMode>((ref) {
  return ReportMode.expense;
});

/// Stream of all categories with their spending, previous month comparison, and budget status.
final categoryAnalysisListProvider =
    StreamProvider.autoDispose<List<CategoryAnalysisItem>>((ref) {
  final month = ref.watch(categoryAnalysisMonthProvider);
  final mode = ref.watch(categoryAnalysisModeProvider);
  return ref.watch(reportsRepositoryProvider).watchCategoryAnalysisList(month, mode: mode);
});

/// Aggregated overview stats derived from [categoryAnalysisListProvider].
class CategoryAnalysisSummary {
  const CategoryAnalysisSummary({
    required this.totalCents,
    required this.categoryCount,
    required this.topCategory,
    required this.averagePerCategoryCents,
    required this.budgetedCount,
    required this.overBudgetCount,
  });

  final int totalCents;
  final int categoryCount;
  final CategoryAnalysisItem? topCategory;
  final int averagePerCategoryCents;
  final int budgetedCount;
  final int overBudgetCount;
}

final categoryAnalysisSummaryProvider =
    Provider.autoDispose<CategoryAnalysisSummary?>((ref) {
  final items = ref.watch(categoryAnalysisListProvider).value;
  if (items == null) return null;

  var total = 0;
  var budgetedCount = 0;
  var overBudgetCount = 0;

  for (final item in items) {
    total += item.totalCents;
    if (item.budgetLimitCents != null) {
      budgetedCount++;
      if (item.totalCents > item.budgetLimitCents!) {
        overBudgetCount++;
      }
    }
  }

  final topCategory = items.isNotEmpty && items.first.totalCents > 0 ? items.first : null;
  final avg = items.isEmpty ? 0 : total ~/ items.length;

  return CategoryAnalysisSummary(
    totalCents: total,
    categoryCount: items.length,
    topCategory: topCategory,
    averagePerCategoryCents: avg,
    budgetedCount: budgetedCount,
    overBudgetCount: overBudgetCount,
  );
});

/// Detailed flow analysis stream for a single [categoryId] in [categoryAnalysisMonthProvider].
final categoryFlowDetailProvider =
    StreamProvider.autoDispose.family<CategoryFlowDetail?, int>((ref, categoryId) {
  final month = ref.watch(categoryAnalysisMonthProvider);
  return ref
      .watch(reportsRepositoryProvider)
      .watchCategoryFlowDetail(categoryId: categoryId, month: month);
});
