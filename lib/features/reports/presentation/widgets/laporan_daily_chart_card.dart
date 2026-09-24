import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/report_models.dart';
import '../laporan_bulanan_providers.dart';
import 'report_shimmer_box.dart';

/// "Belanja harian" card: one thin bar per day of the selected month (sparse
/// — most days are 0), the month's average-per-day in the header, and two
/// stat lines below the chart ("Hari belanja"/"Hari terboros").
class LaporanDailyChartCard extends ConsumerWidget {
  const LaporanDailyChartCard({super.key});

  static const _chartHeight = 120.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daily = ref.watch(laporanDailySpendingProvider);
    final month = ref.watch(laporanBulananMonthProvider);
    final mode = ref.watch(laporanBulananModeProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Belanja harian',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              daily.when(
                data: (days) {
                  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
                  final total = days.fold<int>(0, (sum, d) => sum + d.totalCents.abs());
                  final avg = daysInMonth == 0 ? 0 : total ~/ daysInMonth;
                  return Text(
                    'Rata-rata/hari ${formatRupiahCompact(avg)}',
                    style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                  );
                },
                loading: () => const ReportShimmerBox(width: 80, height: 14),
                error: (err, st) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          daily.when(
            data: (days) => _DailyChartBody(days: days, month: month, mode: mode),
            loading: () => const SizedBox(
              height: _chartHeight,
              child: Center(child: ReportShimmerBox(width: 220, height: 80)),
            ),
            error: (err, st) => SizedBox(
              height: _chartHeight,
              child: Center(
                child: Text(
                  'Gagal memuat data',
                  style: textTheme.bodySmall?.copyWith(color: scheme.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyChartBody extends StatelessWidget {
  const _DailyChartBody({required this.days, required this.month, required this.mode});

  final List<DailySpending> days;
  final DateTime month;
  final ReportMode mode;

  static const _chartHeight = 120.0;
  static const _labelDays = [1, 5, 10, 15, 20, 25];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final barColor = mode == ReportMode.income ? AppColors.income : scheme.primary;

    final totals = List<int>.filled(daysInMonth, 0);
    for (final day in days) {
      totals[day.date.day - 1] = day.totalCents.abs();
    }
    final maxValue = totals.fold<int>(0, (m, v) => v > m ? v : m);
    final busiestIndex = maxValue == 0 ? -1 : totals.indexOf(maxValue);
    final daysWithActivity = totals.where((v) => v > 0).length;
    final labelDays = {..._labelDays, daysInMonth};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < daysInMonth; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: FractionallySizedBox(
                      alignment: Alignment.bottomCenter,
                      heightFactor: maxValue == 0 ? 0.02 : (totals[i] / maxValue).clamp(0.02, 1.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: totals[i] > 0
                              ? barColor
                              : scheme.outline.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            for (var i = 0; i < daysInMonth; i++)
              Expanded(
                child: labelDays.contains(i + 1)
                    ? Text(
                        '${i + 1}',
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall?.copyWith(color: scheme.outline),
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _StatLine(
                label: 'Hari belanja',
                value: '$daysWithActivity/$daysInMonth',
              ),
            ),
            Expanded(
              child: _StatLine(
                label: 'Hari terboros',
                value: busiestIndex < 0
                    ? '—'
                    : '${busiestIndex + 1} • ${formatRupiahCompact(maxValue)}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall?.copyWith(color: scheme.outline)),
        const SizedBox(height: 2),
        Text(value, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
