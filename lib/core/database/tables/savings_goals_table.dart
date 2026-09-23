import 'package:drift/drift.dart';

import 'accounts_table.dart';

class SavingsGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get iconKey => text().withDefault(const Constant('plane'))();
  IntColumn get gradientIndex => integer().withDefault(const Constant(0))();
  IntColumn get targetAmountCents => integer()();
  IntColumn get currentAmountCents => integer().withDefault(const Constant(0))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  BoolColumn get autoSaveEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get autoSaveAmountCents => integer().withDefault(const Constant(0))();
  TextColumn get autoSaveFrequency =>
      text().withDefault(const Constant('monthly'))(); // daily | weekly | monthly
  IntColumn get sourceAccountId =>
      integer().nullable().references(Accounts, #id)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
