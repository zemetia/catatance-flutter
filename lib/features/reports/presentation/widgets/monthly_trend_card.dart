import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/report_models.dart';
import '../reports_providers.dart';
import 'report_interactive_bar_chart.dart';
import 'report_shimmer_box.dart';

/// "Tren 5 bulan" card: an interactive bar chart of the total per month
/// (expense, income, or net) for the 5 months ending at the selected month.
/// Each bar's amount only appears in a tooltip after it is tapped.
class MonthlyTrendCard extends ConsumerWidget {
  const MonthlyTrendCard({super.key});

  static const _chartHeight = 170.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trend = ref.watch(monthlyTrendProvider);
    final mode = ref.watch(selectedReportModeProvider);
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
            data: (months) => ReportInteractiveBarChart(
              height: _chartHeight,
              data: [
                for (final month in months)
                  ReportBarDatum(
                    axisLabel: DateFormat('MMM', 'id_ID').format(month.month),
                    value: month.totalCents,
                    color: mode == ReportMode.net
                        ? (month.totalCents < 0 ? AppColors.expense : AppColors.income)
                        : null,
                  ),
              ],
            ),
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
