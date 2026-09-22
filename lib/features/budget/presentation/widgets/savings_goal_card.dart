import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../budget_providers.dart';

/// A gradient hero banner (icon + progress %) over a footer with the goal's
/// name, saved-of-target amount, and a thin overall progress bar.
class SavingsGoalCard extends StatelessWidget {
  const SavingsGoalCard({
    required this.goal,
    required this.gradient,
    this.delay = Duration.zero,
    this.onTap,
    super.key,
  });

  final SavingsGoalItem goal;
  final Gradient gradient;
  final Duration delay;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = goal.progress;

    return AppCard(
      delay: delay,
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 110,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
                Positioned(
                  left: AppSpacing.md,
                  top: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(goal.icon, size: 20, color: Colors.white),
                  ),
                ),
                Positioned(
                  right: AppSpacing.md,
                  top: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Text(
                      '${(progress * 100).round()}%',
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    goal.name,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${formatRupiahCompact(goal.savedCents)} of ${formatRupiahCompact(goal.targetCents)}',
                  style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: LinearProgressIndicator(
                value: progress == 0 ? 0.02 : progress,
                minHeight: 4,
                backgroundColor: scheme.outline.withValues(alpha: 0.15),
                color: scheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
