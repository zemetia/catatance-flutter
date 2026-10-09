import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pencatatan_keuangan/features/transactions/domain/transaction_item.dart';
import 'package:pencatatan_keuangan/features/transactions/presentation/widgets/transaction_detail_sheet.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  final testItem = TransactionItem(
    id: 123,
    accountId: 1,
    accountName: 'BCA Utama',
    accountCurrencyCode: 'IDR',
    categoryId: 2,
    categoryName: 'Makanan & Minuman',
    categoryIcon: 'utensils',
    categoryType: 'expense',
    categoryColorValue: 0xFFFF5722,
    amountCents: 50000,
    note: 'Makan siang bareng teman',
    date: DateTime(2026, 10, 7, 12, 30),
    createdAt: DateTime(2026, 10, 7, 12, 30),
  );

  final transferItem = TransactionItem(
    id: 124,
    accountId: 1,
    accountName: 'BCA Utama',
    accountCurrencyCode: 'IDR',
    categoryId: 3,
    categoryName: 'Transfer',
    categoryIcon: 'arrow-left-right',
    categoryType: 'transfer',
    categoryColorValue: 0xFF2196F3,
    amountCents: 200000,
    note: 'Pindah ke tabungan',
    date: DateTime(2026, 10, 7, 14, 0),
    createdAt: DateTime(2026, 10, 7, 14, 0),
    toAccountName: 'Kantong Jago',
  );

  Widget createWidget(TransactionItem item) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: TransactionDetailSheet(item: item),
        ),
      ),
    );
  }

  testWidgets('TransactionDetailSheet renders expense details correctly',
      (tester) async {
    await tester.pumpWidget(createWidget(testItem));
    await tester.pumpAndSettle();

    // Verify type badge and amount
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.textContaining('50.000'), findsOneWidget);

    // Verify category and account details
    expect(find.text('Makanan & Minuman'), findsWidgets);
    expect(find.text('BCA Utama'), findsOneWidget);
    expect(find.text('Makan siang bareng teman'), findsWidgets);

    // Verify action button
    expect(find.text('Hapus Transaksi'), findsOneWidget);
    expect(find.byIcon(LucideIcons.trash), findsOneWidget);
  });

  testWidgets('TransactionDetailSheet renders transfer details correctly',
      (tester) async {
    await tester.pumpWidget(createWidget(transferItem));
    await tester.pumpAndSettle();

    // Verify type badge and amount
    expect(find.text('Transfer'), findsWidgets);
    expect(find.textContaining('200.000'), findsOneWidget);

    // Verify source and destination account
    expect(find.text('Dari Rekening'), findsOneWidget);
    expect(find.text('BCA Utama'), findsOneWidget);
    expect(find.text('Ke Rekening'), findsOneWidget);
    expect(find.text('Kantong Jago'), findsOneWidget);
  });
}
