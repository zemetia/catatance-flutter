import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../theme/app_spacing.dart';
import 'icon_badge.dart';

/// A single row's config within a [MenuSection].
class MenuSectionItem {
  const MenuSectionItem({
    required this.icon,
    required this.label,
    required this.description,
    this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color? iconColor;
  final VoidCallback? onTap;
}

/// A titled group of tappable rows, styled as one rounded card
/// (e.g. profile's "Akun & Keamanan" section, or reports' shortcut list).
class MenuSection extends StatelessWidget {
  const MenuSection({
    this.title,
    required this.items,
    this.delay = Duration.zero,
    super.key,
  });

  final String? title;
  final List<MenuSectionItem> items;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: textTheme.labelLarge?.copyWith(
              color: scheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: Container(
            color: scheme.surfaceContainerHigh,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: AppSpacing.xl + AppSpacing.md,
                      color: scheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  _MenuSectionTile(item: items[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    ).animate(delay: delay).fadeIn(duration: 250.ms).slideY(begin: 0.04, end: 0);
  }
}

class _MenuSectionTile extends StatelessWidget {
  const _MenuSectionTile({required this.item});

  final MenuSectionItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = item.iconColor ?? scheme.primary;

    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconBadge(
              icon: item.icon,
              color: accent,
              size: 18,
              shape: BoxShape.rectangle,
              padding: const EdgeInsets.all(AppSpacing.xs),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(LucideIcons.chevron_right, size: 18, color: scheme.outline),
          ],
        ),
      ),
    );
  }
}
