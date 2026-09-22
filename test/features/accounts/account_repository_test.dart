import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';
import 'package:pencatatan_keuangan/features/accounts/data/account_repository.dart';

void main() {
  late AppDatabase db;
  late AccountRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = AccountRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('AccountRepository watches all seeded accounts', () async {
    final list = await repository.watchAll().first;
    expect(list.length, equals(4));
    expect(list.map((a) => a.name), containsAll(['BCA', 'Mandiri', 'GoPay', 'Dompet Tunai']));
    expect(list.every((a) => a.balanceCents > 0), isTrue);
  });
}
