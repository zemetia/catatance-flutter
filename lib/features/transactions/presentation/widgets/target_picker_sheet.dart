import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../savings_goals/domain/savings_goal.dart';

/// Bottom sheet letting the user link an income transaction to a savings
/// goal ("Target"). Returns the selected [SavingsGoal], or `null` for
/// "Tidak ada" (no target) — tapping outside to dismiss also resolves to
/// `null`, same as explicitly picking "Tidak ada", so the caller should
/// always apply the result rather than ignore a `null` return.
Future<SavingsGoal?> showTargetPickerSheet(
  BuildContext context, {
  required List<SavingsGoal> goals,
  required SavingsGoal? selected,
}) {
  return showModalBottomSheet<SavingsGoal?>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _TargetPickerSheet(
      goals: goals,
      selected: selected,
    ),
  );
}

class _TargetPickerSheet extends StatelessWidget {
  const _TargetPickerSheet({
    required this.goals,
    required this.selected,
  });

  final List<SavingsGoal> goals;
  final SavingsGoal? selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan ke Target Tabungan?',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              'Pemasukan ini juga akan menambah saldo target yang dipilih.',
              style: textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
            const SizedBox(height: AppSpacing.md),
            _TargetOption(
              icon: LucideIcons.ban,
              iconColor: scheme.outline,
              title: 'Tidak ada',
              subtitle: 'Pemasukan biasa, tanpa target',
              selected: selected == null,
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (goals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  'Belum ada target tabungan.',
                  style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
              )
            else
              for (final goal in goals) ...[
                _TargetOption(
                  icon: goal.iconOption.iconData,
                  iconColor: goal.gradient.colors.first,
                  title: goal.name,
                  subtitle: '${goal.formattedCurrent} / ${goal.formattedTarget}',
                  selected: goal.id == selected?.id,
                  onTap: () => Navigator.of(context).pop(goal),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/savings-goals');
                },
                icon: const Icon(LucideIcons.target, size: 16),
                label: const Text('Kelola target tabungan'),
                style: TextButton.styleFrom(foregroundColor: scheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetOption extends StatelessWidget {
  const _TargetOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: selected ? iconColor.withValues(alpha: 0.14) : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: selected ? iconColor : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: iconColor.withValues(alpha: 0.18),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                    ),
                  ],
                ),
              ),
              if (selected) Icon(LucideIcons.circle_check, color: iconColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
