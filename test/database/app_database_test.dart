import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';

void main() {
  test('AppDatabase automatically seeds accounts, categories, and transactions', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final accounts = await db.select(db.accounts).get();
    expect(accounts.length, equals(4));
    expect(accounts.map((a) => a.name), containsAll(['BCA', 'Mandiri', 'GoPay', 'Dompet Tunai']));

    final categories = await db.select(db.categories).get();
    expect(categories.length, greaterThanOrEqualTo(10));
    expect(categories.any((c) => c.type == 'income'), isTrue);
    expect(categories.any((c) => c.type == 'expense'), isTrue);

    final transactions = await db.select(db.transactions).get();
    expect(transactions.length, greaterThanOrEqualTo(15));
  });
}
