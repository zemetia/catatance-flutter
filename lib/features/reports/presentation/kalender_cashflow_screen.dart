import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import 'kalender_cashflow_providers.dart';
import 'widgets/cashflow_calendar_grid.dart';
import 'widgets/cashflow_day_detail.dart';
import 'widgets/cashflow_legend.dart';
import 'widgets/cashflow_month_nav.dart';
import 'widgets/cashflow_summary_row.dart';

class KalenderCashflowScreen extends ConsumerWidget {
  const KalenderCashflowScreen({super.key});

  void _changeMonth(WidgetRef ref, int delta) {
    final current = ref.read(kalenderCashflowMonthProvider);
    final newMonth = DateTime(current.year, current.month + delta);
    ref.read(kalenderCashflowMonthProvider.notifier).state = newMonth;

    final selected = ref.read(kalenderSelectedDateProvider);
    final daysInNewMonth = DateTime(newMonth.year, newMonth.month + 1, 0).day;
    final clampedDay = selected.day.clamp(1, daysInNewMonth);
    ref.read(kalenderSelectedDateProvider.notifier).state =
        DateTime(newMonth.year, newMonth.month, clampedDay);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(kalenderCashflowMonthProvider);
    final selectedDate = ref.watch(kalenderSelectedDateProvider);
    final dailyCashflow = ref.watch(kalenderMonthCashflowProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kalender Cashflow')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            CashflowMonthNav(
              month: month,
              onPrevious: () => _changeMonth(ref, -1),
              onNext: () => _changeMonth(ref, 1),
            ),
            const SizedBox(height: AppSpacing.md),
            const CashflowSummaryRow(),
            const SizedBox(height: AppSpacing.md),
            dailyCashflow.when(
              data: (entries) => CashflowCalendarGrid(
                month: month,
                dailyCashflow: entries,
                selectedDate: selectedDate,
                onSelect: (date) =>
                    ref.read(kalenderSelectedDateProvider.notifier).state = date,
              ),
              loading: () => CashflowCalendarGrid(
                month: month,
                dailyCashflow: const [],
                selectedDate: selectedDate,
                onSelect: (date) =>
                    ref.read(kalenderSelectedDateProvider.notifier).state = date,
              ),
              error: (err, st) => CashflowCalendarGrid(
                month: month,
                dailyCashflow: const [],
                selectedDate: selectedDate,
                onSelect: (date) =>
                    ref.read(kalenderSelectedDateProvider.notifier).state = date,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const CashflowLegend(),
            const SizedBox(height: AppSpacing.md),
            const CashflowDayDetail(),
          ],
        ),
      ),
    );
  }
}
