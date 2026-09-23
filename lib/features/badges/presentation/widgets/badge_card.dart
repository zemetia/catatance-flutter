import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/badge_progress.dart';

/// One tile in the Lencana grid — tier-colored icon when unlocked, a dimmed
/// lock state with a thin progress bar underneath when not.
class BadgeCard extends StatelessWidget {
  const BadgeCard({
    required this.progress,
    this.onTap,
    this.delay = Duration.zero,
    super.key,
  });

  final BadgeProgress progress;
  final VoidCallback? onTap;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final def = progress.definition;
    final tierColor = def.tier.color;
    final unlocked = progress.isUnlocked;

    return AppCard(
      delay: delay,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconBadge(
                icon: def.icon,
                color: unlocked ? tierColor : scheme.outline,
                alpha: unlocked ? 0.18 : 0.1,
                size: 26,
                padding: const EdgeInsets.all(AppSpacing.md),
              ),
              if (!unlocked)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.surface, width: 2),
                    ),
                    child: Icon(
                      LucideIcons.lock,
                      size: 11,
                      color: scheme.outline,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            def.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: unlocked ? scheme.onSurface : scheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: LinearProgressIndicator(
              value: progress.progressRatio == 0
                  ? 0.02
                  : progress.progressRatio,
              minHeight: 5,
              backgroundColor: scheme.outline.withValues(alpha: 0.15),
              color: unlocked ? tierColor : scheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            unlocked ? 'Diraih' : '${progress.progressPercent}%',
            style: textTheme.bodySmall?.copyWith(
              color: unlocked ? tierColor : scheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate(delay: delay).scaleXY(begin: 0.94, end: 1, duration: 200.ms);
  }
}
