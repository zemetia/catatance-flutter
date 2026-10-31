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

  test('AccountRepository transfer records transaction and fee on custom date', () async {
    final accounts = await repository.watchAll().first;
    final from = accounts[0];
    final to = accounts[1];
    final customDate = DateTime(2026, 8, 15, 10, 30);
    final categories = await db.select(db.categories).get();
    final feeCat = categories.firstWhere((c) => c.name == 'Biaya Admin Transfer');

    await repository.transfer(
      fromId: from.id,
      toId: to.id,
      amountCents: 50000,
      convertedAmountCents: 50000,
      feeCents: 2500,
      feeCategoryId: feeCat.id,
      date: customDate,
    );

    final txs = await db.select(db.transactions).get();
    final transferTx = txs.firstWhere((t) => t.toAccountId == to.id);
    expect(transferTx.date, customDate);
    expect(transferTx.amountCents, 50000);

    final feeTx = txs.firstWhere((t) => t.categoryId == feeCat.id);
    expect(feeTx.date, customDate);
    expect(feeTx.amountCents, 2500);
  });
}
