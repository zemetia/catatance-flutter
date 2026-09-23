import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/features/debts/domain/debt.dart';
import 'package:pencatatan_keuangan/features/debts/domain/debt_type.dart';

void main() {
  group('Debt Domain Model Tests', () {
    final now = DateTime(2026, 9, 22, 10, 0);

    test('calculates remaining amount correctly', () {
      final debt = Debt(
        id: 1,
        type: DebtType.debt,
        personName: 'Test',
        amountCents: 1000000,
        paidAmountCents: 350000,
        transactionDate: now,
        createdAt: now,
      );

      expect(debt.remainingCents, equals(650000));
      expect(debt.isSettled, isFalse);
      expect(debt.progress, closeTo(0.35, 0.001));
      expect(debt.progressPercentage, equals('35%'));
    });

    test('handles zero amount and fully paid edge cases', () {
      final zeroDebt = Debt(
        id: 1,
        type: DebtType.receivable,
        personName: 'Test',
        amountCents: 0,
        transactionDate: now,
        createdAt: now,
      );
      expect(zeroDebt.isSettled, isTrue);
      expect(zeroDebt.progress, equals(1.0));

      final fullyPaidDebt = Debt(
        id: 2,
        type: DebtType.debt,
        personName: 'Test',
        amountCents: 500000,
        paidAmountCents: 500000,
        transactionDate: now,
        createdAt: now,
      );
      expect(fullyPaidDebt.remainingCents, equals(0));
      expect(fullyPaidDebt.isSettled, isTrue);
      expect(fullyPaidDebt.dueStatusLabel, equals('Lunas'));
    });

    test('overdue detection works accurately across dates', () {
      final overdueDebt = Debt(
        id: 1,
        type: DebtType.receivable,
        personName: 'Late Payer',
        amountCents: 200000,
        dueDate: now.subtract(const Duration(days: 4)),
        transactionDate: now.subtract(const Duration(days: 20)),
        createdAt: now,
      );

      expect(overdueDebt.isOverdueAt(now), isTrue);
      expect(overdueDebt.daysUntilDueAt(now), equals(-4));
      expect(overdueDebt.dueStatusLabelAt(now), equals('Lewat tempo 4 hari'));

      final todayDebt = Debt(
        id: 2,
        type: DebtType.debt,
        personName: 'Due Today',
        amountCents: 150000,
        dueDate: now,
        transactionDate: now,
        createdAt: now,
      );
      expect(todayDebt.daysUntilDueAt(now), equals(0));
      expect(todayDebt.dueStatusLabelAt(now), equals('Jatuh tempo hari ini'));

      final tomorrowDebt = Debt(
        id: 3,
        type: DebtType.debt,
        personName: 'Due Tomorrow',
        amountCents: 150000,
        dueDate: now.add(const Duration(days: 1)),
        transactionDate: now,
        createdAt: now,
      );
      expect(tomorrowDebt.daysUntilDueAt(now), equals(1));
      expect(tomorrowDebt.dueStatusLabelAt(now), equals('Jatuh tempo besok'));

      final futureDebt = Debt(
        id: 4,
        type: DebtType.debt,
        personName: 'Future Payee',
        amountCents: 200000,
        dueDate: now.add(const Duration(days: 5)),
        transactionDate: now,
        createdAt: now,
      );

      expect(futureDebt.isOverdueAt(now), isFalse);
      expect(futureDebt.daysUntilDueAt(now), equals(5));
      expect(futureDebt.dueStatusLabelAt(now), equals('Jatuh tempo 5 hari lagi'));

      final noDueDateDebt = Debt(
        id: 5,
        type: DebtType.debt,
        personName: 'No Due Date',
        amountCents: 200000,
        dueDate: null,
        transactionDate: now,
        createdAt: now,
      );

      expect(noDueDateDebt.isOverdueAt(now), isFalse);
      expect(noDueDateDebt.dueStatusLabelAt(now), equals('Tanpa tempo'));
      expect(noDueDateDebt.dueStatusLabel, equals('Tanpa tempo'));
    });

    test('DebtType provides accurate Indonesian labels and semantics', () {
      expect(DebtType.debt.label, equals('Utang'));
      expect(DebtType.debt.title, equals('Utang Saya'));
      expect(DebtType.debt.paymentActionLabel, equals('Bayar Utang'));

      expect(DebtType.receivable.label, equals('Piutang'));
      expect(DebtType.receivable.title, equals('Piutang Saya'));
      expect(DebtType.receivable.paymentActionLabel, equals('Terima Pembayaran'));

      expect(DebtType.fromRaw('receivable'), equals(DebtType.receivable));
      expect(DebtType.fromRaw('debt'), equals(DebtType.debt));
      expect(DebtType.fromRaw('unknown'), equals(DebtType.debt));
    });
  });
}
