import 'package:drift/drift.dart';

import 'accounts_table.dart';
import 'transactions_table.dart';

/// A raw notification captured from a mapped bank/e-wallet app, with its
/// parsed nominal/direction guess, waiting for the user to confirm (or
/// dismiss) it into a real [Transactions] row — parsing bank notification
/// text is heuristic, so nothing here is written to the ledger directly.
class CapturedBankNotifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()();
  TextColumn get appLabel => text()();
  TextColumn get title => text().nullable()();
  TextColumn get content => text()();
  IntColumn get parsedAmountCents => integer().nullable()();
  TextColumn get direction => text().nullable()(); // 'income' | 'expense'
  IntColumn get accountId =>
      integer().nullable().references(Accounts, #id)();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // pending|confirmed|dismissed
  IntColumn get transactionId =>
      integer().nullable().references(Transactions, #id)();
  TextColumn get dedupeKey => text()();
  DateTimeColumn get postedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {dedupeKey},
  ];
}
