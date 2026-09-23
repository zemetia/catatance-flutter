import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';
import 'package:pencatatan_keuangan/features/savings_goals/data/savings_goal_repository.dart';

void main() {
  late AppDatabase db;
  late SavingsGoalRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = SavingsGoalRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('watchAll loads seeded savings goals correctly', () async {
    final list = await repository.watchAll().first;
    expect(list.length, equals(3));

    final bali = list.firstWhere((g) => g.name == 'Liburan Bali');
    expect(bali.targetAmountCents, equals(10000000));
    expect(bali.currentAmountCents, equals(4500000));
    expect(bali.autoSaveEnabled, isTrue);
    expect(bali.autoSaveAmountCents, equals(500000));
    expect(bali.iconKey, equals('plane'));

    final laptop = list.firstWhere((g) => g.name == 'Beli Laptop Baru');
    expect(laptop.targetAmountCents, equals(18000000));
    expect(laptop.currentAmountCents, equals(12000000));
    expect(laptop.autoSaveEnabled, isFalse);

    final emergency = list.firstWhere((g) => g.name == 'Dana Darurat');
    expect(emergency.targetAmountCents, equals(30000000));
    expect(emergency.targetDate, isNull);
    expect(emergency.autoSaveEnabled, isTrue);
  });

  test('insert creates a new savings goal and assigns an id', () async {
    final id = await repository.insert(
      const SavingsGoalDraft(
        name: 'Umroh Keluarga',
        iconKey: 'hajj',
        gradientIndex: 1,
        targetAmountCents: 65000000,
        currentAmountCents: 5000000,
        autoSaveEnabled: true,
        autoSaveAmountCents: 2000000,
        autoSaveFrequency: 'monthly',
        note: 'Bismillah target berangkat tahun depan',
      ),
    );

    expect(id, isPositive);
    final fetched = await repository.getGoal(id);
    expect(fetched, isNotNull);
    expect(fetched!.name, equals('Umroh Keluarga'));
    expect(fetched.targetAmountCents, equals(65000000));
    expect(fetched.currentAmountCents, equals(5000000));
    expect(fetched.autoSaveEnabled, isTrue);
    expect(fetched.autoSaveAmountCents, equals(2000000));
  });

  test('insert with initial deposit deducts balance from source wallet', () async {
    // Get BCA wallet (seeded with 12.500.000)
    final bca = await (db.select(db.accounts)..where((a) => a.name.equals('BCA'))).getSingle();
    final initialBcaBalance = bca.initialBalanceCents;

    final id = await repository.insert(
      SavingsGoalDraft(
        name: 'Gitar Listrik',
        iconKey: 'gift',
        gradientIndex: 3,
        targetAmountCents: 8000000,
        currentAmountCents: 1500000,
        sourceAccountId: bca.id,
      ),
    );

    expect(id, isPositive);
    final updatedBca = await (db.select(db.accounts)..where((a) => a.id.equals(bca.id))).getSingle();
    expect(updatedBca.initialBalanceCents, equals(initialBcaBalance - 1500000));
  });

  test('insert validates required name and positive target amount', () async {
    expect(
      () => repository.insert(
        const SavingsGoalDraft(
          name: '',
          targetAmountCents: 5000000,
        ),
      ),
      throwsArgumentError,
    );

    expect(
      () => repository.insert(
        const SavingsGoalDraft(
          name: 'Target Negatif',
          targetAmountCents: -100,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('update modifies goal properties properly', () async {
    final list = await repository.watchAll().first;
    final target = list.first;

    await repository.update(
      target.id,
      const SavingsGoalDraft(
        name: 'Liburan Bali & Lombok (Diperbarui)',
        iconKey: 'beach',
        gradientIndex: 4,
        targetAmountCents: 15000000,
        autoSaveEnabled: true,
        autoSaveAmountCents: 750000,
        autoSaveFrequency: 'weekly',
      ),
    );

    final updated = await repository.getGoal(target.id);
    expect(updated!.name, equals('Liburan Bali & Lombok (Diperbarui)'));
    expect(updated.targetAmountCents, equals(15000000));
    expect(updated.autoSaveAmountCents, equals(750000));
    expect(updated.autoSaveFrequency, equals('weekly'));
    // Current amount should be preserved
    expect(updated.currentAmountCents, equals(target.currentAmountCents));
  });

  test('delete removes the goal', () async {
    final list = await repository.watchAll().first;
    final target = list.first;

    await repository.delete(target.id);
    final fetched = await repository.getGoal(target.id);
    expect(fetched, isNull);
  });

  test('deposit adds to savings goal and deducts from wallet', () async {
    final list = await repository.watchAll().first;
    final bali = list.firstWhere((g) => g.name == 'Liburan Bali');
    final bca = await (db.select(db.accounts)..where((a) => a.name.equals('BCA'))).getSingle();

    final prevSaved = bali.currentAmountCents;
    final prevBca = bca.initialBalanceCents;

    await repository.deposit(bali.id, 500000, sourceAccountId: bca.id);

    final updatedBali = await repository.getGoal(bali.id);
    expect(updatedBali!.currentAmountCents, equals(prevSaved + 500000));

    final updatedBca = await (db.select(db.accounts)..where((a) => a.id.equals(bca.id))).getSingle();
    expect(updatedBca.initialBalanceCents, equals(prevBca - 500000));
  });

  test('withdraw reduces savings goal and refunds wallet', () async {
    final list = await repository.watchAll().first;
    final bali = list.firstWhere((g) => g.name == 'Liburan Bali');
    final bca = await (db.select(db.accounts)..where((a) => a.name.equals('BCA'))).getSingle();

    final prevSaved = bali.currentAmountCents;
    final prevBca = bca.initialBalanceCents;

    await repository.withdraw(bali.id, 300000, targetAccountId: bca.id);

    final updatedBali = await repository.getGoal(bali.id);
    expect(updatedBali!.currentAmountCents, equals(prevSaved - 300000));

    final updatedBca = await (db.select(db.accounts)..where((a) => a.id.equals(bca.id))).getSingle();
    expect(updatedBca.initialBalanceCents, equals(prevBca + 300000));
  });

  test('toggleAutoSave and executeAutoSave run correctly', () async {
    final list = await repository.watchAll().first;
    final laptop = list.firstWhere((g) => g.name == 'Beli Laptop Baru');
    expect(laptop.autoSaveEnabled, isFalse);

    // Toggle on
    await repository.toggleAutoSave(laptop.id, true);
    var updated = await repository.getGoal(laptop.id);
    expect(updated!.autoSaveEnabled, isTrue);

    // Toggle off
    await repository.toggleAutoSave(laptop.id, false);
    updated = await repository.getGoal(laptop.id);
    expect(updated!.autoSaveEnabled, isFalse);

    // Execute autosave on Bali (has autosave enabled with 500k)
    final bali = list.firstWhere((g) => g.name == 'Liburan Bali');
    final prevSaved = bali.currentAmountCents;
    final success = await repository.executeAutoSave(bali.id);
    expect(success, isTrue);

    final updatedBali = await repository.getGoal(bali.id);
    expect(updatedBali!.currentAmountCents, equals(prevSaved + bali.autoSaveAmountCents));
  });

  test('withdraw throws when amount exceeds current saved amount (prevents money creation glitch)', () async {
    final list = await repository.watchAll().first;
    final bali = list.firstWhere((g) => g.name == 'Liburan Bali');

    expect(
      () => repository.withdraw(
        bali.id,
        bali.currentAmountCents + 1000000,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('deposit throws when source wallet balance is insufficient', () async {
    final list = await repository.watchAll().first;
    final bali = list.firstWhere((g) => g.name == 'Liburan Bali');
    final bca = await (db.select(db.accounts)..where((a) => a.name.equals('BCA'))).getSingle();

    expect(
      () => repository.deposit(
        bali.id,
        bca.initialBalanceCents + 5000000,
        sourceAccountId: bca.id,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('insert throws when initial deposit exceeds wallet balance', () async {
    final bca = await (db.select(db.accounts)..where((a) => a.name.equals('BCA'))).getSingle();

    expect(
      () => repository.insert(
        SavingsGoalDraft(
          name: 'Target Terlalu Mahal',
          targetAmountCents: 100000000,
          currentAmountCents: bca.initialBalanceCents + 1000000,
          sourceAccountId: bca.id,
        ),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('executeAutoSave returns false when source wallet balance is insufficient', () async {
    // Create a goal with autosave greater than wallet balance
    final cash = await (db.select(db.accounts)..where((a) => a.name.equals('Dompet Tunai'))).getSingle();

    final goalId = await repository.insert(
      SavingsGoalDraft(
        name: 'Target Autosave Besar',
        targetAmountCents: 50000000,
        autoSaveEnabled: true,
        autoSaveAmountCents: cash.initialBalanceCents + 500000,
        sourceAccountId: cash.id,
      ),
    );

    final success = await repository.executeAutoSave(goalId);
    expect(success, isFalse);

    // Goal and wallet balances should remain unchanged
    final goal = await repository.getGoal(goalId);
    expect(goal!.currentAmountCents, equals(0));

    final cashAfter = await (db.select(db.accounts)..where((a) => a.id.equals(cash.id))).getSingle();
    expect(cashAfter.initialBalanceCents, equals(cash.initialBalanceCents));
  });
}
