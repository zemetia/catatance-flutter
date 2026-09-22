import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/report_models.dart';
import '../reports_providers.dart';
import 'report_bar_column.dart';
import 'report_shimmer_box.dart';

/// "Tren 5 bulan" card: total expense per month for the 5 months ending at
/// the selected month.
class MonthlyTrendCard extends ConsumerWidget {
  const MonthlyTrendCard({super.key});

  static const _chartHeight = 170.0;
  static const _barMaxHeight = 110.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trend = ref.watch(monthlyTrendProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      delay: 160.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tren 5 bulan', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.lg),
          trend.when(
            data: (months) => _TrendBars(months: months),
            loading: () => const SizedBox(
              height: _chartHeight,
              child: Center(child: ReportShimmerBox(width: 220, height: 100)),
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

class _TrendBars extends StatelessWidget {
  const _TrendBars({required this.months});

  final List<MonthlySpending> months;

  @override
  Widget build(BuildContext context) {
    final maxTotal = months.fold<int>(0, (m, v) => v.totalCents > m ? v.totalCents : m);

    return SizedBox(
      height: MonthlyTrendCard._chartHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final month in months)
            Expanded(
              child: ReportBarColumn(
                valueLabel: formatRupiahCompact(month.totalCents),
                axisLabel: DateFormat('MMM', 'id_ID').format(month.month),
                heightFraction: maxTotal == 0 ? 0 : month.totalCents / maxTotal,
                highlighted: month.totalCents > 0,
                maxBarHeight: MonthlyTrendCard._barMaxHeight,
              ),
            ),
        ],
      ),
    );
  }
}
