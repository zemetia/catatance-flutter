import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_card.dart';
import 'icon_badge.dart';

/// Friendly "nothing here yet" placeholder used by any list-backed section
/// (budgets, savings goals, wallets, ...) before the user has added items.
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    required this.icon,
    required this.title,
    required this.description,
    this.delay = Duration.zero,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      delay: delay,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          IconBadge(
            icon: icon,
            size: 32,
            padding: const EdgeInsets.all(AppSpacing.md),
            alpha: 0.12,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}
