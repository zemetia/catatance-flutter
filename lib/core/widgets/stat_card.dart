import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../utils/formatters.dart';
import 'app_card.dart';
import 'icon_badge.dart';

/// Small summary card used on the dashboard (e.g. total balance, income, expense).
class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.amountCents,
    required this.icon,
    this.color,
    this.delay = Duration.zero,
    super.key,
  });

  final String label;
  final int amountCents;
  final IconData icon;
  final Color? color;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = color ?? scheme.primary;

    return AppCard(
      delay: delay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: accent, size: 16),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: 2),
          Text(
            formatRupiah(amountCents),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
