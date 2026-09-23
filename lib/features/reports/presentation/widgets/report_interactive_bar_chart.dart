import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';

/// One labeled value plotted by [ReportInteractiveBarChart].
class ReportBarDatum {
  const ReportBarDatum({required this.axisLabel, required this.value, this.color});

  final String axisLabel;
  final int value;

  /// Overrides the default `scheme.primary` rod color — e.g. to distinguish
  /// a negative net-total bar.
  final Color? color;
}

/// A touch-interactive bar chart (used by the weekly expense and monthly
/// trend cards): bars carry no permanent value label — the amount only
/// appears in a tooltip after a bar is tapped, and stays until it (or
/// another bar) is tapped again.
class ReportInteractiveBarChart extends StatefulWidget {
  const ReportInteractiveBarChart({required this.data, required this.height, super.key});

  final List<ReportBarDatum> data;
  final double height;

  @override
  State<ReportInteractiveBarChart> createState() => _ReportInteractiveBarChartState();
}

class _ReportInteractiveBarChartState extends State<ReportInteractiveBarChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final data = widget.data;
    final maxMagnitude = data.fold<int>(0, (m, d) => d.value.abs() > m ? d.value.abs() : m);
    final hasNegative = data.any((d) => d.value < 0);
    final ceiling = maxMagnitude == 0 ? 1.0 : maxMagnitude * 1.25;

    return SizedBox(
      height: widget.height,
      child: BarChart(
        duration: const Duration(milliseconds: 250),
        BarChartData(
          minY: hasNegative ? -ceiling : 0,
          maxY: ceiling,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              tooltipBorderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final datum = data[group.x];
                return BarTooltipItem(
                  '${datum.axisLabel}\n',
                  textTheme.labelSmall!.copyWith(
                    color: scheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: formatRupiahCompact(datum.value),
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.onInverseSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                );
              },
            ),
            touchCallback: (event, response) {
              if (event is! FlTapUpEvent) return;
              final index = response?.spot?.touchedBarGroupIndex;
              setState(() => _touchedIndex = index == _touchedIndex ? null : index);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    space: AppSpacing.xs,
                    child: Text(
                      data[index].axisLabel,
                      style: textTheme.labelSmall?.copyWith(color: scheme.outline),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].value.toDouble(),
                    width: 20,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    color: (data[i].color ?? scheme.primary).withValues(
                      alpha: data[i].value == 0
                          ? 0.25
                          : (_touchedIndex == i ? 1 : 0.85),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
