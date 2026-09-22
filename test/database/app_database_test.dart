import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';

void main() {
  test('AppDatabase can be created and queried in memory', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final accounts = await db.select(db.accounts).get();
    expect(accounts, isEmpty);
  });
}
