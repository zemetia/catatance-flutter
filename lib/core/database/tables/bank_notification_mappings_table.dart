import 'package:drift/drift.dart';

import 'accounts_table.dart';

/// Maps a notification source (Android package name, e.g. `com.bca.mobile`)
/// to the wallet its captured notifications should post transactions
/// against — the setting behind "Tangkap Notifikasi Bank".
class BankNotificationMappings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()();
  TextColumn get appLabel => text()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {packageName},
  ];
}
