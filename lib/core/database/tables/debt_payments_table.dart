import 'package:drift/drift.dart';

import 'accounts_table.dart';
import 'debts_table.dart';
import 'transactions_table.dart';

/// Represents payment logs/installments for a debt or receivable. When
/// [accountId] is set (optional — a payment can be logged without a wallet),
/// the payment also debits/credits that wallet and inserts a real
/// [Transactions] row (linked via [transactionId]) so the payment shows up
/// in Transaksi/Laporan/Dasbor, mirroring [InstallmentPayments].
class DebtPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get debtId => integer().references(Debts, #id)();
  IntColumn get amountCents => integer()();
  DateTimeColumn get paymentDate => dateTime()();
  IntColumn get accountId =>
      integer().nullable().references(Accounts, #id)();
  IntColumn get transactionId =>
      integer().nullable().references(Transactions, #id)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
