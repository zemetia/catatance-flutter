import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../theme/app_spacing.dart';
import '../floating_nav_bar/floating_nav_bar.dart';
import 'smooth_scroll_controller.dart';

/// A floating, animated frosted-glass pill that appears when the user
/// scrolls down and allows 1-tap smooth scrolling back to top.
class AnimatedScrollToTopPill extends StatefulWidget {
  const AnimatedScrollToTopPill({
    required this.controller,
    this.threshold = 260.0,
    this.bottomPadding = FloatingNavBar.clearance,
    this.label = 'Ke Atas',
    this.showLabel = true,
    super.key,
  });

  final ScrollController controller;
  final double threshold;
  final double bottomPadding;
  final String label;
  final bool showLabel;

  @override
  State<AnimatedScrollToTopPill> createState() => _AnimatedScrollToTopPillState();
}

class _AnimatedScrollToTopPillState extends State<AnimatedScrollToTopPill> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_checkScroll);
  }

  @override
  void didUpdateWidget(covariant AnimatedScrollToTopPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_checkScroll);
      widget.controller.addListener(_checkScroll);
      _checkScroll();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_checkScroll);
    super.dispose();
  }

  void _checkScroll() {
    if (!widget.controller.hasClients) return;
    final visible = widget.controller.offset > widget.threshold;
    if (_isVisible != visible) {
      setState(() => _isVisible = visible);
    }
  }

  void _scrollToTop() {
    widget.controller.smoothScrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom: widget.bottomPadding,
      left: 0,
      right: 0,
      child: Center(
        child: IgnorePointer(
          ignoring: !_isVisible,
          child: AnimatedSlide(
            offset: _isVisible ? Offset.zero : const Offset(0, 0.75),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: _isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _scrollToTop,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.showLabel ? AppSpacing.md : AppSpacing.sm,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? scheme.surfaceContainerHigh
                                  : scheme.surface)
                              .withValues(alpha: isDark ? 0.75 : 0.85),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusXl),
                          border: Border.all(
                            color: (isDark ? Colors.white : scheme.outline)
                                .withValues(alpha: isDark ? 0.16 : 0.24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.shadow.withValues(alpha: 0.14),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.arrow_up,
                              size: 16,
                              color: scheme.primary,
                            ),
                            if (widget.showLabel) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                widget.label,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: scheme.onSurface,
                                      letterSpacing: 0.2,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
