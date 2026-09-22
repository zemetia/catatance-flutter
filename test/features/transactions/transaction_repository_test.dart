import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';
import 'package:pencatatan_keuangan/features/transactions/data/transaction_repository.dart';

void main() {
  late AppDatabase db;
  late TransactionRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = TransactionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('TransactionRepository watches recent transactions from seed data', () async {
    final list = await repository.watchRecent().first;
    expect(list, isNotEmpty);
    expect(list.first.accountName, isNotEmpty);
    expect(list.first.categoryName, isNotEmpty);
    expect(list.first.amountCents, greaterThan(0));
  });

  test('TransactionRepository can insert and query a new transaction', () async {
    final accounts = await db.select(db.accounts).get();
    final categories = await db.select(db.categories).get();

    final id = await repository.insert(
      accountId: accounts.first.id,
      categoryId: categories.first.id,
      amountCents: 75000,
      note: 'Uji Coba Transaksi Baru',
      date: DateTime.now(),
    );

    expect(id, greaterThan(0));

    final recent = await repository.watchRecent().first;
    expect(recent.any((t) => t.id == id && t.note == 'Uji Coba Transaksi Baru'), isTrue);
  });

  test('TransactionRepository can delete a transaction', () async {
    final recent = await repository.watchRecent().first;
    final firstId = recent.first.id;

    final deletedCount = await repository.delete(firstId);
    expect(deletedCount, equals(1));

    final afterDelete = await repository.watchRecent().first;
    expect(afterDelete.any((t) => t.id == firstId), isFalse);
  });
}
