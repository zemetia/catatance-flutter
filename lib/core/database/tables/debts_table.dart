import 'package:drift/drift.dart';

import 'accounts_table.dart';
import 'split_bills_table.dart';

/// Represents debts (utang) and receivables (piutang).
/// - type: 'debt' (Utang saya / Pinjaman yang harus saya bayar ke orang lain)
/// - type: 'receivable' (Piutang saya / Pinjaman yang orang lain harus bayar ke saya)
class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // 'debt' | 'receivable'
  TextColumn get personName => text()();
  IntColumn get amountCents => integer()();
  IntColumn get paidAmountCents =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get status =>
      text().withDefault(const Constant('unpaid'))(); // 'unpaid' | 'paid'
  TextColumn get note => text().nullable()();
  IntColumn get accountId =>
      integer().nullable().references(Accounts, #id)();

  /// Set when this receivable was auto-generated from a patungan (split
  /// bill) participant share, linking it back to the `SplitBills` row.
  IntColumn get splitBillId =>
      integer().nullable().references(SplitBills, #id)();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
