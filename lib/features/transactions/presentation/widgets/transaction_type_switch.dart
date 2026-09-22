import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// A segmented switch allowing the user to toggle between
/// "Pengeluaran" (Expense) and "Pemasukan" (Income).
class TransactionTypeSwitch extends StatelessWidget {
  const TransactionTypeSwitch({
    required this.isExpense,
    required this.onChanged,
    super.key,
  });

  final bool isExpense;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SwitchItem(
              label: 'Pengeluaran',
              icon: LucideIcons.arrow_up_right,
              isSelected: isExpense,
              activeColor: AppColors.expense,
              activeBackgroundColor: AppColors.expense.withValues(alpha: 0.16),
              onTap: () => onChanged(true),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _SwitchItem(
              label: 'Pemasukan',
              icon: LucideIcons.arrow_down_left,
              isSelected: !isExpense,
              activeColor: AppColors.income,
              activeBackgroundColor: AppColors.income.withValues(alpha: 0.18),
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchItem extends StatelessWidget {
  const _SwitchItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.activeBackgroundColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final Color activeBackgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: AnimatedContainer(
          duration: 200.ms,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected ? activeBackgroundColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: isSelected
                ? Border.all(color: activeColor.withValues(alpha: 0.4), width: 1.2)
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? activeColor : scheme.outline,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
