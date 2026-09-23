import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart' hide Debt;
import 'package:pencatatan_keuangan/features/debts/data/debt_repository.dart';
import 'package:pencatatan_keuangan/features/debts/domain/debt.dart';
import 'package:pencatatan_keuangan/features/debts/domain/debt_type.dart';
import 'package:pencatatan_keuangan/features/debts/presentation/debt_detail_screen.dart';
import 'package:pencatatan_keuangan/features/debts/presentation/debt_form_screen.dart';
import 'package:pencatatan_keuangan/features/debts/presentation/debt_list_screen.dart';
import 'package:pencatatan_keuangan/features/debts/presentation/debt_providers.dart';
import 'package:pencatatan_keuangan/features/debts/presentation/widgets/dashboard_debt_card.dart';
import 'package:pencatatan_keuangan/features/debts/presentation/widgets/payment_bottom_sheet.dart';

void main() {
  late AppDatabase db;
  late DebtRepository repository;

  setUpAll(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await initializeDateFormatting('id_ID', null);
    db = AppDatabase(NativeDatabase.memory());
    repository = DebtRepository(db);
  });

  tearDownAll(() async {
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
    await tester.pump(const Duration(seconds: 5));
  }

  testWidgets('DebtListScreen renders summary header, search, and seeded debts',
      (tester) async {
    setupViewport(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          debtRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: DebtListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Utang & Piutang'), findsOneWidget);
    expect(find.text('Total Utang'), findsOneWidget);
    expect(find.text('Total Piutang'), findsOneWidget);
    expect(find.text('Kak Sarah'), findsOneWidget);
    expect(find.text('Rian Pratama'), findsOneWidget);

    await disposeTester(tester);
  });

  testWidgets('DebtFormScreen renders type switches and inputs properly',
      (tester) async {
    setupViewport(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          debtRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: DebtFormScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Catat Utang / Piutang'), findsOneWidget);
    expect(find.text('Utang Saya'), findsOneWidget);
    expect(find.text('Piutang Saya'), findsOneWidget);
    expect(find.text('Nominal Pinjaman'), findsOneWidget);
    expect(find.text('Simpan Transaksi'), findsOneWidget);

    // Switch type to Piutang
    await tester.tap(find.text('Piutang Saya'));
    await tester.pumpAndSettle();

    expect(find.text('Peminjam (Nama Orang / Pihak Terkait)'), findsOneWidget);

    await disposeTester(tester);
  });

  testWidgets('DebtDetailScreen displays debt details and actions',
      (tester) async {
    setupViewport(tester);

    final debts = await tester.runAsync(() => repository.watchAll().first);
    final sarahDebt = debts!.firstWhere((d) => d.personName == 'Kak Sarah');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          debtRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          home: DebtDetailScreen(debtId: sarahDebt.id),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Detail Utang'), findsOneWidget);
    expect(find.text('Kak Sarah'), findsOneWidget);
    expect(find.text('Sisa yang Belum Lunas'), findsOneWidget);
    expect(find.text('Bayar Utang'), findsOneWidget);
    expect(find.text('Lunasi Penuh'), findsOneWidget);
    expect(find.text('Riwayat Pembayaran'), findsOneWidget);
    expect(find.text('Cicilan pertama transfer BCA'), findsOneWidget);
    expect(find.text('Dompet Terkait'), findsOneWidget);

    await disposeTester(tester);
  });

  testWidgets('DashboardDebtCard renders active debts, receivables, and alerts',
      (tester) async {
    setupViewport(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          debtRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: DashboardDebtCard(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Utang & Piutang'), findsOneWidget);
    expect(find.text('Utang Saya'), findsOneWidget);
    expect(find.text('Piutang Saya'), findsOneWidget);
    expect(find.text('Kelola'), findsOneWidget);
    expect(
      find.text('1 tagihan melewati jatuh tempo'),
      findsOneWidget,
    );

    await disposeTester(tester);
  });

  testWidgets(
      'DebtDetailScreen renders Piutang on narrow screen (360x640) without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final debts = await tester.runAsync(() => repository.watchAll().first);
    final rianPiutang =
        debts!.firstWhere((d) => d.personName == 'Rian Pratama');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          debtRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          home: DebtDetailScreen(debtId: rianPiutang.id),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Detail Piutang'), findsOneWidget);
    expect(find.text('Rian Pratama'), findsOneWidget);
    expect(find.text('Terima Pembayaran'), findsOneWidget);
    expect(find.text('Lunasi Penuh'), findsOneWidget);
    expect(find.text('Salin Pesan Tagihan (WhatsApp)'), findsOneWidget);

    // Verify no overflow exception was caught
    expect(tester.takeException(), isNull);

    await disposeTester(tester);
  });

  testWidgets(
      'DebtDetailScreen renders Piutang on ultra-narrow screen (320x850) with 1.5x font scale without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final debts = await tester.runAsync(() => repository.watchAll().first);
    final rianPiutang =
        debts!.firstWhere((d) => d.personName == 'Rian Pratama');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          debtRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.5),
            ),
            child: child!,
          ),
          home: DebtDetailScreen(debtId: rianPiutang.id),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Detail Piutang'), findsOneWidget);
    expect(find.text('Rian Pratama'), findsOneWidget);

    final terimaBtn = find.text('Terima Pembayaran');
    await tester.scrollUntilVisible(terimaBtn, 200);
    expect(terimaBtn, findsOneWidget);
    expect(find.text('Lunasi Penuh'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await disposeTester(tester);
  });

  testWidgets(
      'DebtListScreen renders on ultra-narrow screen (320x640) with 1.5x font scale without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          debtRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.5),
            ),
            child: child!,
          ),
          home: const DebtListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Utang & Piutang'), findsOneWidget);
    expect(find.text('Selisih Bersih (Piutang - Utang)'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await disposeTester(tester);
  });

  testWidgets(
      'DebtFormScreen renders on narrow screen (320x850) with 1.5x font scale without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          debtRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.5),
            ),
            child: child!,
          ),
          home: const Scaffold(
            body: DebtFormScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Catat Utang / Piutang'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(find.text('Atur Jatuh Tempo'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(find.text('Dompet Terkait (Opsional)'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await disposeTester(tester);
  });

  testWidgets(
      'PaymentBottomSheet records payment and safely pops with snackbar',
      (tester) async {
    tester.view.physicalSize = const Size(340, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final debts = await tester.runAsync(() => repository.watchAll().first);
    final rianPiutang =
        debts!.firstWhere((d) => d.personName == 'Rian Pratama');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          debtRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => PaymentBottomSheet.show(context, rianPiutang),
                child: const Text('Buka'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();

    expect(find.text('Terima Pembayaran'), findsOneWidget);
    expect(find.text('Pihak: Rian Pratama'), findsOneWidget);

    await tester.tap(find.text('Simpan Pembayaran'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    await disposeTester(tester);
  });

  test('DebtActionNotifier executes all async actions without ref async errors',
      () async {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        debtRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    // 1. Create debt via action notifier
    final newId = await container.read(debtActionProvider.notifier).createDebt(
          DebtDraft(
            type: DebtType.receivable,
            personName: 'Test Orang Asing',
            amountCents: 50000000,
            paidAmountCents: 0,
            dueDate: DateTime.now().add(const Duration(days: 10)),
            transactionDate: DateTime.now(),
            note: 'Pinjaman modal usaha',
          ),
        );
    expect(newId, isNotNull);

    // 2. Update debt
    await container.read(debtActionProvider.notifier).updateDebt(
          newId!,
          DebtDraft(
            type: DebtType.receivable,
            personName: 'Test Orang Asing Updated',
            amountCents: 60000000,
            paidAmountCents: 0,
            dueDate: DateTime.now().add(const Duration(days: 15)),
            transactionDate: DateTime.now(),
            note: 'Updated note',
          ),
        );

    // 3. Record payment
    await container.read(debtActionProvider.notifier).recordPayment(
          DebtPaymentDraft(
            debtId: newId,
            amountCents: 20000000,
            paymentDate: DateTime.now(),
            note: 'Cicilan 1',
          ),
        );

    final updated = await repository.watchDebt(newId).first;
    expect(updated?.paidAmountCents, 20000000);
    expect(updated?.remainingCents, 40000000);

    // 4. Settle debt
    await container.read(debtActionProvider.notifier).settleDebt(newId);
    final settled = await repository.watchDebt(newId).first;
    expect(settled?.isSettled, isTrue);

    // 5. Delete debt
    await container.read(debtActionProvider.notifier).deleteDebt(newId);
    final deleted = await repository.watchDebt(newId).first;
    expect(deleted, isNull);
  });

  testWidgets(
      'Stress test: DebtDetailScreen with extreme font scale (1.8x) and long names on 320px width',
      (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final longDebtId = await repository.insertDebt(
      DebtDraft(
        type: DebtType.receivable,
        personName: 'Alexander Bartholomeus Sitorus Pangestu',
        amountCents: 98765432100, // 987 million Rp
        paidAmountCents: 12345678900,
        dueDate: DateTime.now().add(const Duration(days: 3)),
        transactionDate: DateTime.now(),
        note: 'Pinjaman modal usaha ekspansi cabang baru dengan tempo ketat',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          debtRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.8),
            ),
            child: child!,
          ),
          home: DebtDetailScreen(debtId: longDebtId),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Scroll through the whole screen to check for any overflows
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await disposeTester(tester);
  });

  testWidgets(
      'Stress test: PaymentBottomSheet with extreme values on 320px width and 1.5x font scale',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testDebt = Debt(
      id: 9999,
      type: DebtType.receivable,
      personName: 'Alexander Bartholomeus Pangestu',
      amountCents: 99999999900,
      paidAmountCents: 0,
      transactionDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          debtRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.5),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => PaymentBottomSheet.show(ctx, testDebt),
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await disposeTester(tester);
  });

  testWidgets(
      'DebtDetailScreen delete flow: successfully deletes and pops without deactivated widget or ref errors',
      (tester) async {
    setupViewport(tester);

    final debtId = await repository.insertDebt(
      DebtDraft(
        type: DebtType.receivable,
        personName: 'Orang Mau Dihapus',
        amountCents: 5000000,
        paidAmountCents: 0,
        transactionDate: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          debtRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => Navigator.of(ctx).push(
                  MaterialPageRoute(
                    builder: (_) => DebtDetailScreen(debtId: debtId),
                  ),
                ),
                child: const Text('Open Detail'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Detail'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Piutang'), findsOneWidget);

    // Open popup menu
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    // Tap 'Hapus Catatan'
    await tester.tap(find.text('Hapus Catatan'));
    await tester.pumpAndSettle();

    // Confirm dialog
    expect(find.text('Hapus Catatan?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Open Detail'), findsOneWidget);

    final check = await repository.getDebt(debtId);
    expect(check, isNull);

    await disposeTester(tester);
  });

  testWidgets(
      'DebtFormScreen edit flow: loads existing data and updates without ref error',
      (tester) async {
    setupViewport(tester);

    final debtId = await repository.insertDebt(
      DebtDraft(
        type: DebtType.debt,
        personName: 'Pak Budi Edit',
        amountCents: 10000000,
        paidAmountCents: 0,
        transactionDate: DateTime.now(),
        note: 'Catatan awal',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          debtRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          home: DebtFormScreen(debtId: debtId),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Edit Catatan'), findsOneWidget);
    expect(find.text('Pak Budi Edit'), findsOneWidget);
    expect(find.text('10000000'), findsOneWidget);

    // Change name and submit
    await tester.enterText(
        find.widgetWithText(TextField, 'Pak Budi Edit'), 'Pak Budi Sukses');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perbarui Catatan'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final updated = await repository.getDebt(debtId);
    expect(updated?.personName, 'Pak Budi Sukses');

    await disposeTester(tester);
  });
}
