import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' as db;
import '../domain/installment.dart';
import '../domain/installment_payment.dart';
import '../domain/installment_status.dart';

class InstallmentDraft {
  const InstallmentDraft({
    required this.name,
    required this.totalAmountCents,
    required this.tenorMonths,
    required this.installmentAmountCents,
    required this.startDate,
    this.accountId,
    this.categoryId,
    this.note,
    this.clearAccount = false,
    this.clearCategory = false,
  });

  final String name;
  final int totalAmountCents;
  final int tenorMonths;
  final int installmentAmountCents;
  final DateTime startDate;
  final int? accountId;
  final int? categoryId;
  final String? note;
  final bool clearAccount;
  final bool clearCategory;
}

class InstallmentPaymentDraft {
  const InstallmentPaymentDraft({
    required this.installmentId,
    required this.amountCents,
    required this.paymentDate,
    this.note,
  });

  final int installmentId;
  final int amountCents;
  final DateTime paymentDate;
  final String? note;
}

class InstallmentRepository {
  InstallmentRepository(this._db);

  final db.AppDatabase _db;

  /// Watches all installment plans, active ones first, newest first.
  Stream<List<Installment>> watchAll() {
    return (_db.select(_db.installments)
          ..orderBy([
            (i) => OrderingTerm.asc(i.status), // 'active' before 'completed'
            (i) => OrderingTerm.desc(i.id),
          ]))
        .watch()
        .map((rows) => rows.map(_toDomainInstallment).toList());
  }

  Stream<Installment?> watchInstallment(int id) {
    return (_db.select(_db.installments)..where((i) => i.id.equals(id)))
        .watchSingleOrNull()
        .map((row) => row != null ? _toDomainInstallment(row) : null);
  }

