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
import 'widgets/report_interactive_bar_chart.dart';
import 'widgets/report_shimmer_box.dart';

class CategoryDetailScreen extends ConsumerWidget {
  const CategoryDetailScreen({required this.categoryId, super.key});

  final int categoryId;

  static final _monthFormatter = DateFormat('MMMM yyyy', 'id_ID');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(categoryAnalysisMonthProvider);
    final detailAsync = ref.watch(categoryFlowDetailProvider(categoryId));
    final hideBalance = ref.watch(hideBalanceProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    void changeMonth(int delta) {
      ref.read(categoryAnalysisMonthProvider.notifier).state =
          DateTime(month.year, month.month + delta);
    }

    return Scaffold(
      body: SafeArea(
        child: detailAsync.when(
          data: (detail) {
            if (detail == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.circle_alert, size: 48, color: scheme.outline),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Kategori tidak ditemukan',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              );
            }

            final isExpense = detail.categoryType == 'expense';
            final pctChange = detail.percentageChange;

            return SmoothListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                FloatingNavBar.clearance,
              ),
              children: [
                // Top App Bar
                Row(
                  children: [
                    CircleIconButton(
                      icon: LucideIcons.chevron_left,
                      backgroundColor: scheme.surfaceContainerHigh,
                      onTap: () => context.pop(),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.categoryName,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Alur & Analisis Kategori',
                            style: textTheme.labelSmall?.copyWith(color: scheme.outline),
                          ),
                        ],
                      ),
                    ),
                    IconBadge(
                      icon: detail.iconData,
                      color: detail.color,
                      size: 38,
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
                // Hero Summary Card
                _CategoryHeroCard(
                  detail: detail,
                  hideBalance: hideBalance,
                  isExpense: isExpense,
                  pctChange: pctChange,
                ),
                const SizedBox(height: AppSpacing.md),
                // Budget Status Card (if applicable)
                if (isExpense) ...[
                  _CategoryBudgetFlowCard(detail: detail, hideBalance: hideBalance),
                  const SizedBox(height: AppSpacing.md),
                ],
                // Historical 6-Month Trend Chart Card
                _CategoryTrendChartCard(detail: detail),
                const SizedBox(height: AppSpacing.md),
                // Wallet Breakdown (Alur Sumber Dana)
                _CategoryWalletFlowCard(detail: detail, hideBalance: hideBalance),
                const SizedBox(height: AppSpacing.md),
                // Sub-category / #Tags Breakdown
                if (detail.tags.isNotEmpty) ...[
                  _CategoryTagsFlowCard(detail: detail, hideBalance: hideBalance),
                  const SizedBox(height: AppSpacing.md),
                ],
                // Smart Insight Card
                _CategoryInsightCard(detail: detail, isExpense: isExpense),
                const SizedBox(height: AppSpacing.md),
                // Transaction History List
                _CategoryTransactionsCard(
                  detail: detail,
                  hideBalance: hideBalance,
                  onAddTransaction: () => context.push('/transactions/add'),
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                ReportShimmerBox(width: double.infinity, height: 180),
                SizedBox(height: AppSpacing.md),
                ReportShimmerBox(width: double.infinity, height: 120),
                SizedBox(height: AppSpacing.md),
                ReportShimmerBox(width: double.infinity, height: 200),
              ],
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Terjadi kesalahan saat memuat data: $err',
                style: textTheme.bodyMedium?.copyWith(color: scheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryHeroCard extends StatelessWidget {
  const _CategoryHeroCard({
    required this.detail,
    required this.hideBalance,
    required this.isExpense,
    required this.pctChange,
  });

  final CategoryFlowDetail detail;
  final bool hideBalance;
  final bool isExpense;
  final double? pctChange;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color trendColor() {
      if (pctChange == null || pctChange == 0) return scheme.outline;
      if (isExpense) {
        return pctChange! > 0 ? AppColors.expense : AppColors.income;
      } else {
        return pctChange! > 0 ? AppColors.income : AppColors.expense;
      }
    }

    String trendLabel() {
      if (pctChange == null) return 'Baru bulan ini';
      final sign = pctChange! > 0 ? '+' : '';
      final word = pctChange! > 0
          ? (isExpense ? 'naik' : 'naik')
          : (isExpense ? 'hemat' : 'turun');
      return '$sign${pctChange!.toStringAsFixed(1)}% ($word vs bln lalu)';
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Total ${isExpense ? "Pengeluaran" : "Pemasukan"}',
                style: textTheme.labelMedium?.copyWith(
                  color: scheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: detail.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
                child: Text(
                  '${(detail.shareOfTotal * 100).toStringAsFixed(1)}% dari total',
                  style: textTheme.labelSmall?.copyWith(
                    color: detail.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hideBalance ? '••••••••' : formatRupiah(detail.totalCents),
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Share bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            child: LinearProgressIndicator(
              value: detail.shareOfTotal.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(detail.color),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // 3-Metric Row
          Row(
            children: [
              Expanded(
                child: _HeroDetailMetric(
                  icon: LucideIcons.calculator,
                  label: 'Rata-rata / trx',
                  value: hideBalance ? '••••' : formatRupiahCompact(detail.averageCents),
                ),
              ),
              Container(width: 1, height: 32, color: scheme.outlineVariant.withValues(alpha: 0.5)),
              Expanded(
                child: _HeroDetailMetric(
                  icon: LucideIcons.repeat,
                  label: 'Frekuensi',
                  value: '${detail.transactionCount} kali',
                ),
              ),
              Container(width: 1, height: 32, color: scheme.outlineVariant.withValues(alpha: 0.5)),
              Expanded(
                child: _HeroDetailMetric(
                  icon: LucideIcons.trending_up,
                  label: 'Tren bln lalu',
                  value: pctChange == null
                      ? 'Baru'
                      : '${pctChange! > 0 ? "+" : ""}${pctChange!.toStringAsFixed(0)}%',
                  valueColor: trendColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
            decoration: BoxDecoration(
              color: trendColor().withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  pctChange != null && pctChange! > 0
                      ? LucideIcons.trending_up
                      : LucideIcons.trending_down,
                  size: 14,
                  color: trendColor(),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    trendLabel(),
                    style: textTheme.bodySmall?.copyWith(
                      color: trendColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroDetailMetric extends StatelessWidget {
  const _HeroDetailMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: scheme.outline),
            const SizedBox(width: 3),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(color: scheme.outline, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _CategoryBudgetFlowCard extends StatelessWidget {
  const _CategoryBudgetFlowCard({required this.detail, required this.hideBalance});

  final CategoryFlowDetail detail;
  final bool hideBalance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final limit = detail.budgetLimitCents;
    final spent = detail.budgetSpentCents ?? detail.totalCents;

    if (limit == null) {
      return AppCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(LucideIcons.wallet, size: 20, color: scheme.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Belum Ada Pagu Anggaran',
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Atur batas bulanan untuk mengontrol pengeluaran kategori ini',
                    style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => context.push('/budget'),
              child: const Text('Atur'),
            ),
          ],
        ),
      );
    }

    final ratio = detail.budgetUsageRatio ?? 0.0;
    final isOver = spent > limit;
    final isCaution = ratio >= 0.8 && !isOver;
    final statusColor = isOver
        ? AppColors.expense
        : (isCaution ? Colors.orange : AppColors.income);
    final statusLabel = isOver
        ? 'Melebihi Anggaran'
        : (isCaution ? 'Mendekati Batas' : 'Aman');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Status Anggaran',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
                child: Text(
                  statusLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(statusColor),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                'Terpakai: ${hideBalance ? "••••" : formatRupiahCompact(spent)}',
                style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                'Pagu: ${hideBalance ? "••••" : formatRupiahCompact(limit)}',
                style: textTheme.bodySmall?.copyWith(color: scheme.outline),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            isOver
                ? 'Kelebihan ${hideBalance ? "••••" : formatRupiahCompact(spent - limit)} dari pagu'
                : 'Sisa kuota: ${hideBalance ? "••••" : formatRupiahCompact(limit - spent)}',
            style: textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTrendChartCard extends StatelessWidget {
  const _CategoryTrendChartCard({required this.detail});

  final CategoryFlowDetail detail;

  static final _shortMonthFormatter = DateFormat('MMM', 'id_ID');

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final barData = [
      for (final item in detail.monthlyTrends)
        ReportBarDatum(
          axisLabel: _shortMonthFormatter.format(item.month),
          value: item.totalCents,
          color: item.totalCents > 0 ? detail.color : scheme.surfaceContainerHighest,
        ),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tren 6 Bulan Terakhir',
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Fluktuasi pengeluaran kategori dari waktu ke waktu',
                      style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chart_bar, size: 20, color: scheme.outline),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ReportInteractiveBarChart(
            data: barData,
            height: 140,
          ),
        ],
      ),
    );
  }
}

class _CategoryWalletFlowCard extends StatelessWidget {
  const _CategoryWalletFlowCard({required this.detail, required this.hideBalance});

  final CategoryFlowDetail detail;
  final bool hideBalance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alur Sumber Dana (Dompet)',
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dari mana uang kategori ini mengalir keluar?',
                      style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.arrow_down_right, size: 20, color: scheme.outline),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (detail.wallets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'Belum ada alur transaksi dompet bulan ini',
                style: textTheme.bodySmall?.copyWith(color: scheme.outline),
              ),
            )
          else
            Column(
              children: [
                for (final wallet in detail.wallets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.wallet, size: 16, color: detail.color),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  wallet.accountName,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                hideBalance ? '••••' : formatRupiah(wallet.totalCents),
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                                  child: LinearProgressIndicator(
                                    value: wallet.share.clamp(0.0, 1.0),
                                    minHeight: 4,
                                    backgroundColor: scheme.surfaceContainerHighest,
                                    valueColor: AlwaysStoppedAnimation(detail.color),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '${(wallet.share * 100).toStringAsFixed(0)}% (${wallet.count}x)',
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.outline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CategoryTagsFlowCard extends StatelessWidget {
  const _CategoryTagsFlowCard({required this.detail, required this.hideBalance});

  final CategoryFlowDetail detail;
  final bool hideBalance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pola Belanja (#Tag)',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Icon(LucideIcons.hash, size: 18, color: scheme.outline),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final tag in detail.tags)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#${tag.tag}',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hideBalance ? '••••' : formatRupiahCompact(tag.totalCents),
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${tag.count}x)',
                        style: textTheme.labelSmall?.copyWith(color: scheme.outline, fontSize: 10),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryInsightCard extends StatelessWidget {
  const _CategoryInsightCard({required this.detail, required this.isExpense});

  final CategoryFlowDetail detail;
  final bool isExpense;

  static final _dayFormatter = DateFormat('d MMMM', 'id_ID');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final biggest = detail.biggestTransaction;
    final mainWallet = detail.wallets.isNotEmpty ? detail.wallets.first : null;

    final insights = <String>[];

    if (biggest != null) {
      insights.add(
        'Transaksi terbesar adalah "${biggest.title}" sebesar ${formatRupiahCompact(biggest.amountCents)} pada ${_dayFormatter.format(biggest.date)}.',
      );
    }

    if (mainWallet != null && detail.wallets.length > 1) {
      insights.add(
        'Sumber dana utama: ${mainWallet.accountName} (${(mainWallet.share * 100).toStringAsFixed(0)}% dari seluruh transaksi kategori ini).',
      );
    }

    if (detail.transactionCount > 5) {
      insights.add(
        'Frekuensi transaksi kategori ini cukup aktif (${detail.transactionCount} transaksi dalam satu bulan).',
      );
    }

    if (insights.isEmpty) {
      insights.add(
        'Belum banyak aktivitas transaksi tercatat di kategori ini untuk bulan terpilih.',
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.sparkles, size: 18, color: scheme.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Insight Alur Transaksi',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final text in insights)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: textTheme.bodySmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)),
                  Expanded(
                    child: Text(
                      text,
                      style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryTransactionsCard extends StatelessWidget {
  const _CategoryTransactionsCard({
    required this.detail,
    required this.hideBalance,
    required this.onAddTransaction,
  });

  final CategoryFlowDetail detail;
  final bool hideBalance;
  final VoidCallback onAddTransaction;

  void _showDetailSheet(BuildContext context, CashflowTransaction tx) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final textTheme = Theme.of(ctx).textTheme;
        final fullDate = DateFormat('EEEE, d MMMM yyyy • HH:mm', 'id_ID').format(tx.date);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconBadge(icon: tx.iconData, color: tx.categoryColor),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.title,
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            tx.categoryName,
                            style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Nominal Transaksi',
                  style: textTheme.labelSmall?.copyWith(color: scheme.outline),
                ),
                Text(
                  formatRupiah(tx.amountCents),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tx.isIncome ? AppColors.income : scheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Column(
                    children: [
                      _DetailModalRow(label: 'Dompet / Rekening', value: tx.accountName),
                      const Divider(height: AppSpacing.md),
                      _DetailModalRow(label: 'Waktu Transaksi', value: fullDate),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.tonal(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Riwayat Transaksi',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${detail.transactions.length} transaksi',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (detail.transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.receipt, size: 36, color: scheme.outline),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Belum ada transaksi di bulan ini',
                      style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextButton.icon(
                      onPressed: onAddTransaction,
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text('Tambah Transaksi'),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < detail.transactions.length; i++) ...[
                  if (i > 0) const Divider(height: AppSpacing.sm),
                  _TransactionRow(
                    tx: detail.transactions[i],
                    hideBalance: hideBalance,
                    onTap: () => _showDetailSheet(context, detail.transactions[i]),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.tx,
    required this.hideBalance,
    required this.onTap,
  });

  final CashflowTransaction tx;
  final bool hideBalance;
  final VoidCallback onTap;

  static final _dateTimeFormatter = DateFormat('dd MMM • HH:mm', 'id_ID');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tx.accountName} • ${_dateTimeFormatter.format(tx.date)}',
                    style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              hideBalance
                  ? '••••'
                  : '${tx.isIncome ? "+" : "-"}${formatRupiah(tx.amountCents)}',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: tx.isIncome ? AppColors.income : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailModalRow extends StatelessWidget {
  const _DetailModalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodySmall?.copyWith(color: scheme.outline)),
        Text(value, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
