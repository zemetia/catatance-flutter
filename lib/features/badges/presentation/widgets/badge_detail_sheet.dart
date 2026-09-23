import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/badge_progress.dart';

/// Full detail of one badge — icon, tier, description, progress, and (when
/// unlocked) the date it was earned. Opened by tapping a [BadgeCard].
Future<void> showBadgeDetailSheet(BuildContext context, BadgeProgress progress) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => BadgeDetailSheet(progress: progress),
  );
}

class BadgeDetailSheet extends StatelessWidget {
  const BadgeDetailSheet({required this.progress, super.key});

  final BadgeProgress progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final def = progress.definition;
    final tierColor = def.tier.color;
    final unlocked = progress.isUnlocked;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            IconBadge(
              icon: def.icon,
              color: unlocked ? tierColor : scheme.outline,
              alpha: unlocked ? 0.18 : 0.1,
              size: 36,
              padding: const EdgeInsets.all(AppSpacing.lg),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: tierColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                'Lencana ${def.tier.label}',
                style: textTheme.labelSmall?.copyWith(
                  color: tierColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              def.title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              def.description,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: LinearProgressIndicator(
                value: progress.progressRatio == 0 ? 0.02 : progress.progressRatio,
                minHeight: 8,
                backgroundColor: scheme.outline.withValues(alpha: 0.15),
                color: unlocked ? tierColor : scheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              progress.valueLabel,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  unlocked ? LucideIcons.circle_check_big : LucideIcons.lock,
                  size: 16,
                  color: unlocked ? tierColor : scheme.outline,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  unlocked && progress.unlockedAt != null
                      ? 'Diraih pada ${formatDate(progress.unlockedAt!)}'
                      : 'Belum tercapai — terus catat keuanganmu!',
                  style: textTheme.bodySmall?.copyWith(
                    color: unlocked ? tierColor : scheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
