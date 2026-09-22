import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';

void main() {
  test('NativeDatabase with file works and seeds initial data', () async {
    final tempDir = await Directory.systemTemp.createTemp('pk_db_test_');
    final dbFile = File('${tempDir.path}/test.sqlite');
    final db = AppDatabase(NativeDatabase(dbFile));
    addTearDown(() async {
      await db.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final accounts = await db.select(db.accounts).get();
    expect(accounts, isNotEmpty);
    expect(accounts.length, equals(4));
  });
}
