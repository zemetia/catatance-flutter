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
    final recent = await tester.runAsync(() => repository.watchRecent().first);
    expect(recent?.any((t) => t.amountCents == 50000), isTrue);

    await disposeTester(tester);
  });

  testWidgets(
      'Selecting a Dollar (USD) wallet dynamically switches nominal display and buttons to \$',
      (tester) async {
    setupViewport(tester);

    // Insert a Dollar account
    final usdAccountId = await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            name: 'PayPal USD',
            type: 'e-wallet',
            currencyCode: const Value('USD'),
            initialBalanceCents: const Value(1500),
            colorValue: const Value(0xFF0079C1),
            isDefault: const Value(false),
          ),
        );

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    // Initially IDR: nominal displays 'Rp 0' and presets have '+10rb', '+50rb'
    expect(find.text('Rp 0'), findsOneWidget);
    expect(find.text('+10rb'), findsOneWidget);
    expect(find.text('+50rb'), findsOneWidget);

    // Pick the PayPal USD account
    await tester.tap(find.text('Sumber Dana / Dompet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('PayPal USD'));
    await tester.pumpAndSettle();

    // Nominal should now show '$ 0'
    expect(find.text(r'$ 0'), findsOneWidget);

    // Presets should now update to '+$10', '+$50', '+$100', '+$500'
    expect(find.text(r'+$10'), findsOneWidget);
    expect(find.text(r'+$50'), findsOneWidget);
    expect(find.text(r'+$100'), findsOneWidget);
    expect(find.text(r'+$500'), findsOneWidget);

    // Tap '+$50' preset chip
    await tester.tap(find.text(r'+$50'));
    await tester.pumpAndSettle();

    expect(find.text(r'$ 50'), findsOneWidget);

    // Submit button should display '$ 50'
    final submitButton = find.text('Simpan Pengeluaran (\$ 50)');
    expect(submitButton, findsOneWidget);

    // Submit transaction
    await tester.tap(submitButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    // Verify transaction exists with accountId = usdAccountId and amountCents = 50
    final recent = await tester.runAsync(() => repository.watchRecent().first);
    expect(
      recent?.any((t) => t.accountId == usdAccountId && t.amountCents == 50),
      isTrue,
    );

    await disposeTester(tester);
  });

  testWidgets(
      'Switching to Pemasukan with a Euro wallet updates nominal label and formats with €',
      (tester) async {
    setupViewport(tester);

    // Insert a Euro account
    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            name: 'Euro Tabungan',
            type: 'bank',
            currencyCode: const Value('EUR'),
            initialBalanceCents: const Value(500),
            colorValue: const Value(0xFF2E7D32),
            isDefault: const Value(false),
          ),
        );

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    // Switch to Pemasukan (Income)
    await tester.tap(find.text('Pemasukan'));
    await tester.pumpAndSettle();

    expect(find.text('NOMINAL PEMASUKAN'), findsOneWidget);

    // Pick the Euro account
    await tester.tap(find.text('Sumber Dana / Dompet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Euro Tabungan'));
    await tester.pumpAndSettle();

    // Nominal should now show '€ 0'
    expect(find.text('€ 0'), findsOneWidget);

    // Presets should now update to '+€10', '+€50', etc.
    expect(find.text('+€10'), findsOneWidget);
    expect(find.text('+€50'), findsOneWidget);

    // Tap '+€50' twice -> total 100
    await tester.tap(find.text('+€50'));
    await tester.pumpAndSettle();
    expect(find.text('€ 50'), findsOneWidget);

    await tester.tap(find.text('+€50'));
    await tester.pumpAndSettle();
    expect(find.text('€ 100'), findsOneWidget);

    // Submit button shows 'Simpan Pemasukan (€ 100)'
    expect(find.text('Simpan Pemasukan (€ 100)'), findsOneWidget);

    await disposeTester(tester);
  });

  testWidgets(
      'Typing directly into nominal TextField with Dollar wallet formats with \$ symbol',
      (tester) async {
    setupViewport(tester);

    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            name: 'Cash Dollar',
            type: 'cash',
            currencyCode: const Value('USD'),
            initialBalanceCents: const Value(200),
            colorValue: const Value(0xFF4CAF50),
            isDefault: const Value(false),
          ),
        );

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    // Select Cash Dollar
    await tester.tap(find.text('Sumber Dana / Dompet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cash Dollar'));
    await tester.pumpAndSettle();

    expect(find.text(r'$ 0'), findsOneWidget);

    // Enter text '125' in the nominal text field
    final textField = find.byType(TextField).first;
    await tester.enterText(textField, '125');
    await tester.pumpAndSettle();

    expect(find.text(r'$ 125'), findsOneWidget);
    expect(find.text('Simpan Pengeluaran (\$ 125)'), findsOneWidget);

    // Now switch to Euro wallet and verify that the nominal preserves 125 with €
    await tester.tap(find.text('Sumber Dana / Dompet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Euro Tabungan'));
    await tester.pumpAndSettle();

    expect(find.text('€ 125'), findsOneWidget);
    expect(find.text('Simpan Pengeluaran (€ 125)'), findsOneWidget);

    await disposeTester(tester);
  });

  testWidgets(
      'When default account is USD, screen initializes immediately with \$ 0',
      (tester) async {
    setupViewport(tester);

    // Set all existing accounts isDefault to false
    await db.update(db.accounts).write(
          const AccountsCompanion(isDefault: Value(false)),
        );

    // Insert a default USD account
    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            name: 'Default USD Card',
            type: 'bank',
            currencyCode: const Value('USD'),
            initialBalanceCents: const Value(1000),
            colorValue: const Value(0xFF1E88E5),
            isDefault: const Value(true),
          ),
        );

    await tester.pumpWidget(buildTestableScreen());
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    // Verify it immediately displays '$ 0' without needing manual account switch
    expect(find.text(r'$ 0'), findsOneWidget);
    expect(find.text(r'+$10'), findsOneWidget);
    expect(find.text(r'+$50'), findsOneWidget);

    await disposeTester(tester);
  });
}
