import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/report_models.dart';
import '../reports_providers.dart';
import 'report_bar_column.dart';
import 'report_shimmer_box.dart';

/// "Total belanja" card: a 7-day expense bar chart, ending today (or the
/// last day of the selected month, for a past month).
class ExpenseBarChartCard extends ConsumerWidget {
  const ExpenseBarChartCard({super.key});

  static const _chartHeight = 160.0;
  static const _barMaxHeight = 110.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daily = ref.watch(dailyExpenseProvider);
    final total = ref.watch(weeklyExpenseTotalProvider);
    final month = ref.watch(selectedReportMonthProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      delay: 40.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Total belanja',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text('  •  ', style: textTheme.titleMedium?.copyWith(color: scheme.outline)),
              total.when(
                data: (value) => Text(
                  formatRupiahCompact(value),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
                loading: () => const ReportShimmerBox(width: 64, height: 18),
                error: (err, st) => Text('—', style: textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          daily.when(
            data: (days) => _WeekBars(days: days, referenceMonth: month),
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

class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.days, required this.referenceMonth});

  final List<DailySpending> days;
  final DateTime referenceMonth;

  static const _weekdayInitials = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth =
        referenceMonth.year == now.year && referenceMonth.month == now.month;
    final end = isCurrentMonth
        ? DateTime(now.year, now.month, now.day)
        : DateTime(referenceMonth.year, referenceMonth.month + 1, 0);
    final weekDates = [for (var i = 6; i >= 0; i--) end.subtract(Duration(days: i))];

    final totalsByDay = {for (final d in days) d.date: d.totalCents};
    final maxTotal = totalsByDay.values.fold<int>(0, (m, v) => v > m ? v : m);

    return SizedBox(
      height: ExpenseBarChartCard._chartHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final date in weekDates)
            Expanded(
              child: Builder(
                builder: (context) {
                  final key = DateTime(date.year, date.month, date.day);
                  final value = totalsByDay[key] ?? 0;
                  return ReportBarColumn(
                    valueLabel: formatRupiahCompact(value),
                    axisLabel: _weekdayInitials[date.weekday - 1],
                    heightFraction: maxTotal == 0 ? 0 : value / maxTotal,
                    highlighted: value > 0,
                    maxBarHeight: ExpenseBarChartCard._barMaxHeight,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
