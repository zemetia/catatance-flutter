import 'package:drift/drift.dart';

import 'categories_table.dart';

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get limitCents => integer()();
  TextColumn get periodType =>
      text().withDefault(const Constant('monthly'))(); // monthly | weekly | custom
  DateTimeColumn get customStartDate => dateTime().nullable()();
  DateTimeColumn get customEndDate => dateTime().nullable()();
  BoolColumn get carryOverEnabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
