import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/security/security_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/report_models.dart';
import '../reports_providers.dart';
import 'report_interactive_bar_chart.dart';
import 'report_shimmer_box.dart';

/// "Total belanja" card: a 7-day interactive bar chart (expense, income, or
/// net), ending today (or the last day of the selected month, for a past
/// month). The header total stays masked until held or tapped.
class ExpenseBarChartCard extends ConsumerWidget {
  const ExpenseBarChartCard({super.key});

  static const _chartHeight = 160.0;

  String _titleFor(ReportMode mode) => switch (mode) {
    ReportMode.expense => 'Total belanja',
    ReportMode.income => 'Total pemasukan',
    ReportMode.net => 'Arus kas bersih',
  };

  Color _totalColorFor(ReportMode mode, int value, ColorScheme scheme) =>
      switch (mode) {
        ReportMode.expense => scheme.primary,
        ReportMode.income => scheme.primary,
        ReportMode.net => value < 0 ? AppColors.expense : AppColors.income,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daily = ref.watch(dailySpendingProvider);
    final total = ref.watch(weeklyTotalProvider);
    final month = ref.watch(selectedReportMonthProvider);
    final mode = ref.watch(selectedReportModeProvider);
    final hideBalance = ref.watch(hideBalanceProvider);
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
                _titleFor(mode),
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text('  •  ', style: textTheme.titleMedium?.copyWith(color: scheme.outline)),
              total.when(
                data: (value) => hideBalance
                    ? HoldToReveal(
                        builder: (context, revealed) => Text(
                          revealed ? formatRupiahCompact(value) : '••••••',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: revealed
                                ? _totalColorFor(mode, value, scheme)
                                : scheme.outline,
                          ),
                        ),
                      )
                    : Text(
                        formatRupiahCompact(value),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _totalColorFor(mode, value, scheme),
                        ),
                      ),
                loading: () => const ReportShimmerBox(width: 64, height: 18),
                error: (err, st) => Text('—', style: textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          daily.when(
            data: (days) => ReportInteractiveBarChart(
              height: _chartHeight,
              data: _weekData(days: days, referenceMonth: month, mode: mode),
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

  static const _weekdayInitials = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

  List<ReportBarDatum> _weekData({
    required List<DailySpending> days,
    required DateTime referenceMonth,
    required ReportMode mode,
  }) {
    final now = DateTime.now();
    final isCurrentMonth =
        referenceMonth.year == now.year && referenceMonth.month == now.month;
    final end = isCurrentMonth
        ? DateTime(now.year, now.month, now.day)
        : DateTime(referenceMonth.year, referenceMonth.month + 1, 0);
    final weekDates = [for (var i = 6; i >= 0; i--) end.subtract(Duration(days: i))];

    final totalsByDay = {for (final d in days) d.date: d.totalCents};

    return [
      for (final date in weekDates)
        ReportBarDatum(
          axisLabel: _weekdayInitials[date.weekday - 1],
          value: totalsByDay[DateTime(date.year, date.month, date.day)] ?? 0,
          color: mode == ReportMode.net
              ? ((totalsByDay[DateTime(date.year, date.month, date.day)] ?? 0) < 0
                    ? AppColors.expense
                    : AppColors.income)
              : null,
        ),
    ];
  }
}