  Future<Installment?> getInstallment(int id) async {
    final row = await (_db.select(_db.installments)
          ..where((i) => i.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _toDomainInstallment(row) : null;
  }

  Stream<List<InstallmentPayment>> watchPaymentsForInstallment(
    int installmentId,
  ) {
    return (_db.select(_db.installmentPayments)
          ..where((p) => p.installmentId.equals(installmentId))
          ..orderBy([(p) => OrderingTerm.desc(p.paymentDate)]))
        .watch()
        .map((rows) => rows.map(_toDomainPayment).toList());
  }

  Future<int> insertInstallment(InstallmentDraft draft) {
    if (draft.name.trim().isEmpty) {
      throw ArgumentError('Nama cicilan tidak boleh kosong');
    }
    if (draft.tenorMonths <= 0) {
      throw ArgumentError('Tenor cicilan harus lebih dari 0 bulan');
    }
    if (draft.installmentAmountCents <= 0) {
      throw ArgumentError('Nominal cicilan per bulan harus lebih dari 0');
    }

    return _db.into(_db.installments).insert(
          db.InstallmentsCompanion.insert(
            name: draft.name.trim(),
            totalAmountCents: draft.totalAmountCents,
            tenorMonths: draft.tenorMonths,
            installmentAmountCents: draft.installmentAmountCents,
            startDate: draft.startDate,
            accountId: Value(draft.accountId),
            categoryId: Value(draft.categoryId),
            note: Value(draft.note?.trim()),
          ),
        );
  }

  /// Updates an installment plan's details, preserving progress already made.
  Future<void> updateInstallment(int id, InstallmentDraft draft) {
    if (draft.name.trim().isEmpty) {
      throw ArgumentError('Nama cicilan tidak boleh kosong');
    }
    if (draft.tenorMonths <= 0) {
      throw ArgumentError('Tenor cicilan harus lebih dari 0 bulan');
    }

    return _db.transaction(() async {
      final existing = await (_db.select(_db.installments)
            ..where((i) => i.id.equals(id)))
          .getSingle();

      final newStatus = existing.paidAmountCents >= draft.totalAmountCents
          ? InstallmentStatus.completed
          : InstallmentStatus.active;

      final int? effectiveAccountId =
          draft.clearAccount ? null : (draft.accountId ?? existing.accountId);
      final int? effectiveCategoryId = draft.clearCategory
          ? null
          : (draft.categoryId ?? existing.categoryId);

      await (_db.update(_db.installments)..where((i) => i.id.equals(id)))
          .write(
        db.InstallmentsCompanion(
          name: Value(draft.name.trim()),
          totalAmountCents: Value(draft.totalAmountCents),
          tenorMonths: Value(draft.tenorMonths),
          installmentAmountCents: Value(draft.installmentAmountCents),
          startDate: Value(draft.startDate),
          accountId: Value(effectiveAccountId),
          categoryId: Value(effectiveCategoryId),
          note: Value(draft.note?.trim()),
          status: Value(newStatus.raw),
        ),
      );
    });
  }

  /// Deletes an installment plan and its payment log. Past transactions
  /// created by those payments are left intact — the money was already spent.
  Future<void> deleteInstallment(int id) {
    return _db.transaction(() async {
      await (_db.delete(_db.installmentPayments)
            ..where((p) => p.installmentId.equals(id)))
          .go();
      await (_db.delete(_db.installments)..where((i) => i.id.equals(id))).go();
    });
  }

  /// Records the next scheduled installment payment.
  Future<int> payInstallment(InstallmentPaymentDraft draft) {
    if (draft.amountCents <= 0) {
      throw ArgumentError('Nominal pembayaran harus lebih dari 0');
    }

    return _db.transaction(() async {
      final installment = await (_db.select(_db.installments)
            ..where((i) => i.id.equals(draft.installmentId)))
          .getSingle();

      if (installment.paidAmountCents >= installment.totalAmountCents) {
        throw StateError('Cicilan ini sudah lunas');
      }

      final newPaidAmount = installment.paidAmountCents + draft.amountCents;
      final newPaidInstallments = installment.paidInstallments + 1;
      final newStatus = newPaidAmount >= installment.totalAmountCents
          ? InstallmentStatus.completed
          : InstallmentStatus.active;

      return _recordPayment(
        installment: installment,
        amountCents: draft.amountCents,
        paymentDate: draft.paymentDate,
        note: draft.note,
        newPaidInstallments: newPaidInstallments,
        newPaidAmountCents: newPaidAmount,
        newStatus: newStatus,
      );
    });
  }

  /// Pays off the remaining balance in one lump-sum payment and marks the
  /// plan fully completed, regardless of how many installments remain.
  Future<int> payoffRemaining(
    int installmentId, {
    DateTime? paymentDate,
    String? note,
  }) {
    return _db.transaction(() async {
      final installment = await (_db.select(_db.installments)
            ..where((i) => i.id.equals(installmentId)))
          .getSingle();

      final remaining =
          installment.totalAmountCents - installment.paidAmountCents;

      if (remaining <= 0) {
        throw StateError('Cicilan ini sudah lunas');
      }

      return _recordPayment(
        installment: installment,
        amountCents: remaining,
        paymentDate: paymentDate ?? DateTime.now(),
        note: note ?? 'Pelunasan dipercepat',
        newPaidInstallments: installment.tenorMonths,
        newPaidAmountCents: installment.totalAmountCents,
        newStatus: InstallmentStatus.completed,
      );
    });
  }

  /// Shared payment-recording logic: optionally deducts the linked wallet
  /// and creates a linked Transaction, then logs the payment and updates
  /// the installment's progress. Must run inside an existing `_db.transaction`.
  Future<int> _recordPayment({
    required db.Installment installment,
    required int amountCents,
    required DateTime paymentDate,
    required String? note,
    required int newPaidInstallments,
    required int newPaidAmountCents,
    required InstallmentStatus newStatus,
  }) async {
    int? transactionId;

    if (installment.accountId != null && installment.categoryId != null) {
      final account = await (_db.select(_db.accounts)
            ..where((a) => a.id.equals(installment.accountId!)))
          .getSingleOrNull();

      if (account != null) {
        if (account.initialBalanceCents < amountCents) {
          throw StateError('Saldo dompet tidak mencukupi untuk bayar cicilan');
        }

        await (_db.update(_db.accounts)
              ..where((a) => a.id.equals(account.id)))
            .write(
          db.AccountsCompanion(
            initialBalanceCents:
                Value(account.initialBalanceCents - amountCents),
          ),
        );

        transactionId = await _db.into(_db.transactions).insert(
              db.TransactionsCompanion.insert(
                accountId: installment.accountId!,
                categoryId: installment.categoryId!,
                amountCents: amountCents,
                note: Value(
                  'Cicilan ${installment.name} '
                  '($newPaidInstallments/${installment.tenorMonths})',
                ),
                date: paymentDate,
              ),
            );
      }
    }

    final paymentId = await _db.into(_db.installmentPayments).insert(
          db.InstallmentPaymentsCompanion.insert(
            installmentId: installment.id,
            amountCents: amountCents,
            paymentDate: paymentDate,
            transactionId: Value(transactionId),
            note: Value(note?.trim()),
          ),
        );

    await (_db.update(_db.installments)
          ..where((i) => i.id.equals(installment.id)))
        .write(
      db.InstallmentsCompanion(
        paidInstallments: Value(newPaidInstallments),
        paidAmountCents: Value(newPaidAmountCents),
        status: Value(newStatus.raw),
      ),
    );

    return paymentId;
  }

  /// Deletes a payment record, reverses its linked wallet/transaction effect
  /// if any, and recalculates the installment's progress.
  Future<void> deletePayment(int paymentId) {
    return _db.transaction(() async {
      final payment = await (_db.select(_db.installmentPayments)
            ..where((p) => p.id.equals(paymentId)))
          .getSingleOrNull();
      if (payment == null) return;

      if (payment.transactionId != null) {
        final tx = await (_db.select(_db.transactions)
              ..where((t) => t.id.equals(payment.transactionId!)))
            .getSingleOrNull();
        if (tx != null) {
          final account = await (_db.select(_db.accounts)
                ..where((a) => a.id.equals(tx.accountId)))
              .getSingleOrNull();
          if (account != null) {
            await (_db.update(_db.accounts)
                  ..where((a) => a.id.equals(account.id)))
                .write(
              db.AccountsCompanion(
                initialBalanceCents:
                    Value(account.initialBalanceCents + tx.amountCents),
              ),
            );
          }
          await (_db.delete(_db.transactions)..where((t) => t.id.equals(tx.id)))
              .go();
        }
      }

      await (_db.delete(_db.installmentPayments)
            ..where((p) => p.id.equals(paymentId)))
          .go();

      final installment = await (_db.select(_db.installments)
            ..where((i) => i.id.equals(payment.installmentId)))
          .getSingle();

      final newPaidInstallments = installment.paidInstallments > 0
          ? installment.paidInstallments - 1
          : 0;
      final newPaidAmount = installment.paidAmountCents - payment.amountCents;
      final clampedPaidAmount = newPaidAmount < 0 ? 0 : newPaidAmount;
      final newStatus = clampedPaidAmount >= installment.totalAmountCents
          ? InstallmentStatus.completed
          : InstallmentStatus.active;

      await (_db.update(_db.installments)
            ..where((i) => i.id.equals(installment.id)))
          .write(
        db.InstallmentsCompanion(
          paidInstallments: Value(newPaidInstallments),
          paidAmountCents: Value(clampedPaidAmount),
          status: Value(newStatus.raw),
        ),
      );
    });
  }

  Installment _toDomainInstallment(db.Installment row) => Installment(
        id: row.id,
        name: row.name,
        totalAmountCents: row.totalAmountCents,
        tenorMonths: row.tenorMonths,
        installmentAmountCents: row.installmentAmountCents,
        paidInstallments: row.paidInstallments,
        paidAmountCents: row.paidAmountCents,
        startDate: row.startDate,
        accountId: row.accountId,
        categoryId: row.categoryId,
        note: row.note,
        status: InstallmentStatus.fromRaw(row.status),
        createdAt: row.createdAt,
      );

  InstallmentPayment _toDomainPayment(db.InstallmentPayment row) =>
      InstallmentPayment(
        id: row.id,
        installmentId: row.installmentId,
        amountCents: row.amountCents,
        paymentDate: row.paymentDate,
        transactionId: row.transactionId,
        note: row.note,
        createdAt: row.createdAt,
      );
}
