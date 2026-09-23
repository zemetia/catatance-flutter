import 'package:drift/drift.dart';

import 'installments_table.dart';
import 'transactions_table.dart';

/// A single recorded installment payment. When the parent [Installments] row
/// has both an `accountId` and `categoryId`, paying an installment also
/// deducts the wallet balance and inserts a real [Transactions] row (linked
/// via [transactionId]) so the payment shows up in Transaksi/Laporan/Dasbor.
class InstallmentPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get installmentId => integer().references(Installments, #id)();
  IntColumn get amountCents => integer()();
  DateTimeColumn get paymentDate => dateTime()();
  IntColumn get transactionId =>
      integer().nullable().references(Transactions, #id)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
