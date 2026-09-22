import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// An icon inside a soft tinted circle or rounded square — used for stat
/// card icons, suggestion/tip icons, and menu row icons.
class IconBadge extends StatelessWidget {
  const IconBadge({
    required this.icon,
    this.color,
    this.size = 20,
    this.shape = BoxShape.circle,
    this.padding = const EdgeInsets.all(AppSpacing.sm),
    this.alpha = 0.16,
    super.key,
  });

  final IconData icon;
  final Color? color;
  final double size;
  final BoxShape shape;
  final EdgeInsetsGeometry padding;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: alpha),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(AppSpacing.radiusMd)
            : null,
      ),
      child: Icon(icon, size: size, color: accent),
    );
  }
}
