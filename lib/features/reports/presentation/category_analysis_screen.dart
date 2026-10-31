import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/security/security_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/report_models.dart';
import 'category_analysis_providers.dart';
import 'widgets/report_shimmer_box.dart';

class CategoryAnalysisScreen extends ConsumerWidget {
  const CategoryAnalysisScreen({super.key});

  static final _monthFormatter = DateFormat('MMMM yyyy', 'id_ID');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(categoryAnalysisMonthProvider);
    final mode = ref.watch(categoryAnalysisModeProvider);
    final itemsAsync = ref.watch(categoryAnalysisListProvider);
    final summary = ref.watch(categoryAnalysisSummaryProvider);
    final hideBalance = ref.watch(hideBalanceProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    void changeMonth(int delta) {
      ref.read(categoryAnalysisMonthProvider.notifier).state =
          DateTime(month.year, month.month + delta);
    }

    return Scaffold(
      body: SafeArea(
        child: SmoothListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            FloatingNavBar.clearance,
          ),
          children: [
            Row(
              children: [
                CircleIconButton(
                  icon: LucideIcons.chevron_left,
                  backgroundColor: scheme.surfaceContainerHigh,
                  onTap: () => context.pop(),
                ),
                Expanded(
                  child: Text(
                    'Analisis Kategori',
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                CircleIconButton(
                  icon: LucideIcons.plus,
                  backgroundColor: scheme.surfaceContainerHigh,
                  onTap: () => context.push('/transactions/add'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Month navigator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleIconButton(
                  icon: LucideIcons.chevron_left,
                  size: 18,
                  onTap: () => changeMonth(-1),
                ),
                SizedBox(
                  width: 200,
                  child: Text(
                    _monthFormatter.format(month),
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                CircleIconButton(
                  icon: LucideIcons.chevron_right,
                  size: 18,
                  onTap: () => changeMonth(1),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Mode toggle (Pengeluaran / Pemasukan)
            _CategoryModeToggle(
              selected: mode,
              onChanged: (m) =>
                  ref.read(categoryAnalysisModeProvider.notifier).state = m,
            ),
            const SizedBox(height: AppSpacing.md),
            // Overview Hero Card
            _OverviewHeroCard(
              mode: mode,
              summary: summary,
              hideBalance: hideBalance,
              items: itemsAsync.value ?? const [],
            ),
            const SizedBox(height: AppSpacing.lg),
            // List Section Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alur Kategori',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pilih kategori untuk melihat alur detail, tren & sumber dana',
                        style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            itemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.chart_pie, size: 48, color: scheme.outline),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Belum ada transaksi ${mode.label.toLowerCase()} di bulan ini',
                            style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton.icon(
                            onPressed: () => context.push('/transactions/add'),
                            icon: const Icon(LucideIcons.plus, size: 16),
                            label: const Text('Catat Transaksi Sekarang'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _CategoryListItemCard(
                          item: item,
                          mode: mode,
                          hideBalance: hideBalance,
                          onTap: () => context.push('/reports/categories/${item.categoryId}'),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Column(
                children: [
                  ReportShimmerBox(width: double.infinity, height: 80),
                  SizedBox(height: AppSpacing.sm),
                  ReportShimmerBox(width: double.infinity, height: 80),
                  SizedBox(height: AppSpacing.sm),
                  ReportShimmerBox(width: double.infinity, height: 80),
                ],
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Gagal memuat analisis kategori: $err',
                  style: textTheme.bodySmall?.copyWith(color: scheme.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryModeToggle extends StatelessWidget {
  const _CategoryModeToggle({required this.selected, required this.onChanged});

  final ReportMode selected;
  final ValueChanged<ReportMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget item(ReportMode mode) {
      final isSelected = mode == selected;
      return Expanded(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: InkWell(
            onTap: () => onChanged(mode),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? scheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              alignment: Alignment.center,
              child: Text(
                mode.label,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Row(
        children: [item(ReportMode.expense), item(ReportMode.income)],
      ),
    );
  }
}

class _OverviewHeroCard extends StatelessWidget {
  const _OverviewHeroCard({
    required this.mode,
    required this.summary,
    required this.hideBalance,
    required this.items,
  });

  final ReportMode mode;
  final CategoryAnalysisSummary? summary;
  final bool hideBalance;
  final List<CategoryAnalysisItem> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalCents = summary?.totalCents ?? 0;
    final activeCount = summary?.categoryCount ?? 0;
    final top = summary?.topCategory;
    final avg = summary?.averagePerCategoryCents ?? 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Total ${mode.label}',
                style: textTheme.labelMedium?.copyWith(
                  color: scheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
                child: Text(
                  '$activeCount Kategori Aktif',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hideBalance ? '••••••••' : formatRupiah(totalCents),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Visual multi-color distribution bar
          if (items.isNotEmpty && totalCents > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              child: SizedBox(
                height: 8,
                child: Row(
                  children: [
                    for (final item in items.take(6))
                      if (item.share > 0.01)
                        Expanded(
                          flex: (item.share * 1000).toInt(),
                          child: Container(color: item.color),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          // 2-column key metrics row
          Row(
            children: [
              Expanded(
                child: _HeroStatBox(
                  label: 'Kategori Terbesar',
                  value: top != null ? top.name : '-',
                  subtitle: top != null
                      ? '${hideBalance ? "••••" : formatRupiahCompact(top.totalCents)} (${(top.share * 100).toStringAsFixed(1)}%)'
                      : 'Belum ada',
                  accentColor: top?.color ?? scheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _HeroStatBox(
                  label: 'Rata-rata / Kategori',
                  value: hideBalance ? '••••' : formatRupiahCompact(avg),
                  subtitle: 'Dari $activeCount kategori',
                  accentColor: scheme.tertiary,
                ),
              ),
            ],
          ),
          if ((summary?.overBudgetCount ?? 0) > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.expense.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.triangle_alert, size: 16, color: AppColors.expense),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Perhatian: ${summary!.overBudgetCount} kategori telah melebihi batas anggaran bulan ini.',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.expense,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroStatBox extends StatelessWidget {
  const _HeroStatBox({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.accentColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(color: scheme.outline),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: textTheme.labelSmall?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CategoryListItemCard extends StatelessWidget {
  const _CategoryListItemCard({
    required this.item,
    required this.mode,
    required this.hideBalance,
    required this.onTap,
  });

  final CategoryAnalysisItem item;
  final ReportMode mode;
  final bool hideBalance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pctChange = item.percentageChange;
    final isOverBudget = item.budgetLimitCents != null &&
        item.totalCents > item.budgetLimitCents!;

    Color trendColor() {
      if (pctChange == null || pctChange == 0) return scheme.outline;
      if (mode == ReportMode.expense) {
        return pctChange > 0 ? AppColors.expense : AppColors.income;
      } else {
        return pctChange > 0 ? AppColors.income : AppColors.expense;
      }
    }

    String trendText() {
      if (pctChange == null) return 'Baru';
      final sign = pctChange > 0 ? '+' : '';
      return '$sign${pctChange.toStringAsFixed(0)}% vs bln lalu';
    }

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBadge(
                    icon: item.iconData,
                    color: item.color,
                    shape: BoxShape.rectangle,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.name,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isOverBudget) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.expense.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                ),
                                child: Text(
                                  'Over budget',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: AppColors.expense,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${item.count} transaksi • ${(item.share * 100).toStringAsFixed(1)}%',
                              style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: trendColor().withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                              child: Text(
                                trendText(),
                                style: textTheme.labelSmall?.copyWith(
                                  color: trendColor(),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        hideBalance ? '••••' : formatRupiah(item.totalCents),
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Icon(LucideIcons.chevron_right, size: 14, color: scheme.outline),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Share progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                child: LinearProgressIndicator(
                  value: item.share.clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(item.color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
