import 'package:drift/drift.dart';

import 'accounts_table.dart';
import 'categories_table.dart';

/// A recurring installment plan (cicilan) — e.g. paying off a phone or
/// appliance in fixed monthly amounts over a fixed number of months.
class Installments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get totalAmountCents => integer()();
  IntColumn get tenorMonths => integer()();
  IntColumn get installmentAmountCents => integer()();
  IntColumn get paidInstallments => integer().withDefault(const Constant(0))();
  IntColumn get paidAmountCents => integer().withDefault(const Constant(0))();
  DateTimeColumn get startDate => dateTime()();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  TextColumn get note => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('active'))(); // 'active' | 'completed'
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
