import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../projection_providers.dart';
import '../report_shimmer_box.dart';

/// "Kurva saldo bulan ini": actual balance so far (solid) continuing into a
/// linear projection to month end (dashed), with a marker for today and a
/// red baseline at zero.
class BalanceCurveChartCard extends ConsumerWidget {
  const BalanceCurveChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projection = ref.watch(monthProjectionProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (projection == null) {
      return const AppCard(child: ReportShimmerBox(width: double.infinity, height: 220));
    }

    final actualSpots = [
      for (final point in projection.curve)
        if (point.actualCents != null)
          FlSpot(point.day.toDouble(), point.actualCents!.toDouble()),
    ];
    final projectedSpots = [
      for (final point in projection.curve)
        if (point.projectedCents != null)
          FlSpot(point.day.toDouble(), point.projectedCents!.toDouble()),
    ];

    final allValues = [...actualSpots, ...projectedSpots, const FlSpot(0, 0)]
        .map((s) => s.y)
        .toList();
    final maxY = allValues.reduce((a, b) => a > b ? a : b);
    final minY = allValues.reduce((a, b) => a < b ? a : b);
    final span = (maxY - minY).abs();
    final pad = span == 0 ? (maxY.abs() * 0.2 + 1) : span * 0.15;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Kurva saldo bulan ini',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _Legend(color: scheme.primary, label: 'Aktual'),
              const SizedBox(width: AppSpacing.md),
              _Legend(color: scheme.primary, label: 'Proyeksi', dashed: true),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: projection.daysInMonth.toDouble(),
                minY: minY - pad,
                maxY: maxY + pad,
                lineTouchData: const LineTouchData(enabled: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: scheme.outlineVariant.withValues(alpha: 0.25),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 58,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: Text(
                          formatRupiahCompact(value.round()),
                          style: textTheme.labelSmall?.copyWith(color: scheme.outline),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (projection.daysInMonth / 4).ceilToDouble(),
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: textTheme.labelSmall?.copyWith(color: scheme.outline),
                      ),
                    ),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  verticalLines: [
                    VerticalLine(
                      x: projection.today.toDouble(),
                      color: scheme.outline.withValues(alpha: 0.4),
                      strokeWidth: 1,
                      dashArray: const [4, 4],
                    ),
                  ],
                  horizontalLines: [
                    if (minY - pad <= 0)
                      HorizontalLine(
                        y: 0,
                        color: AppColors.expense.withValues(alpha: 0.6),
                        strokeWidth: 1,
                        dashArray: const [4, 4],
                      ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: actualSpots,
                    isCurved: true,
                    curveSmoothness: 0.15,
                    color: scheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: scheme.primary.withValues(alpha: 0.14),
                    ),
                  ),
                  LineChartBarData(
                    spots: projectedSpots,
                    isCurved: true,
                    curveSmoothness: 0.15,
                    color: scheme.primary,
                    barWidth: 2,
                    dashArray: const [6, 4],
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, this.dashed = false});

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          color: color.withValues(alpha: dashed ? 0.5 : 1),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
