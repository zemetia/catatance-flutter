import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// A tappable circular icon button, optionally on a tinted background and
/// optionally showing a small numeric badge (e.g. unread notifications).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    required this.icon,
    this.onTap,
    this.size = 20,
    this.padding = const EdgeInsets.all(AppSpacing.sm),
    this.backgroundColor,
    this.badgeCount = 0,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final button = Material(
      color: backgroundColor ?? Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Icon(icon, size: size, color: scheme.onSurface),
        ),
      ),
    );

    if (badgeCount <= 0) return button;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: scheme.error,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.surface, width: 2),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              '$badgeCount',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: scheme.onError,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
