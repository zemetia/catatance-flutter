import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/widgets/smooth_scroll/smooth_scroll.dart';

void main() {
  group('SmoothScrollPhysics', () {
    test('provides custom spring description and velocity bounds', () {
      const physics = SmoothScrollPhysics();

      expect(physics.spring.mass, 75.0);
      expect(physics.spring.stiffness, 120.0);
      expect(physics.spring.damping, 1.15);
      expect(physics.minFlingVelocity, 40.0);
      expect(physics.maxFlingVelocity, 8000.0);
    });

    test('calculates custom friction factor correctly', () {
      const physics = SmoothScrollPhysics();

      expect(physics.frictionFactor(0.0), closeTo(0.52, 0.001));
      expect(physics.frictionFactor(0.5), closeTo(0.26, 0.001));
      expect(physics.frictionFactor(1.0), closeTo(0.0, 0.001));
    });

    test('applyTo preserves physics inheritance', () {
      const physics = SmoothScrollPhysics();
      final applied = physics.applyTo(const ClampingScrollPhysics());

      expect(applied, isA<SmoothScrollPhysics>());
      expect(applied.parent, isA<ClampingScrollPhysics>());
    });
  });

  group('SmoothScrollBehavior', () {
    testWidgets('provides SmoothScrollPhysics and multi-device drag support',
        (tester) async {
      const behavior = SmoothScrollBehavior();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final physics = behavior.getScrollPhysics(context);
              expect(physics, isA<SmoothScrollPhysics>());
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(
        behavior.dragDevices,
        containsAll([
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        ]),
      );
    });
  });

  group('SmoothScrollController & Extensions', () {
    testWidgets('smoothScrollTo / smoothScrollToTop animate smoothly',
        (tester) async {
      final controller = SmoothScrollController(threshold: 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              controller: controller,
              itemCount: 50,
              itemExtent: 50.0,
              itemBuilder: (context, index) => Text('Item $index'),
            ),
          ),
        ),
      );

      expect(controller.offset, 0.0);
      expect(controller.isPastThreshold.value, isFalse);

      // Scroll to 300
      unawaited(controller.smoothScrollTo(300.0));
      await tester.pumpAndSettle();

      expect(controller.offset, 300.0);
      expect(controller.isPastThreshold.value, isTrue);

      // Scroll to top
      unawaited(controller.smoothScrollToTop());
      await tester.pumpAndSettle();

      expect(controller.offset, 0.0);
      expect(controller.isPastThreshold.value, isFalse);

      controller.dispose();
    });
  });

  group('AnimatedScrollToTopPill', () {
    testWidgets('shows pill when scrolled past threshold and scrolls to top on tap',
        (tester) async {
      final controller = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ListView.builder(
                  controller: controller,
                  itemCount: 100,
                  itemExtent: 50.0,
                  itemBuilder: (context, index) => Text('Row $index'),
                ),
                AnimatedScrollToTopPill(
                  controller: controller,
                  threshold: 150.0,
                  bottomPadding: 20.0,
                ),
              ],
            ),
          ),
        ),
      );

      // Initially at 0: pill is hidden (opacity 0)
      expect(find.text('Ke Atas'), findsOneWidget);
      final initialOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(initialOpacity.opacity, 0.0);

      // Scroll down past threshold
      controller.jumpTo(300.0);
      await tester.pumpAndSettle();

      final visibleOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(visibleOpacity.opacity, 1.0);

      // Tap the pill to scroll to top
      await tester.tap(find.text('Ke Atas'));
      await tester.pumpAndSettle();

      expect(controller.offset, 0.0);
      controller.dispose();
    });
  });

  group('AnimatedScrollItem', () {
    testWidgets('renders child cleanly with and without animation',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimatedScrollItem(
                  index: 0,
                  child: Text('Animated Child'),
                ),
                AnimatedScrollItem(
                  index: 1,
                  enabled: false,
                  child: Text('Static Child'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Animated Child'), findsOneWidget);
      expect(find.text('Static Child'), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });

  group('SmoothListView', () {
    testWidgets('renders list with built-in smooth physics and scroll pill',
        (tester) async {
      final controller = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothListView(
              controller: controller,
              scrollToTopThreshold: 100.0,
              children: List.generate(
                40,
                (i) => SizedBox(height: 50, child: Text('Smooth Row $i')),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Smooth Row 0'), findsOneWidget);

      // Scroll down
      controller.jumpTo(250.0);
      await tester.pumpAndSettle();

      // Tap scroll to top
      await tester.tap(find.text('Ke Atas'));
      await tester.pumpAndSettle();

      expect(controller.offset, 0.0);
      controller.dispose();
    });
  });
}
