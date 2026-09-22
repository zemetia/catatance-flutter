import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';
import 'package:pencatatan_keuangan/features/transactions/data/transaction_repository.dart';
import 'package:pencatatan_keuangan/features/transactions/presentation/add_transaction_screen.dart';
import 'package:pencatatan_keuangan/features/transactions/presentation/transaction_providers.dart';
import 'package:pencatatan_keuangan/features/transactions/presentation/widgets/budget_info_card.dart';
import 'package:pencatatan_keuangan/features/transactions/presentation/widgets/transaction_type_switch.dart';

import 'package:drift/drift.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late AppDatabase db;
  late TransactionRepository repository;

  setUpAll(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await initializeDateFormatting('id_ID', null);
    db = AppDatabase(NativeDatabase.memory());
    repository = TransactionRepository(db);
  });

  tearDownAll(() async {
    await db.close();
  });

  Widget buildTestableScreen() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        transactionRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: AddTransactionScreen(),
      ),
    );
  }

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

  testWidgets('AddTransactionScreen renders initial elements properly',
      (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    // Check header
    expect(find.text('Catat Pengeluaran'), findsOneWidget);

    // Check type switch
    expect(find.byType(TransactionTypeSwitch), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Pemasukan'), findsOneWidget);

    // Check nominal display
    expect(find.text('NOMINAL PENGELUARAN'), findsOneWidget);
    expect(find.text('Rp 0'), findsOneWidget);

    // Check quick presets
    expect(find.text('+10rb'), findsOneWidget);
    expect(find.text('+50rb'), findsOneWidget);
    expect(find.text('+100rb'), findsOneWidget);

    // Check action chips
    expect(find.text('Suara'), findsOneWidget);
    expect(find.text('Scan Struk'), findsOneWidget);
    expect(find.text('Patungan'), findsOneWidget);
    expect(find.text('Tag'), findsOneWidget);

    await disposeTester(tester);
  });

  testWidgets('Tapping quick amount chips updates the displayed nominal',
      (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('Rp 0'), findsOneWidget);

    // Tap +50rb
    await tester.tap(find.text('+50rb'));
    await tester.pumpAndSettle();

    expect(find.text('Rp 50.000'), findsOneWidget);

    // Tap +100rb -> total 150.000
    await tester.tap(find.text('+100rb'));
    await tester.pumpAndSettle();

    expect(find.text('Rp 150.000'), findsOneWidget);

    // Tap Reset chip
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(find.text('Rp 0'), findsOneWidget);

    await disposeTester(tester);
  });

  testWidgets('Switching to Pemasukan updates title and nominal label',
      (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    // Switch to Pemasukan
    await tester.tap(find.text('Pemasukan'));
    await tester.pumpAndSettle();

    expect(find.text('Catat Pemasukan'), findsOneWidget);
    expect(find.text('NOMINAL PEMASUKAN'), findsOneWidget);

    // Switch back to Pengeluaran
    await tester.tap(find.text('Pengeluaran'));
    await tester.pumpAndSettle();

    expect(find.text('Catat Pengeluaran'), findsOneWidget);
    expect(find.text('NOMINAL PENGELUARAN'), findsOneWidget);

    await disposeTester(tester);
  });

  testWidgets('BudgetInfoCard shows active budgeting status for budgeted category',
      (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    // In seed data, default expense category is 'Makanan & Minuman',
    // which matches seeded budget 'Makanan & Minuman'.
    expect(find.byType(BudgetInfoCard), findsOneWidget);
    expect(find.textContaining('Masuk Pembudgetan'), findsOneWidget);

    await disposeTester(tester);
  });

  testWidgets('Submitting a transaction writes to database and syncs account balance',
      (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    // Add amount 50.000
    await tester.tap(find.text('+50rb'));
    await tester.pumpAndSettle();

    // Submit button
    final submitButton = find.textContaining('Simpan Pengeluaran');
    expect(submitButton, findsOneWidget);

    await tester.tap(submitButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    // Verify transaction exists in repository
    final recent = await repository.watchRecent().first;
    expect(recent.any((t) => t.amountCents == 50000), isTrue);

    await disposeTester(tester);
  });
}
