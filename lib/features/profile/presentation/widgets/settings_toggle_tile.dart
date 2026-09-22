import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';

/// A single labelled switch row, styled to match [MenuSection]'s rows —
/// used by the settings screens (Notifikasi, Keamanan, ...) that need a
/// toggle instead of a chevron-to-another-screen tap target.
class SettingsToggleTile extends StatelessWidget {
  const SettingsToggleTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconBadge(
            icon: icon,
            color: scheme.primary,
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
                  label,
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.85),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: scheme.primary,
            activeTrackColor: scheme.primary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

/// A titled group of [SettingsToggleTile]s, styled as one rounded card
/// (same container language as [MenuSection]).
class SettingsToggleSection extends StatelessWidget {
  const SettingsToggleSection({
    this.title,
    required this.children,
    super.key,
  });

  final String? title;
  final List<Widget> children;

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
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: AppSpacing.xl + AppSpacing.md,
                      color: scheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable "empty chevron row" for a static info screen (About, Help, ...)
/// that just opens a URL/dialog with no persistent state behind it.
class SettingsLinkTile extends StatelessWidget {
  const SettingsLinkTile({
    required this.icon,
    required this.label,
    this.trailingText,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? trailingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            IconBadge(
              icon: icon,
              color: scheme.primary,
              size: 18,
              shape: BoxShape.rectangle,
              padding: const EdgeInsets.all(AppSpacing.xs),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: textTheme.bodySmall?.copyWith(color: scheme.outline),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            if (onTap != null)
              Icon(LucideIcons.chevron_right, size: 18, color: scheme.outline),
          ],
        ),
      ),
    );
  }
}
