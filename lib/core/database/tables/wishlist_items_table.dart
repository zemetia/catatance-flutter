import 'package:drift/drift.dart';

class WishlistItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get estimatedPriceCents => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get url => text().nullable()();
  IntColumn get coolingDays => integer().withDefault(const Constant(30))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get readyAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('cooling_off'))();
  DateTimeColumn get decisionDate => dateTime().nullable()();
  TextColumn get decisionNote => text().nullable()();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  TextColumn get categoryName => text().nullable()();
  TextColumn get iconKey => text().withDefault(const Constant('shopping-bag'))();
  IntColumn get savedAmountCents => integer().withDefault(const Constant(0))();
}
