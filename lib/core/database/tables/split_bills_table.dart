import 'package:drift/drift.dart';

import 'transactions_table.dart';

/// Represents a patungan (group bill) event: the single expense
/// transaction the payer actually paid, and how it was divided between
/// the payer and named participants. Each participant's share is
/// persisted separately as a `receivable` row in `Debts` (linked back via
/// `Debts.splitBillId`) so repayment tracking reuses the existing
/// Utang & Piutang flow instead of duplicating it here.
class SplitBills extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().references(Transactions, #id)();
  IntColumn get totalAmountCents => integer()();

  /// Whether the payer's own share is included in the split (vs. the
  /// payer only fronting money for other people).
  BoolColumn get payerIncluded =>
      boolean().withDefault(const Constant(true))();

  /// The payer's own share, already excluded from participants' shares.
  IntColumn get payerShareCents =>
      integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
