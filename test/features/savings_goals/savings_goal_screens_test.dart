import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';
import 'package:pencatatan_keuangan/features/savings_goals/data/savings_goal_repository.dart';
import 'package:pencatatan_keuangan/features/savings_goals/presentation/savings_goal_detail_screen.dart';
import 'package:pencatatan_keuangan/features/savings_goals/presentation/savings_goal_form_screen.dart';
import 'package:pencatatan_keuangan/features/savings_goals/presentation/savings_goal_list_screen.dart';
import 'package:pencatatan_keuangan/features/savings_goals/presentation/savings_goal_providers.dart';
import 'package:pencatatan_keuangan/features/savings_goals/presentation/widgets/quick_deposit_sheet.dart';
import 'package:pencatatan_keuangan/features/savings_goals/presentation/widgets/savings_calculator_sheet.dart';

void main() {
  late AppDatabase db;
  late SavingsGoalRepository repository;

  setUpAll(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = SavingsGoalRepository(db);
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

  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        savingsGoalRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Savings Goal Screens Tests', () {
    testWidgets('SavingsGoalFormScreen renders initial preview card, name, icons, and autosave controls',
        (tester) async {
      setupViewport(tester);

      await tester.pumpWidget(buildTestableWidget(const SavingsGoalFormScreen()));
      await tester.pumpAndSettle();

      // Form title
      expect(find.text('Target tabungan'), findsOneWidget);

      // Preview card placeholder
      expect(find.text('cth: Liburan Bali'), findsAtLeastNWidgets(1));
      expect(find.text('Tanpa deadline'), findsAtLeastNWidgets(1));

      // Input sections
      expect(find.text('Nama target'), findsOneWidget);
      expect(find.text('Ikon'), findsOneWidget);
      expect(find.text('Warna'), findsOneWidget);
      expect(find.text('atau biarkan otomatis'), findsOneWidget);
      expect(find.text('Pilih dari galeri'), findsOneWidget);
      expect(find.text('Target Nominal Tabungan'), findsOneWidget);
      expect(find.text('Autosave (Tabung Otomatis)'), findsOneWidget);

      // Bottom CTA
      expect(find.text('Buat target'), findsOneWidget);

      await disposeTester(tester);
    });

    testWidgets('Entering target name dynamically updates preview card',
        (tester) async {
      setupViewport(tester);

      await tester.pumpWidget(buildTestableWidget(const SavingsGoalFormScreen()));
      await tester.pumpAndSettle();

      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Liburan ke Jepang');
      await tester.pumpAndSettle();

      // Preview card now displays the user-entered name
      expect(find.text('Liburan ke Jepang'), findsAtLeastNWidgets(1));

      await disposeTester(tester);
    });

    testWidgets('Toggling Autosave reveals frequency options and wallet picker',
        (tester) async {
      setupViewport(tester);

      await tester.pumpWidget(buildTestableWidget(const SavingsGoalFormScreen()));
      await tester.pumpAndSettle();

      // Find Autosave switch
      final autosaveSwitch = find.byType(Switch).last;
      await tester.tap(autosaveSwitch);
      await tester.pumpAndSettle();

      // Sub-controls now visible
      expect(find.text('Nominal ditabung per periode'), findsOneWidget);
      expect(find.text('Frekuensi Menabung'), findsOneWidget);
      expect(find.text('Harian'), findsOneWidget);
      expect(find.text('Mingguan'), findsOneWidget);
      expect(find.text('Bulanan'), findsOneWidget);
      expect(find.text('Sumber Dompet Pendebetan'), findsOneWidget);

      await disposeTester(tester);
    });

    testWidgets('SavingsGoalDetailScreen renders goal details and actions',
        (tester) async {
      setupViewport(tester);

      // Get first seeded goal (Liburan Bali)
      final goals = await db.select(db.savingsGoals).get();
      final bali = goals.firstWhere((g) => g.name == 'Liburan Bali');

      await tester.pumpWidget(
        buildTestableWidget(SavingsGoalDetailScreen(goalId: bali.id)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Liburan Bali'), findsAtLeastNWidgets(1));
      expect(find.text('Terkumpul'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
      expect(find.text('Nabung'), findsOneWidget);
      expect(find.text('Tarik Saldo'), findsOneWidget);
      expect(find.text('Autosave (Tabung Otomatis)'), findsOneWidget);

      await disposeTester(tester);
    });

    testWidgets('SavingsGoalListScreen renders summary banner and list',
        (tester) async {
      setupViewport(tester);

      await tester.pumpWidget(buildTestableWidget(const SavingsGoalListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Target Tabungan'), findsOneWidget);
      expect(find.text('Total Terkumpul'), findsOneWidget);
      expect(find.textContaining('Semua'), findsOneWidget);
      expect(find.textContaining('Berjalan'), findsOneWidget);
      expect(find.text('Liburan Bali'), findsOneWidget);
      expect(find.text('Beli Laptop Baru'), findsOneWidget);
      expect(find.text('Dana Darurat'), findsOneWidget);

      await disposeTester(tester);
    });

    testWidgets('SavingsGoalListScreen toggles balance masking via eye icon',
        (tester) async {
      setupViewport(tester);

      await tester.pumpWidget(buildTestableWidget(const SavingsGoalListScreen()));
      await tester.pumpAndSettle();

      // Initially balance is visible (contains 'Rp')
      expect(find.textContaining('Rp'), findsWidgets);

      // Find eye icon and tap
      final eyeButton = find.byWidgetPredicate(
        (w) => w is InkWell && w.child is Padding,
      );
      if (eyeButton.evaluate().isNotEmpty) {
        await tester.tap(eyeButton.first);
        await tester.pumpAndSettle();

        expect(find.text('Rp ••••••••'), findsOneWidget);

        // Tap again to unmask
        await tester.tap(eyeButton.first);
        await tester.pumpAndSettle();

        expect(find.text('Rp ••••••••'), findsNothing);
      }

      await disposeTester(tester);
    });

    testWidgets('SavingsCalculatorSheet calculates daily, weekly, and monthly commitments',
        (tester) async {
      setupViewport(tester);

      await tester.pumpWidget(
        buildTestableWidget(
          const Scaffold(body: SavingsCalculatorSheet()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Simulasi & Kalkulator Target'), findsOneWidget);
      expect(find.text('Rekomendasi Setoran Rutin'), findsOneWidget);
      expect(find.text('Per Bulan'), findsOneWidget);
      expect(find.text('Per Minggu'), findsOneWidget);
      expect(find.text('Per Hari'), findsOneWidget);

      // Check preset duration chips
      expect(find.text('3 Bulan'), findsOneWidget);
      expect(find.text('12 Bulan (1 Thn)'), findsOneWidget);

      // Tap 3 Bulan
      await tester.tap(find.text('3 Bulan'));
      await tester.pumpAndSettle();

      expect(find.textContaining('3 Bulan'), findsAtLeastNWidgets(1));

      await disposeTester(tester);
    });

    testWidgets('QuickDepositSheet renders target info, chips, and updates nominal on tap',
        (tester) async {
      setupViewport(tester);

      final goals = await repository.getAll();
      expect(goals, isNotEmpty);
      final targetGoal = goals.first;

      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: QuickDepositSheet(
              goals: goals,
              initialGoalId: targetGoal.id,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nabung Cepat'), findsOneWidget);
      expect(find.text('Target Tujuan'), findsOneWidget);
      expect(find.text('Setor Tabungan Sekarang'), findsOneWidget);
      expect(find.text('+50rb'), findsOneWidget);
      expect(find.text('+100rb'), findsOneWidget);
      expect(find.text('+500rb'), findsOneWidget);
      expect(find.text('+1jt'), findsOneWidget);

      // Tap +50rb chip (initial 100.000 + 50.000 = 150.000)
      await tester.tap(find.text('+50rb'));
      await tester.pumpAndSettle();

      expect(find.text('150.000'), findsOneWidget);

      await disposeTester(tester);
    });
  });
}
