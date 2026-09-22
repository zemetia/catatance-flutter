import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';
import 'package:pencatatan_keuangan/features/categories/data/category_repository.dart';

void main() {
  late AppDatabase db;
  late CategoryRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = CategoryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('CategoryRepository watches all seeded categories', () async {
    final list = await repository.watchAll().first;
    expect(list.length, greaterThanOrEqualTo(10));
  });

  test('CategoryRepository filters categories by type', () async {
    final expenses = await repository.watchByType('expense').first;
    final incomes = await repository.watchByType('income').first;

    expect(expenses, isNotEmpty);
    expect(incomes, isNotEmpty);
    expect(expenses.every((c) => c.type == 'expense'), isTrue);
    expect(incomes.every((c) => c.type == 'income'), isTrue);
  });
}
