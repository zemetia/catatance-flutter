import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';
import 'package:pencatatan_keuangan/features/profile/presentation/profile_screen.dart';
import 'package:pencatatan_keuangan/features/savings_goals/data/savings_goal_repository.dart';
import 'package:pencatatan_keuangan/features/savings_goals/presentation/savings_goal_list_screen.dart';
import 'package:pencatatan_keuangan/features/savings_goals/presentation/savings_goal_providers.dart';

void main() {
  late AppDatabase db;
  late SavingsGoalRepository savingsRepo;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    savingsRepo = SavingsGoalRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  void setupViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> disposeTester(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('Tapping Semua Target in ProfileScreen navigates to /savings-goals and can return back', (tester) async {
    setupViewport(tester);

    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (_, _) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/savings-goals',
          builder: (context, _) => Scaffold(
            appBar: AppBar(
              title: const Text('Target Tabungan Mock'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(child: Text('Savings Goals Screen Target')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify ProfileScreen is rendered
    expect(find.text('Profil'), findsOneWidget);

    // Verify 'Semua Target' menu is rendered
    final targetFinder = find.text('Semua Target');
    expect(targetFinder, findsOneWidget);

    // Scroll until 'Semua Target' is visible and tap it
    await tester.scrollUntilVisible(
      targetFinder,
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(targetFinder);
    await tester.pumpAndSettle();

    // Verify navigation destination has been reached
    expect(find.text('Savings Goals Screen Target'), findsOneWidget);
    expect(find.text('Target Tabungan Mock'), findsOneWidget);

    // Pop back to profile
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify we are back on ProfileScreen
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Savings Goals Screen Target'), findsNothing);

    await disposeTester(tester);
  });

  testWidgets('End-to-end: ProfileScreen navigates to real SavingsGoalListScreen and returns back', (tester) async {
    setupViewport(tester);

    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (_, _) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/savings-goals',
          builder: (_, _) => const SavingsGoalListScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          savingsGoalRepositoryProvider.overrideWithValue(savingsRepo),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final targetFinder = find.text('Semua Target');
    expect(targetFinder, findsOneWidget);

    await tester.scrollUntilVisible(
      targetFinder,
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(targetFinder);
    await tester.pumpAndSettle();

    // Verify real SavingsGoalListScreen is rendered
    expect(find.text('Target Tabungan'), findsOneWidget);
    expect(find.text('Total Terkumpul'), findsOneWidget);

    // Tap back button on the real SavingsGoalListScreen AppBar
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Verify we are back on ProfileScreen
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Total Terkumpul'), findsNothing);

    await disposeTester(tester);
  });
}
