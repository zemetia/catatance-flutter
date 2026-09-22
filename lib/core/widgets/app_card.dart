import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_spacing.dart';

/// Shared rounded surface for dashboard/profile-style cards: consistent
/// radius and background, an optional tap ripple, optional background
/// layers (e.g. [DecorativeCircle]s) behind the content, and a shared
/// fade/slide entrance animation.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.border,
    this.backgroundLayers = const [],
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BoxBorder? border;
  final List<Widget> backgroundLayers;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: Container(
        decoration: BoxDecoration(border: border),
        child: Material(
          color: color ?? scheme.surfaceContainerHigh,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                ...backgroundLayers,
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: delay).fadeIn(duration: 250.ms).slideY(begin: 0.06, end: 0);
  }
}
