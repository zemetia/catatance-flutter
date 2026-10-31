import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';
import 'package:pencatatan_keuangan/features/reports/domain/report_models.dart';
import 'package:pencatatan_keuangan/features/reports/presentation/kalender_cashflow_providers.dart';
import 'package:pencatatan_keuangan/features/reports/presentation/widgets/cashflow_day_detail.dart';
import 'package:pencatatan_keuangan/features/transactions/data/transaction_repository.dart';
import 'package:pencatatan_keuangan/features/transactions/presentation/transaction_providers.dart';
import 'package:pencatatan_keuangan/features/transactions/presentation/widgets/transaction_detail_sheet.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  late AppDatabase db;
  late TransactionRepository transactionRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    transactionRepo = TransactionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('CashflowDayDetail transaction row can be tapped to show detail and edit', (tester) async {
    final accounts = await db.select(db.accounts).get();
    final categories = await db.select(db.categories).get();

    final testDate = DateTime(2026, 10, 31, 14, 0);
    final txId = await transactionRepo.insert(
      accountId: accounts.first.id,
      categoryId: categories.first.id,
      amountCents: 45000,
      note: 'Kopi Kenangan Senja',
      date: testDate,
    );

    final cashflowTx = CashflowTransaction(
      id: txId,
      title: 'Kopi Kenangan Senja',
      categoryName: categories.first.name,
      categoryIcon: categories.first.icon,
      categoryColorValue: categories.first.colorValue,
      accountName: accounts.first.name,
      amountCents: 45000,
      date: testDate,
      isIncome: false,
      isTransfer: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          transactionRepositoryProvider.overrideWithValue(transactionRepo),
          kalenderSelectedDateProvider.overrideWith((ref) => DateTime(2026, 10, 31)),
          kalenderSelectedDateTransactionsProvider.overrideWith(
            (ref) => Stream.value([cashflowTx]),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CashflowDayDetail(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify action buttons
    expect(
      find.byTooltip('Transfer antar dompet di tanggal ini'),
      findsOneWidget,
    );
    expect(
      find.byTooltip('Tambah transaksi di tanggal ini'),
      findsOneWidget,
    );

    // Verify transaction is rendered in the list
    expect(find.text('Kopi Kenangan Senja'), findsOneWidget);

    // Tap on the transaction row
    await tester.tap(find.text('Kopi Kenangan Senja'));
    await tester.pumpAndSettle();

    // Verify TransactionDetailSheet opened with "Ubah Transaksi" and "Hapus Transaksi" buttons
    expect(find.byType(TransactionDetailSheet), findsOneWidget);
    expect(find.text('Ubah Transaksi'), findsOneWidget);
    expect(find.text('Hapus Transaksi'), findsOneWidget);
  });

  testWidgets('CashflowDayDetail renders transfer transaction row with proper formatting', (tester) async {
    final transferTx = CashflowTransaction(
      id: 99,
      title: 'Transfer dari BCA ke Mandiri',
      categoryName: 'Transfer',
      categoryIcon: 'arrow-left-right',
      categoryColorValue: 0xFF3D7FFF,
      accountName: 'BCA',
      amountCents: 500000,
      date: DateTime(2026, 10, 31, 10, 30),
      isIncome: false,
      isTransfer: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          transactionRepositoryProvider.overrideWithValue(transactionRepo),
          kalenderSelectedDateProvider.overrideWith((ref) => DateTime(2026, 10, 31)),
          kalenderSelectedDateTransactionsProvider.overrideWith(
            (ref) => Stream.value([transferTx]),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CashflowDayDetail(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Transfer dari BCA ke Mandiri'), findsOneWidget);
    expect(find.text('Transfer • BCA • 10:30'), findsOneWidget);
    expect(find.textContaining('⇄ Rp 500.000'), findsOneWidget);
  });
}
