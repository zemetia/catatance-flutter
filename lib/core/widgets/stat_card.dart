import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../utils/formatters.dart';
import 'app_card.dart';
import 'decorative_circle.dart';
import 'icon_badge.dart';

/// Small summary card used on the dashboard (e.g. total balance, income, expense).
class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.amountCents,
    required this.icon,
    this.color,
    this.delay = Duration.zero,
    this.compact = false,
    super.key,
  });

  final String label;
  final int amountCents;
  final IconData icon;
  final Color? color;
  final Duration delay;

  /// Uses abbreviated formatting (e.g. `Rp22,8jt`) instead of the full
  /// `Rp22.800.000` for tight layouts.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = color ?? scheme.primary;

    return AppCard(
      delay: delay,
      color: accent.withValues(alpha: 0.08),
      backgroundLayers: [
        Positioned(
          right: -22,
          bottom: -22,
          child: DecorativeCircle(size: 84, color: accent, alpha: 0.14),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: accent, size: 16, shape: BoxShape.rectangle),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: 2),
          Text(
            compact ? formatRupiahCompact(amountCents) : formatRupiah(amountCents),
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
