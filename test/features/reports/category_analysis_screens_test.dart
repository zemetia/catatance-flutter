import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pencatatan_keuangan/core/security/security_providers.dart';
import 'package:pencatatan_keuangan/features/reports/domain/report_models.dart';
import 'package:pencatatan_keuangan/features/reports/presentation/category_analysis_providers.dart';
import 'package:pencatatan_keuangan/features/reports/presentation/category_analysis_screen.dart';
import 'package:pencatatan_keuangan/features/reports/presentation/category_detail_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  final sampleItems = [
    const CategoryAnalysisItem(
      categoryId: 1,
      name: 'Makanan & Minuman',
      icon: 'utensils',
      colorValue: 0xFFFF5722,
      type: 'expense',
      totalCents: 850000,
      previousMonthTotalCents: 750000,
      share: 0.65,
      count: 8,
      budgetLimitCents: 1000000,
      budgetSpentCents: 850000,
    ),
    const CategoryAnalysisItem(
      categoryId: 2,
      name: 'Transportasi',
      icon: 'car',
      colorValue: 0xFF2196F3,
      type: 'expense',
      totalCents: 350000,
      previousMonthTotalCents: 400000,
      share: 0.35,
      count: 4,
      budgetLimitCents: 300000,
      budgetSpentCents: 350000,
    ),
  ];

  final sampleDetail = CategoryFlowDetail(
    categoryId: 1,
    categoryName: 'Makanan & Minuman',
    categoryIcon: 'utensils',
    categoryColorValue: 0xFFFF5722,
    categoryType: 'expense',
    totalCents: 850000,
    previousMonthTotalCents: 750000,
    shareOfTotal: 0.65,
    transactionCount: 8,
    averageCents: 106250,
    budgetLimitCents: 1000000,
    budgetSpentCents: 850000,
    wallets: const [
      CategoryWalletSpending(
        accountId: 1,
        accountName: 'BCA',
        totalCents: 600000,
        share: 0.705,
        count: 5,
      ),
      CategoryWalletSpending(
        accountId: 2,
        accountName: 'GoPay',
        totalCents: 250000,
        share: 0.295,
        count: 3,
      ),
    ],
    tags: const [
      TagSpending(tag: 'ngopi', totalCents: 150000, share: 0.176, count: 3),
      TagSpending(tag: 'makan-siang', totalCents: 700000, share: 0.824, count: 5),
    ],
    monthlyTrends: [
      CategoryMonthlyTrend(month: DateTime(2026, 5), totalCents: 500000),
      CategoryMonthlyTrend(month: DateTime(2026, 6), totalCents: 600000),
      CategoryMonthlyTrend(month: DateTime(2026, 7), totalCents: 550000),
      CategoryMonthlyTrend(month: DateTime(2026, 8), totalCents: 700000),
      CategoryMonthlyTrend(month: DateTime(2026, 9), totalCents: 750000),
      CategoryMonthlyTrend(month: DateTime(2026, 10), totalCents: 850000),
    ],
    transactions: [
      CashflowTransaction(
        id: 101,
        title: 'Makan Siang Bareng',
        categoryName: 'Makanan & Minuman',
        categoryIcon: 'utensils',
        categoryColorValue: 0xFFFF5722,
        accountName: 'BCA',
        amountCents: 150000,
        date: DateTime(2026, 10, 28, 12, 30),
        isIncome: false,
        isTransfer: false,
      ),
      CashflowTransaction(
        id: 102,
        title: 'Kopi Kenangan Senja',
        categoryName: 'Makanan & Minuman',
        categoryIcon: 'utensils',
        categoryColorValue: 0xFFFF5722,
        accountName: 'GoPay',
        amountCents: 35000,
        date: DateTime(2026, 10, 27, 15, 0),
        isIncome: false,
        isTransfer: false,
      ),
    ],
    biggestTransaction: CashflowTransaction(
      id: 101,
      title: 'Makan Siang Bareng',
      categoryName: 'Makanan & Minuman',
      categoryIcon: 'utensils',
      categoryColorValue: 0xFFFF5722,
      accountName: 'BCA',
      amountCents: 150000,
      date: DateTime(2026, 10, 28, 12, 30),
      isIncome: false,
      isTransfer: false,
    ),
  );

  testWidgets('CategoryAnalysisScreen renders overview and category items', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hideBalanceProvider.overrideWithValue(false),
          categoryAnalysisListProvider.overrideWith((ref) => Stream.value(sampleItems)),
        ],
        child: const MaterialApp(
          home: CategoryAnalysisScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Analisis Kategori'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Pemasukan'), findsOneWidget);
    expect(find.text('Makanan & Minuman'), findsWidgets);
    expect(find.text('Transportasi'), findsOneWidget);
    expect(find.text('Over budget'), findsWidgets);
  });

  testWidgets('CategoryDetailScreen renders category metrics, budget status, and wallet flow', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hideBalanceProvider.overrideWithValue(false),
          categoryFlowDetailProvider(1).overrideWith((ref) => Stream.value(sampleDetail)),
        ],
        child: const MaterialApp(
          home: CategoryDetailScreen(categoryId: 1),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Makanan & Minuman'), findsWidgets);
    expect(find.text('Alur & Analisis Kategori'), findsOneWidget);
    expect(find.text('Tren 6 Bulan Terakhir'), findsOneWidget);
    expect(find.text('Alur Sumber Dana (Dompet)'), findsOneWidget);
    expect(find.text('Pola Belanja (#Tag)'), findsOneWidget);
    expect(find.text('#ngopi'), findsOneWidget);
    expect(find.text('#makan-siang'), findsOneWidget);
    expect(find.text('Riwayat Transaksi'), findsOneWidget);
    expect(find.text('Makan Siang Bareng'), findsWidgets);
    expect(find.text('Kopi Kenangan Senja'), findsOneWidget);
  });
}
