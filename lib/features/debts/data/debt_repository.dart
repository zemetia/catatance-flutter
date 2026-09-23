import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' as db;
import '../domain/debt.dart';
import '../domain/debt_payment.dart';
import '../domain/debt_type.dart';

class DebtDraft {
  const DebtDraft({
    required this.type,
    required this.personName,
    required this.amountCents,
    this.paidAmountCents = 0,
    this.dueDate,
    required this.transactionDate,
    this.status = DebtStatus.unpaid,
    this.note,
    this.accountId,
    this.clearAccount = false,
  });

  final DebtType type;
  final String personName;
  final int amountCents;
  final int paidAmountCents;
  final DateTime? dueDate;
  final DateTime transactionDate;
  final DebtStatus status;
  final String? note;
  final int? accountId;
  final bool clearAccount;
}

class DebtPaymentDraft {
  const DebtPaymentDraft({
    required this.debtId,
    required this.amountCents,
    required this.paymentDate,
    this.note,
    this.accountId,
  });

  final int debtId;
  final int amountCents;
  final DateTime paymentDate;
  final String? note;

  /// Optional wallet this payment moves money through. When set, the
  /// payment also debits/credits this wallet and inserts a real
  /// [db.Transactions] row; when left null, the payment is logged
  /// without touching any wallet balance or the ledger.
  final int? accountId;
}

class DebtRepository {
  DebtRepository(this._db);

  final db.AppDatabase _db;

  /// Watches all debts ordered with unpaid first, then by due date.
  Stream<List<Debt>> watchAll() {
    return (_db.select(_db.debts)
          ..orderBy([
            (d) => OrderingTerm(
                  expression: d.status,
                  mode: OrderingMode.desc,
                ), // 'unpaid' before 'paid'
            (d) => OrderingTerm(
                  expression: d.dueDate,
                  mode: OrderingMode.asc,
                  nulls: NullsOrder.last,
                ),
            (d) => OrderingTerm.desc(d.id),
          ]))
        .watch()
        .map((rows) => rows.map(_toDomainDebt).toList());
  }

  /// Watches a single debt by its [id].
  Stream<Debt?> watchDebt(int id) {
    return (_db.select(_db.debts)..where((d) => d.id.equals(id)))
        .watchSingleOrNull()
        .map((row) => row != null ? _toDomainDebt(row) : null);
  }

