import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';

/// Top-of-dashboard greeting: avatar, time-of-day greeting, level badge,
/// and a notification bell.
class DashboardGreetingHeader extends StatelessWidget {
  const DashboardGreetingHeader({
    required this.displayName,
    required this.levelLabel,
    required this.notificationCount,
    this.onNotificationTap,
    super.key,
  });

  final String displayName;
  final String levelLabel;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InitialsAvatar(name: displayName, radius: 26),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingForNow(),
                style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
              ),
              Text(
                displayName,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.star, size: 14, color: AppColors.badge),
                    const SizedBox(width: AppSpacing.xs),
                    Text(levelLabel, style: textTheme.labelMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
        CircleIconButton(
          icon: LucideIcons.bell,
          onTap: onNotificationTap,
          backgroundColor: scheme.surfaceContainerHighest,
          badgeCount: notificationCount,
        ),
      ],
    );
  }
}
