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

  test('CategoryRepository includes Bisnis, Jajan, and AI expense categories', () async {
    final expenses = await repository.watchByType('expense').first;
    final names = expenses.map((c) => c.name).toSet();

    expect(names, contains('Bisnis'));
    expect(names, contains('Jajan'));
    expect(names, contains('AI'));
  });

  test('CategoryRepository auto sorts by usageCount DESC and updates reactively', () async {
    final initialExpenses = await repository.watchByType('expense').first;
    expect(initialExpenses, isNotEmpty);

    // Verify list is sorted by usageCount DESC
    for (var i = 0; i < initialExpenses.length - 1; i++) {
      expect(
        initialExpenses[i].usageCount >= initialExpenses[i + 1].usageCount,
        isTrue,
        reason: 'Category ${initialExpenses[i].name} (${initialExpenses[i].usageCount}) should be >= ${initialExpenses[i + 1].name} (${initialExpenses[i + 1].usageCount})',
      );
    }

    // Pick a category with 0 usage (e.g. AI or Jajan)
    final aiCategory = initialExpenses.firstWhere((c) => c.name == 'AI');
    final initialUsage = aiCategory.usageCount;

    // Get an account to record transactions
    final account = (await db.select(db.accounts).get()).first;

    // Insert 50 transactions for AI category
    for (var i = 0; i < 50; i++) {
      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              accountId: account.id,
              categoryId: aiCategory.id,
              amountCents: 10000,
              date: DateTime.now(),
            ),
          );
    }

    // Now watch categories again
    final updatedExpenses = await repository.watchByType('expense').first;
    expect(updatedExpenses.first.name, equals('AI'));
    expect(updatedExpenses.first.usageCount, equals(initialUsage + 50));
  });
}
