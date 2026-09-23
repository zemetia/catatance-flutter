import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';
import 'package:pencatatan_keuangan/features/debts/data/debt_repository.dart';
import 'package:pencatatan_keuangan/features/debts/domain/debt_type.dart';

void main() {
  late AppDatabase db;
  late DebtRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DebtRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('watchAll loads seeded debts and receivables correctly', () async {
    final list = await repository.watchAll().first;
    expect(list.length, equals(4));

    final sarah = list.firstWhere((d) => d.personName == 'Kak Sarah');
    expect(sarah.type, equals(DebtType.debt));
    expect(sarah.amountCents, equals(2500000));
    expect(sarah.paidAmountCents, equals(1000000));
    expect(sarah.remainingCents, equals(1500000));
    expect(sarah.status, equals(DebtStatus.unpaid));

    final budi = list.firstWhere((d) => d.personName == 'Budi Santoso');
    expect(budi.type, equals(DebtType.debt));
    expect(budi.isSettled, isTrue);
    expect(budi.status, equals(DebtStatus.paid));
  });

  test('insertDebt creates a new debt and assigns an id', () async {
    final newId = await repository.insertDebt(
      DebtDraft(
        type: DebtType.debt,
        personName: 'Pak RT',
        amountCents: 500000,
        transactionDate: DateTime.now(),
        note: 'Iuran renovasi lingkungan',
      ),
    );

    expect(newId, isPositive);
    final fetched = await repository.getDebt(newId);
    expect(fetched, isNotNull);
    expect(fetched!.personName, equals('Pak RT'));
    expect(fetched.amountCents, equals(500000));
    expect(fetched.paidAmountCents, equals(0));
    expect(fetched.remainingCents, equals(500000));
    expect(fetched.status, equals(DebtStatus.unpaid));
  });

  test('updateDebt updates fields properly', () async {
    final newId = await repository.insertDebt(
      DebtDraft(
        type: DebtType.receivable,
        personName: 'Andi',
        amountCents: 100000,
        transactionDate: DateTime.now(),
      ),
    );

    await repository.updateDebt(
      newId,
      DebtDraft(
        type: DebtType.receivable,
        personName: 'Andi Wijaya',
        amountCents: 150000,
        transactionDate: DateTime.now(),
        note: 'Pinjaman makan siang + bensin',
      ),
    );

    final updated = await repository.getDebt(newId);
    expect(updated!.personName, equals('Andi Wijaya'));
    expect(updated.amountCents, equals(150000));
    expect(updated.note, equals('Pinjaman makan siang + bensin'));
  });

  test('updateDebt preserves paidAmountCents and accountId when payments exist',
      () async {
    final debtId = await repository.insertDebt(
      DebtDraft(
        type: DebtType.debt,
        personName: 'Toko Elektronik',
        amountCents: 1000000,
        transactionDate: DateTime.now(),
        accountId: 1,
      ),
    );

    await repository.recordPayment(
      DebtPaymentDraft(
        debtId: debtId,
        amountCents: 400000,
        paymentDate: DateTime.now(),
        note: 'Cicilan 1',
      ),
    );

    var debtBefore = await repository.getDebt(debtId);
    expect(debtBefore!.paidAmountCents, equals(400000));
    expect(debtBefore.accountId, equals(1));

    // Edit debt without re-specifying paidAmountCents (simulating edit form)
    await repository.updateDebt(
      debtId,
      DebtDraft(
        type: DebtType.debt,
        personName: 'Toko Elektronik Modern',
        amountCents: 1000000,
        transactionDate: DateTime.now(),
        note: 'Ganti rincian toko',
      ),
    );

    final debtAfter = await repository.getDebt(debtId);
    expect(debtAfter!.personName, equals('Toko Elektronik Modern'));
    expect(debtAfter.paidAmountCents, equals(400000)); // Crucial: NOT reset to 0!
    expect(debtAfter.remainingCents, equals(600000));
    expect(debtAfter.status, equals(DebtStatus.unpaid));
    expect(debtAfter.accountId, equals(1)); // Crucial: NOT reset to null!
  });

  test('updateDebt allows explicit accountId change and clearAccount', () async {
    final debtId = await repository.insertDebt(
      DebtDraft(
        type: DebtType.receivable,
        personName: 'Rudi',
        amountCents: 500000,
        transactionDate: DateTime.now(),
        accountId: 1,
      ),
    );

    // Update accountId to 2
    await repository.updateDebt(
      debtId,
      DebtDraft(
        type: DebtType.receivable,
        personName: 'Rudi',
        amountCents: 500000,
        transactionDate: DateTime.now(),
        accountId: 2,
      ),
    );
    var debt = await repository.getDebt(debtId);
    expect(debt!.accountId, equals(2));

    // Clear account explicitly
    await repository.updateDebt(
      debtId,
      DebtDraft(
        type: DebtType.receivable,
        personName: 'Rudi',
        amountCents: 500000,
        transactionDate: DateTime.now(),
        clearAccount: true,
      ),
    );
    debt = await repository.getDebt(debtId);
    expect(debt!.accountId, isNull);
  });

  test('recordPayment updates paidAmountCents and auto-settles when complete',
      () async {
    final debtId = await repository.insertDebt(
      DebtDraft(
        type: DebtType.debt,
        personName: 'Toko Elektronik',
        amountCents: 1000000,
        transactionDate: DateTime.now(),
      ),
    );

    // 1. Partial payment of 400.000
    final payment1Id = await repository.recordPayment(
      DebtPaymentDraft(
        debtId: debtId,
        amountCents: 400000,
        paymentDate: DateTime.now(),
        note: 'Cicilan 1',
      ),
    );
    expect(payment1Id, isPositive);

    var debt = await repository.getDebt(debtId);
    expect(debt!.paidAmountCents, equals(400000));
    expect(debt.remainingCents, equals(600000));
    expect(debt.status, equals(DebtStatus.unpaid));
    expect(debt.isSettled, isFalse);

    // 2. Remaining payment of 600.000 (total = 1.000.000)
    await repository.recordPayment(
      DebtPaymentDraft(
        debtId: debtId,
        amountCents: 600000,
        paymentDate: DateTime.now(),
        note: 'Cicilan 2 pelunasan',
      ),
    );

    debt = await repository.getDebt(debtId);
    expect(debt!.paidAmountCents, equals(1000000));
    expect(debt.remainingCents, equals(0));
    expect(debt.status, equals(DebtStatus.paid));
    expect(debt.isSettled, isTrue);

    // 3. Check payments stream
    final payments = await repository.watchPaymentsForDebt(debtId).first;
    expect(payments.length, equals(2));
  });

  test('deletePayment recalculates paid amount and reverts status', () async {
    final debtId = await repository.insertDebt(
      DebtDraft(
        type: DebtType.receivable,
        personName: 'Citra',
        amountCents: 300000,
        transactionDate: DateTime.now(),
      ),
    );

    final paymentId = await repository.recordPayment(
      DebtPaymentDraft(
        debtId: debtId,
        amountCents: 300000,
        paymentDate: DateTime.now(),
      ),
    );

    var debt = await repository.getDebt(debtId);
    expect(debt!.isSettled, isTrue);

    // Delete payment
    await repository.deletePayment(paymentId);

    debt = await repository.getDebt(debtId);
    expect(debt!.paidAmountCents, equals(0));
    expect(debt.remainingCents, equals(300000));
    expect(debt.status, equals(DebtStatus.unpaid));
  });

  test('settleDebt marks debt as paid and inserts payment record', () async {
    final debtId = await repository.insertDebt(
      DebtDraft(
        type: DebtType.debt,
        personName: 'Koperasi',
        amountCents: 500000,
        transactionDate: DateTime.now(),
      ),
    );

    await repository.settleDebt(debtId, note: 'Pelunasan kontan');

    final debt = await repository.getDebt(debtId);
    expect(debt!.paidAmountCents, equals(500000));
    expect(debt.status, equals(DebtStatus.paid));

    final payments = await repository.watchPaymentsForDebt(debtId).first;
    expect(payments.length, equals(1));
    expect(payments.first.amountCents, equals(500000));
    expect(payments.first.note, equals('Pelunasan kontan'));
  });

  test('deleteDebt removes debt and cascades payments', () async {
    final debtId = await repository.insertDebt(
      DebtDraft(
        type: DebtType.debt,
        personName: 'Hapus Me',
        amountCents: 200000,
        transactionDate: DateTime.now(),
      ),
    );

    await repository.recordPayment(
      DebtPaymentDraft(
        debtId: debtId,
        amountCents: 50000,
        paymentDate: DateTime.now(),
      ),
    );

    await repository.deleteDebt(debtId);

    final debt = await repository.getDebt(debtId);
    expect(debt, isNull);

    final payments = await repository.watchPaymentsForDebt(debtId).first;
    expect(payments, isEmpty);
  });

  test('insertDebt rejects non-positive amount and empty person name', () async {
    expect(
      () => repository.insertDebt(
        DebtDraft(
          type: DebtType.debt,
          personName: 'Valid Name',
          amountCents: 0,
          transactionDate: DateTime.now(),
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );

    expect(
      () => repository.insertDebt(
        DebtDraft(
          type: DebtType.debt,
          personName: '   ',
          amountCents: 100000,
          transactionDate: DateTime.now(),
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('recordPayment rejects non-positive amount', () async {
    expect(
      () => repository.recordPayment(
        DebtPaymentDraft(
          debtId: 1,
          amountCents: 0,
          paymentDate: DateTime.now(),
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
