import 'package:drift/drift.dart' show Value;
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

  test('TransactionRepository getItem returns item by id or null if not found', () async {
    final notFound = await repository.getItem(999999);
    expect(notFound, isNull);

    final accounts = await db.select(db.accounts).get();
    final categories = await db.select(db.categories).get();

    final id = await repository.insert(
      accountId: accounts.first.id,
      categoryId: categories.first.id,
      amountCents: 50000,
      note: 'Test getItem',
      date: DateTime(2026, 10, 31, 10, 0),
    );

    final item = await repository.getItem(id);
    expect(item, isNotNull);
    expect(item!.id, id);
    expect(item.note, 'Test getItem');
    expect(item.amountCents, 50000);
    expect(item.accountId, accounts.first.id);
    expect(item.categoryId, categories.first.id);
  });

  group('edit & delete keep balances in step', () {
    late int walletA;
    late int walletB;
    late int expenseCat;
    late int otherExpenseCat;
    late int incomeCat;

    Future<int> balance(int id) async => (await (db.select(db.accounts)
              ..where((a) => a.id.equals(id)))
            .getSingle())
        .initialBalanceCents;

    Future<int> goalSaved(int id) async => (await (db.select(db.savingsGoals)
              ..where((g) => g.id.equals(id)))
            .getSingle())
        .currentAmountCents;

    setUp(() async {
      final accounts = await db.select(db.accounts).get();
      walletA = accounts[0].id;
      walletB = accounts[1].id;
      final expenses = await (db.select(db.categories)
            ..where((c) => c.type.equals('expense')))
          .get();
      expenseCat = expenses[0].id;
      otherExpenseCat = expenses[1].id;
      incomeCat = (await (db.select(db.categories)
                ..where((c) => c.type.equals('income')))
              .get())
          .first
          .id;
      for (final id in [walletA, walletB]) {
        await (db.update(db.accounts)..where((a) => a.id.equals(id))).write(
          const AccountsCompanion(initialBalanceCents: Value(1000000)),
        );
      }
    });

    test('delete gives an expense back to its wallet', () async {
      final id = await repository.insert(
        accountId: walletA,
        categoryId: expenseCat,
        amountCents: 250000,
        date: DateTime(2026, 10, 1),
      );
      expect(await balance(walletA), 750000);

      await repository.delete(id);

      expect(await balance(walletA), 1000000);
      expect(await db.select(db.transactions).get().then(
            (rows) => rows.any((t) => t.id == id),
          ), isFalse);
    });

    test('changing the wallet moves the nominal from A to B', () async {
      final id = await repository.insert(
        accountId: walletA,
        categoryId: expenseCat,
        amountCents: 300000,
        date: DateTime(2026, 10, 1),
      );
      expect(await balance(walletA), 700000);

      await repository.update(
        id: id,
        accountId: walletB,
        categoryId: expenseCat,
        amountCents: 300000,
        date: DateTime(2026, 10, 1),
      );

      expect(await balance(walletA), 1000000); // refunded U
      expect(await balance(walletB), 700000); // charged U
    });

    test('changing the nominal adjusts the same wallet by the difference',
        () async {
      final id = await repository.insert(
        accountId: walletA,
        categoryId: expenseCat,
        amountCents: 100000,
        date: DateTime(2026, 10, 1),
      );

      await repository.update(
        id: id,
        accountId: walletA,
        categoryId: expenseCat,
        amountCents: 350000,
        date: DateTime(2026, 10, 1),
      );
      expect(await balance(walletA), 650000);

      await repository.update(
        id: id,
        accountId: walletA,
        categoryId: expenseCat,
        amountCents: 40000,
        date: DateTime(2026, 10, 1),
      );
      expect(await balance(walletA), 960000);
    });

    test('changing wallet and nominal together applies both', () async {
      final id = await repository.insert(
        accountId: walletA,
        categoryId: expenseCat,
        amountCents: 100000,
        date: DateTime(2026, 10, 1),
      );

      await repository.update(
        id: id,
        accountId: walletB,
        categoryId: expenseCat,
        amountCents: 400000,
        date: DateTime(2026, 10, 1),
      );

      expect(await balance(walletA), 1000000);
      expect(await balance(walletB), 600000);
    });

    test('changing category within a type leaves balances untouched and '
        'changing expense → income flips the sign', () async {
      final id = await repository.insert(
        accountId: walletA,
        categoryId: expenseCat,
        amountCents: 200000,
        date: DateTime(2026, 10, 1),
      );

      await repository.update(
        id: id,
        accountId: walletA,
        categoryId: otherExpenseCat,
        amountCents: 200000,
        date: DateTime(2026, 10, 1),
      );
      expect(await balance(walletA), 800000);

      await repository.update(
        id: id,
        accountId: walletA,
        categoryId: incomeCat,
        amountCents: 200000,
        date: DateTime(2026, 10, 1),
      );
      expect(await balance(walletA), 1200000);
    });

    test('changing the date and note does not move any money', () async {
      final id = await repository.insert(
        accountId: walletA,
        categoryId: expenseCat,
        amountCents: 200000,
        note: 'lama',
        date: DateTime(2026, 10, 1),
      );

      await repository.update(
        id: id,
        accountId: walletA,
        categoryId: expenseCat,
        amountCents: 200000,
        note: 'baru',
        date: DateTime(2026, 9, 15),
      );

      final row = await (db.select(db.transactions)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      expect(row.note, 'baru');
      expect(row.date, DateTime(2026, 9, 15));
      expect(await balance(walletA), 800000);
    });

    test('changing the savings target moves the saved amount between goals',
        () async {
      final goalOne = await db.into(db.savingsGoals).insert(
            SavingsGoalsCompanion.insert(
              name: 'Liburan',
              targetAmountCents: 5000000,
            ),
          );
      final goalTwo = await db.into(db.savingsGoals).insert(
            SavingsGoalsCompanion.insert(
              name: 'Laptop',
              targetAmountCents: 9000000,
            ),
          );

      final id = await repository.insert(
        accountId: walletA,
        categoryId: incomeCat,
        amountCents: 500000,
        date: DateTime(2026, 10, 1),
        savingsGoalId: goalOne,
      );
      expect(await goalSaved(goalOne), 500000);
      expect(await balance(walletA), 1500000);

      // Re-point to another goal with a different nominal.
      await repository.update(
        id: id,
        accountId: walletA,
        categoryId: incomeCat,
        amountCents: 700000,
        date: DateTime(2026, 10, 1),
        savingsGoalId: goalTwo,
      );
      expect(await goalSaved(goalOne), 0);
      expect(await goalSaved(goalTwo), 700000);
      expect(await balance(walletA), 1700000);

      // Removing the target releases the goal but keeps the income.
      await repository.update(
        id: id,
        accountId: walletA,
        categoryId: incomeCat,
        amountCents: 700000,
        date: DateTime(2026, 10, 1),
      );
      expect(await goalSaved(goalTwo), 0);
      expect(await balance(walletA), 1700000);

      // Re-add, then delete: wallet and goal both roll back.
      await repository.update(
        id: id,
        accountId: walletA,
        categoryId: incomeCat,
        amountCents: 700000,
        date: DateTime(2026, 10, 1),
        savingsGoalId: goalTwo,
      );
      await repository.delete(id);
      expect(await goalSaved(goalTwo), 0);
      expect(await balance(walletA), 1000000);
    });

    test('a single-row transfer is reversed on both wallets when deleted',
        () async {
      final transferCat = await (db.select(db.categories)
            ..where((c) => c.type.equals('transfer')))
          .getSingle();
      final id = await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              accountId: walletA,
              categoryId: transferCat.id,
              amountCents: 200000,
              date: DateTime(2026, 10, 1),
              toAccountId: Value(walletB),
              toAmountCents: const Value(180000),
            ),
          );
      await (db.update(db.accounts)..where((a) => a.id.equals(walletA)))
          .write(const AccountsCompanion(initialBalanceCents: Value(800000)));
      await (db.update(db.accounts)..where((a) => a.id.equals(walletB)))
          .write(const AccountsCompanion(initialBalanceCents: Value(1180000)));

      await repository.delete(id);

      expect(await balance(walletA), 1000000);
      expect(await balance(walletB), 1000000);
    });

    test('transfers refuse a money edit but allow date and note', () async {
      final transferCat = await (db.select(db.categories)
            ..where((c) => c.type.equals('transfer')))
          .getSingle();
      final id = await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              accountId: walletA,
              categoryId: transferCat.id,
              amountCents: 200000,
              date: DateTime(2026, 10, 1),
              toAccountId: Value(walletB),
            ),
          );

      expect(
        () => repository.update(
          id: id,
          accountId: walletA,
          categoryId: expenseCat,
          amountCents: 1,
          date: DateTime(2026, 10, 1),
        ),
        throwsStateError,
      );

      await repository.updateNoteAndDate(
        id: id,
        note: 'ganti catatan',
        date: DateTime(2026, 9, 1),
      );
      final row = await (db.select(db.transactions)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      expect(row.note, 'ganti catatan');
      expect(await balance(walletA), 1000000);
    });

    test('a cicilan payment cannot be edited or deleted from the ledger',
        () async {
      final installmentId = await db.into(db.installments).insert(
            InstallmentsCompanion.insert(
              name: 'HP',
              totalAmountCents: 1200000,
              installmentAmountCents: 100000,
              tenorMonths: 12,
              startDate: DateTime(2026, 10, 1),
            ),
          );
      final txId = await repository.insert(
        accountId: walletA,
        categoryId: expenseCat,
        amountCents: 100000,
        date: DateTime(2026, 10, 1),
      );
      await db.into(db.installmentPayments).insert(
            InstallmentPaymentsCompanion.insert(
              installmentId: installmentId,
              amountCents: 100000,
              paymentDate: DateTime(2026, 10, 1),
              transactionId: Value(txId),
            ),
          );

      expect(await repository.lockReason(txId), isNotNull);
      expect(() => repository.delete(txId), throwsStateError);
      expect(
        () => repository.update(
          id: txId,
          accountId: walletA,
          categoryId: expenseCat,
          amountCents: 5,
          date: DateTime(2026, 10, 1),
        ),
        throwsStateError,
      );
      expect(await balance(walletA), 900000);
    });
  });
}
