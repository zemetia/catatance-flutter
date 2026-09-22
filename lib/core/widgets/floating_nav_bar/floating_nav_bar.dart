import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../theme/app_spacing.dart';

/// A destination shown in [FloatingNavBar], excluding the center action button.
class FloatingNavItem {
  const FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Modern floating bottom navigation bar with a raised center action button
/// (used for the "add transaction" shortcut).
///
/// Renders as a frosted-glass pill fixed a fixed distance above the screen's
/// bottom edge (never flush against it), with a circular accent button
/// overlapping its top edge in the middle.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    required this.items,
    required this.currentIndex,
    required this.onItemSelected,
    required this.onCenterActionPressed,
    super.key,
  });

  final List<FloatingNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onCenterActionPressed;

  static const double _barHeight = 74;
  static const double _fabSize = 64;
  // How far the center button pokes above the bar's top edge — kept under
  // half of [_fabSize] so most of the button sits embedded in the bar
  // instead of floating high above it.
  static const double _fabPokeAbove = 22;
  static const double _radius = 28;
  static const double _bottomGap = AppSpacing.xl;

  /// Bottom padding a screen under the shell should reserve so its scrollable
  /// content isn't hidden behind this bar (and shows through its glass blur
  /// instead of leaving a flat gap).
  static const double clearance = _bottomGap + _barHeight + AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final half = items.length ~/ 2;
    final leftItems = items.sublist(0, half);
    final rightItems = items.sublist(half);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: _bottomGap),
      child: SizedBox(
        height: _barHeight + _fabPokeAbove,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_radius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    height: _barHeight,
                    decoration: BoxDecoration(
                      color: (isDark ? scheme.surfaceContainerHigh : scheme.surface)
                          .withValues(alpha: isDark ? 0.38 : 0.55),
                      borderRadius: BorderRadius.circular(_radius),
                      border: Border.all(
                        color: (isDark ? Colors.white : scheme.outline)
                            .withValues(alpha: isDark ? 0.2 : 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.shadow.withValues(alpha: 0.18),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        for (final item in leftItems)
                          _NavButton(
                            item: item,
                            selected: items.indexOf(item) == currentIndex,
                            onTap: () => onItemSelected(items.indexOf(item)),
                          ),
                        const SizedBox(width: _fabSize),
                        for (final item in rightItems)
                          _NavButton(
                            item: item,
                            selected: items.indexOf(item) == currentIndex,
                            onTap: () => onItemSelected(items.indexOf(item)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: _barHeight - _fabSize + _fabPokeAbove,
              child: _CenterActionButton(onPressed: onCenterActionPressed),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final FloatingNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: 180.ms,
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primary.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Icon(
                selected ? item.activeIcon : item.icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterActionButton extends StatelessWidget {
  const _CenterActionButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: FloatingNavBar._fabSize,
      height: FloatingNavBar._fabSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primary,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(LucideIcons.plus, color: scheme.onPrimary, size: 30),
        ),
      ),
    ).animate().scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1, 1),
      duration: 220.ms,
      curve: Curves.easeOutBack,
    );
  }
}
