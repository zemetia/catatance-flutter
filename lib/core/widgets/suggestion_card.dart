import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../theme/app_spacing.dart';
import 'app_card.dart';
import 'decorative_circle.dart';
import 'icon_badge.dart';

/// "Saran untukmu" style card: an icon tile, title, description, and a
/// chevron affordance, with a soft decorative circle in the background.
class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    this.onTap,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      delay: 80.ms,
      backgroundLayers: const [
        Positioned(right: -24, top: -24, child: DecorativeCircle(size: 96, alpha: 0.10)),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, shape: BoxShape.rectangle),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: textTheme.labelMedium?.copyWith(color: scheme.outline),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevron_right, size: 18, color: scheme.outline),
        ],
      ),
    );
  }
}
