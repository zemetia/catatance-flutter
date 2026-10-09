import 'package:flutter/material.dart';

import '../floating_nav_bar/floating_nav_bar.dart';
import 'animated_scroll_to_top_pill.dart';
import 'smooth_scroll_physics.dart';

/// A drop-in smooth scrollable list with built-in [SmoothScrollPhysics],
/// optional pull-to-refresh, and an animated [AnimatedScrollToTopPill].
class SmoothListView extends StatefulWidget {
  const SmoothListView({
    required List<Widget> this.children,
    this.controller,
    this.padding,
    this.physics,
    this.showScrollToTop = true,
    this.scrollToTopThreshold = 260.0,
    this.scrollToTopBottomPadding = FloatingNavBar.clearance,
    this.onRefresh,
    super.key,
  })  : itemBuilder = null,
        itemCount = null;

  const SmoothListView.builder({
    required NullableIndexedWidgetBuilder this.itemBuilder,
    required int this.itemCount,
    this.controller,
    this.padding,
    this.physics,
    this.showScrollToTop = true,
    this.scrollToTopThreshold = 260.0,
    this.scrollToTopBottomPadding = FloatingNavBar.clearance,
    this.onRefresh,
    super.key,
  }) : children = null;

  final List<Widget>? children;
  final NullableIndexedWidgetBuilder? itemBuilder;
  final int? itemCount;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool showScrollToTop;
  final double scrollToTopThreshold;
  final double scrollToTopBottomPadding;
  final RefreshCallback? onRefresh;

  @override
  State<SmoothListView> createState() => _SmoothListViewState();
}

class _SmoothListViewState extends State<SmoothListView> {
  ScrollController? _internalController;

  ScrollController get _effectiveController =>
      widget.controller ?? (_internalController ??= ScrollController());

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollPhysics = widget.physics ?? const SmoothScrollPhysics();

    Widget listView;
    if (widget.itemBuilder != null) {
      listView = ListView.builder(
        controller: _effectiveController,
        physics: scrollPhysics,
        padding: widget.padding,
        itemCount: widget.itemCount,
        itemBuilder: widget.itemBuilder!,
      );
    } else {
      listView = ListView(
        controller: _effectiveController,
        physics: scrollPhysics,
        padding: widget.padding,
        children: widget.children ?? const [],
      );
    }

    if (widget.onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listView,
      );
    }

    if (!widget.showScrollToTop) {
      return listView;
    }

    return Stack(
      children: [
        listView,
        AnimatedScrollToTopPill(
          controller: _effectiveController,
          threshold: widget.scrollToTopThreshold,
          bottomPadding: widget.scrollToTopBottomPadding,
        ),
      ],
    );
  }
}
