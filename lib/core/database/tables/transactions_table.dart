import 'package:drift/drift.dart';

import 'accounts_table.dart';
import 'categories_table.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get amountCents =>
      integer()(); // always positive; sign from category.type
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Destination wallet for a `transfer`-type transaction — `accountId` is
  /// the source wallet it's debited from. Null for every non-transfer row.
  IntColumn get toAccountId => integer().nullable().references(Accounts, #id)();

  /// The amount credited to [toAccountId], in its own currency, when it
  /// differs from [amountCents] (a cross-currency transfer). Null means
  /// "same as amountCents" — most transfers share one currency.
  IntColumn get toAmountCents => integer().nullable()();
}
