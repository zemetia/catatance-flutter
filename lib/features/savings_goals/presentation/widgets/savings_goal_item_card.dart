import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/savings_goal.dart';

/// Card rendering a saved target with gradient header, watermark, and progress info.
class SavingsGoalItemCard extends StatelessWidget {
  const SavingsGoalItemCard({
    required this.goal,
    this.delay = Duration.zero,
    this.onTap,
    this.onDeposit,
    super.key,
  });

  final SavingsGoal goal;
  final Duration delay;
  final VoidCallback? onTap;
  final VoidCallback? onDeposit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = goal.progress;
    final iconOption = goal.iconOption;

    return AppCard(
      delay: delay,
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner with gradient, watermark, icon badge, and progress pill
          SizedBox(
            height: 105,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: goal.gradient,
                  ),
                ),
                // Subtle watermark
                Positioned(
                  right: -10,
                  bottom: -15,
                  child: Transform.rotate(
                    angle: -0.22,
                    child: Opacity(
                      opacity: 0.2,
                      child: Icon(
                        iconOption.iconData,
                        size: 95,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Icon badge in circular translucent frame
                Positioned(
                  left: AppSpacing.md,
                  top: AppSpacing.md,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      iconOption.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                // Progress percent pill
                Positioned(
                  right: AppSpacing.md,
                  top: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Text(
                      goal.progressPercentage,
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // Autosave chip if enabled
                if (goal.autoSaveEnabled && goal.autoSaveAmountCents > 0)
                  Positioned(
                    left: AppSpacing.md,
                    bottom: AppSpacing.xs,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.zap,
                            size: 11,
                            color: Color(0xFFC6FF3D),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            goal.autoSaveSummary,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFC6FF3D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content footer
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        goal.deadlineLabel,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.outline,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${formatRupiahCompact(goal.currentAmountCents)} of ${formatRupiahCompact(goal.targetAmountCents)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Progress line
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: LinearProgressIndicator(
                value: progress == 0 ? 0.02 : progress,
                minHeight: 6,
                backgroundColor: scheme.outline.withValues(alpha: 0.15),
                color: goal.gradient.colors.first,
              ),
            ),
          ),
          // Sub-footer: remaining amount & quick action
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              2,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.isAchieved
                        ? '🎉 Target Tercapai Penuh!'
                        : 'Kurang ${formatRupiahCompact(goal.remainingCents)} • ${goal.deadlineStatusLabel}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: goal.isAchieved ? scheme.primary : scheme.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onDeposit != null && !goal.isAchieved)
                  InkWell(
                    onTap: onDeposit,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.plus,
                            size: 13,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Nabung',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
