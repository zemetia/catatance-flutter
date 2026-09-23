import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/report_models.dart';

/// A 3-way segmented switch for the statistics screen: Pengeluaran (expense),
/// Pemasukan (income), or Bersih (net = income − expense).
class ReportModeSwitch extends StatelessWidget {
  const ReportModeSwitch({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final ReportMode selected;
  final ValueChanged<ReportMode> onChanged;

  Color _colorFor(ReportMode mode, ColorScheme scheme) => switch (mode) {
    ReportMode.expense => AppColors.expense,
    ReportMode.income => AppColors.income,
    ReportMode.net => scheme.primary,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          for (final mode in ReportMode.values)
            Expanded(
              child: _ModeItem(
                label: mode.label,
                isSelected: mode == selected,
                activeColor: _colorFor(mode, scheme),
                onTap: () => onChanged(mode),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeItem extends StatelessWidget {
  const _ModeItem({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color activeColor;
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
            color: isSelected
                ? activeColor.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: isSelected
                ? Border.all(color: activeColor.withValues(alpha: 0.4), width: 1.2)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
