import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/report_models.dart';

const _weekdayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

/// Month grid for the "Kalender Cashflow" screen: one cell per day, tinted
/// and labeled with that day's net cashflow when it has one, the selected
/// day ringed in the theme accent.
class CashflowCalendarGrid extends StatelessWidget {
  const CashflowCalendarGrid({
    required this.month,
    required this.dailyCashflow,
    required this.selectedDate,
    required this.onSelect,
    super.key,
  });

  final DateTime month;
  final List<DailyCashflow> dailyCashflow;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday;
    final leadingBlanks = firstWeekday - DateTime.monday;
    final byDay = {for (final entry in dailyCashflow) entry.date.day: entry};
    final now = DateTime.now();
    final isCurrentMonth = month.year == now.year && month.month == now.month;

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              for (final label in _weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: textTheme.labelSmall?.copyWith(color: scheme.outline),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: leadingBlanks + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();
              final day = index - leadingBlanks + 1;
              final date = DateTime(month.year, month.month, day);
              final cashflow = byDay[day];
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final isToday =
                  isCurrentMonth && day == now.day;

              return Padding(
                padding: const EdgeInsets.all(2),
                child: _DayCell(
                  day: day,
                  cashflow: cashflow,
                  isSelected: isSelected,
                  isToday: isToday,
                  onTap: () => onSelect(date),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.cashflow,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final int day;
  final DailyCashflow? cashflow;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasData = cashflow != null;
    final net = cashflow?.netCents ?? 0;
    final netColor = net >= 0 ? AppColors.income : AppColors.expense;

    return Material(
      color: hasData ? netColor.withValues(alpha: 0.12) : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: isSelected || isToday
                ? Border.all(
                    color: isSelected ? scheme.primary : scheme.outlineVariant,
                    width: isSelected ? 2 : 1,
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w500,
                  color: hasData ? netColor : null,
                ),
              ),
              if (hasData) ...[
                const SizedBox(height: 1),
                Text(
                  net >= 0
                      ? '+${formatRupiahCompact(net)}'
                      : formatRupiahCompact(net),
                  style: textTheme.labelSmall?.copyWith(
                    color: netColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