  /// Fetches a single debt by its [id] once.
  Future<Debt?> getDebt(int id) async {
    final row = await (_db.select(_db.debts)..where((d) => d.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _toDomainDebt(row) : null;
  }

  /// Watches payments recorded for a specific debt.
  Stream<List<DebtPayment>> watchPaymentsForDebt(int debtId) {
    return (_db.select(_db.debtPayments)
          ..where((p) => p.debtId.equals(debtId))
          ..orderBy([(p) => OrderingTerm.desc(p.paymentDate)]))
        .watch()
        .map((rows) => rows.map(_toDomainPayment).toList());
  }

  /// Inserts a new debt/receivable record.
  Future<int> insertDebt(DebtDraft draft) {
    if (draft.amountCents <= 0) {
      throw ArgumentError('Nominal pinjaman harus lebih dari 0');
    }
    if (draft.personName.trim().isEmpty) {
      throw ArgumentError('Nama pihak terkait tidak boleh kosong');
    }

    final effectiveStatus = draft.paidAmountCents >= draft.amountCents
        ? DebtStatus.paid
        : draft.status;

    return _db.into(_db.debts).insert(
          db.DebtsCompanion.insert(
            type: draft.type.raw,
            personName: draft.personName.trim(),
            amountCents: draft.amountCents,
            paidAmountCents: Value(draft.paidAmountCents),
            dueDate: Value(draft.dueDate),
            transactionDate: draft.transactionDate,
            status: Value(effectiveStatus.raw),
            note: Value(draft.note?.trim()),
            accountId: Value(draft.accountId),
          ),
        );
  }

  /// Updates an existing debt/receivable record, safely recalculating
  /// paidAmountCents and status from recorded payments and preserving accountId.
  Future<void> updateDebt(int id, DebtDraft draft) {
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.debts)..where((d) => d.id.equals(id)))
              .getSingle();
      final payments = await (_db.select(_db.debtPayments)
            ..where((p) => p.debtId.equals(id)))
          .get();

      final totalPaidFromPayments = payments.fold<int>(
        0,
        (sum, p) => sum + p.amountCents,
      );

      final effectivePaid = payments.isNotEmpty
          ? totalPaidFromPayments
          : (draft.paidAmountCents > 0
              ? draft.paidAmountCents
              : existing.paidAmountCents);

      final effectiveStatus = effectivePaid >= draft.amountCents
          ? DebtStatus.paid
          : DebtStatus.unpaid;

      final int? effectiveAccountId = draft.clearAccount
          ? null
          : (draft.accountId ?? existing.accountId);

      await (_db.update(_db.debts)..where((d) => d.id.equals(id))).write(
        db.DebtsCompanion(
          type: Value(draft.type.raw),
          personName: Value(draft.personName.trim()),
          amountCents: Value(draft.amountCents),
          paidAmountCents: Value(effectivePaid),
          dueDate: Value(draft.dueDate),
          transactionDate: Value(draft.transactionDate),
          status: Value(effectiveStatus.raw),
          note: Value(draft.note?.trim()),
          accountId: Value(effectiveAccountId),
        ),
      );
    });
  }

  /// Deletes a debt along with all its recorded payments atomically.
  Future<void> deleteDebt(int id) {
    return _db.transaction(() async {
      await (_db.delete(_db.debtPayments)..where((p) => p.debtId.equals(id)))
          .go();
      await (_db.delete(_db.debts)..where((d) => d.id.equals(id))).go();
    });
  }

  /// Records a payment/installment towards [draft.debtId] and updates
  /// the debt's paidAmountCents and status atomically. When
  /// [DebtPaymentDraft.accountId] is set, also debits/credits that wallet
  /// and inserts a linked [db.Transactions] row.
  Future<int> recordPayment(DebtPaymentDraft draft) {
    if (draft.amountCents <= 0) {
      throw ArgumentError('Nominal pembayaran harus lebih dari 0');
    }

    return _db.transaction(() async {
      final debtRow = await (_db.select(_db.debts)
            ..where((d) => d.id.equals(draft.debtId)))
          .getSingle();

      int? transactionId;
      if (draft.accountId != null) {
        transactionId = await _applyPaymentToWallet(
          accountId: draft.accountId!,
          debtType: DebtType.fromRaw(debtRow.type),
          amountCents: draft.amountCents,
          personName: debtRow.personName,
          date: draft.paymentDate,
        );
      }

      final paymentId = await _db.into(_db.debtPayments).insert(
            db.DebtPaymentsCompanion.insert(
              debtId: draft.debtId,
              amountCents: draft.amountCents,
              paymentDate: draft.paymentDate,
              note: Value(draft.note?.trim()),
              accountId: Value(draft.accountId),
              transactionId: Value(transactionId),
            ),
          );

      final payments = await (_db.select(_db.debtPayments)
            ..where((p) => p.debtId.equals(draft.debtId)))
          .get();

      final totalPaid = payments.fold<int>(
        0,
        (sum, p) => sum + p.amountCents,
      );

      final newStatus = totalPaid >= debtRow.amountCents
          ? DebtStatus.paid.raw
          : DebtStatus.unpaid.raw;

      await (_db.update(_db.debts)..where((d) => d.id.equals(draft.debtId)))
          .write(
        db.DebtsCompanion(
          paidAmountCents: Value(totalPaid),
          status: Value(newStatus),
        ),
      );

      return paymentId;
    });
  }

  /// Paying off a debt (type='debt') debits the wallet as an expense
  /// (category 'Hutang'); receiving a receivable payment (type='receivable')
  /// credits it as income (category 'Piutang'). Must run inside an existing
  /// `_db.transaction`. Returns the inserted Transaction's id.
  Future<int> _applyPaymentToWallet({
    required int accountId,
    required DebtType debtType,
    required int amountCents,
    required String personName,
    required DateTime date,
  }) async {
    final isDebtPayment = debtType == DebtType.debt;
    final account = await (_db.select(_db.accounts)
          ..where((a) => a.id.equals(accountId)))
        .getSingle();

    if (isDebtPayment && account.initialBalanceCents < amountCents) {
      throw StateError('Saldo dompet tidak mencukupi untuk membayar utang');
    }

    final newBalance = isDebtPayment
        ? account.initialBalanceCents - amountCents
        : account.initialBalanceCents + amountCents;

    await (_db.update(_db.accounts)..where((a) => a.id.equals(accountId)))
        .write(
      db.AccountsCompanion(initialBalanceCents: Value(newBalance)),
    );

    final categoryId = await _categoryIdByName(
      isDebtPayment ? 'Hutang' : 'Piutang',
      isDebtPayment ? 'expense' : 'income',
    );

    return _db.into(_db.transactions).insert(
          db.TransactionsCompanion.insert(
            accountId: accountId,
            categoryId: categoryId,
            amountCents: amountCents,
            note: Value(
              isDebtPayment
                  ? 'Bayar utang ke $personName'
                  : 'Terima pembayaran piutang dari $personName',
            ),
            date: date,
          ),
        );
  }

  Future<int> _categoryIdByName(String name, String type) async {
    final row = await (_db.select(_db.categories)
          ..where((c) => c.name.equals(name) & c.type.equals(type)))
        .getSingle();
    return row.id;
  }

  /// Deletes a payment record, reverses its linked wallet/transaction effect
  /// if any, and recalculates the debt's total paid amount.
  Future<void> deletePayment(int paymentId) {
    return _db.transaction(() async {
      final payment = await (_db.select(_db.debtPayments)
            ..where((p) => p.id.equals(paymentId)))
          .getSingleOrNull();
      if (payment == null) return;

      final debtId = payment.debtId;

      if (payment.transactionId != null) {
        final tx = await (_db.select(_db.transactions)
              ..where((t) => t.id.equals(payment.transactionId!)))
            .getSingleOrNull();
        if (tx != null) {
          final category = await (_db.select(_db.categories)
                ..where((c) => c.id.equals(tx.categoryId)))
              .getSingleOrNull();
          final account = await (_db.select(_db.accounts)
                ..where((a) => a.id.equals(tx.accountId)))
              .getSingleOrNull();
          if (account != null) {
            final isIncome = category?.type == 'income';
            final revertedBalance = isIncome
                ? account.initialBalanceCents - tx.amountCents
                : account.initialBalanceCents + tx.amountCents;
            await (_db.update(_db.accounts)
                  ..where((a) => a.id.equals(account.id)))
                .write(
              db.AccountsCompanion(
                initialBalanceCents: Value(revertedBalance),
              ),
            );
          }
          await (_db.delete(_db.transactions)..where((t) => t.id.equals(tx.id)))
              .go();
        }
      }

      await (_db.delete(_db.debtPayments)..where((p) => p.id.equals(paymentId)))
          .go();

      final remainingPayments = await (_db.select(_db.debtPayments)
            ..where((p) => p.debtId.equals(debtId)))
          .get();

      final totalPaid = remainingPayments.fold<int>(
        0,
        (sum, p) => sum + p.amountCents,
      );

      final debtRow = await (_db.select(_db.debts)
            ..where((d) => d.id.equals(debtId)))
          .getSingle();

      final newStatus = totalPaid >= debtRow.amountCents
          ? DebtStatus.paid.raw
          : DebtStatus.unpaid.raw;

      await (_db.update(_db.debts)..where((d) => d.id.equals(debtId))).write(
        db.DebtsCompanion(
          paidAmountCents: Value(totalPaid),
          status: Value(newStatus),
        ),
      );
    });
  }

  /// Fully settles a debt in one step, recording a payment for the remaining balance.
  Future<void> settleDebt(
    int debtId, {
    DateTime? paymentDate,
    String? note,
  }) {
    return _db.transaction(() async {
      final debtRow = await (_db.select(_db.debts)
            ..where((d) => d.id.equals(debtId)))
          .getSingle();

      final remaining = debtRow.amountCents - debtRow.paidAmountCents;
      if (remaining > 0) {
        await _db.into(_db.debtPayments).insert(
              db.DebtPaymentsCompanion.insert(
                debtId: debtId,
                amountCents: remaining,
                paymentDate: paymentDate ?? DateTime.now(),
                note: Value(note ?? 'Pelunasan otomatis'),
              ),
            );
      }

      await (_db.update(_db.debts)..where((d) => d.id.equals(debtId))).write(
        db.DebtsCompanion(
          paidAmountCents: Value(debtRow.amountCents),
          status: Value(DebtStatus.paid.raw),
        ),
      );
    });
  }

  Debt _toDomainDebt(db.Debt row) => Debt(
        id: row.id,
        type: DebtType.fromRaw(row.type),
        personName: row.personName,
        amountCents: row.amountCents,
        paidAmountCents: row.paidAmountCents,
        dueDate: row.dueDate,
        transactionDate: row.transactionDate,
        status: DebtStatus.fromRaw(row.status),
        note: row.note,
        accountId: row.accountId,
        createdAt: row.createdAt,
      );

  DebtPayment _toDomainPayment(db.DebtPayment row) => DebtPayment(
        id: row.id,
        debtId: row.debtId,
        amountCents: row.amountCents,
        paymentDate: row.paymentDate,
        note: row.note,
        accountId: row.accountId,
        transactionId: row.transactionId,
        createdAt: row.createdAt,
      );
}
