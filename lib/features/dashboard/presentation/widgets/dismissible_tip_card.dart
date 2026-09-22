import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';

/// A closeable tip/nudge card shown under the "Untukmu" section.
class DismissibleTipCard extends StatelessWidget {
  const DismissibleTipCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onDismiss,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      border: Border.all(color: scheme.outlineVariant),
      delay: 160.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: icon, color: scheme.tertiary, shape: BoxShape.rectangle),
              const Spacer(),
              CircleIconButton(
                icon: LucideIcons.x,
                onTap: onDismiss,
                size: 18,
                padding: const EdgeInsets.all(AppSpacing.xs),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
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
    );
  }
}
