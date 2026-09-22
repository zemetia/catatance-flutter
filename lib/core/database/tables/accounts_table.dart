import 'package:drift/drift.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // cash, bank, e-wallet, card, savings, other
  IntColumn get initialBalanceCents =>
      integer().withDefault(const Constant(0))();
  IntColumn get colorValue =>
      integer().withDefault(const Constant(0xFFC6FF3D))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
