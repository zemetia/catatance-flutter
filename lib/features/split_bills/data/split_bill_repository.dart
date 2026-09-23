import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' as db;
import '../domain/split_bill.dart';

class SplitBillParticipantDraft {
  const SplitBillParticipantDraft({
    required this.name,
    required this.amountCents,
  });

  final String name;
  final int amountCents;
}

class SplitBillDraft {
  const SplitBillDraft({
    required this.accountId,
    required this.categoryId,
    required this.totalAmountCents,
    required this.payerIncluded,
    required this.payerShareCents,
    required this.participants,
    required this.date,
    this.note,
  });

  final int accountId;
  final int categoryId;
  final int totalAmountCents;
  final bool payerIncluded;
  final int payerShareCents;
  final List<SplitBillParticipantDraft> participants;
  final DateTime date;
  final String? note;
}

/// Creates and manages patungan (group bill) events: one expense
/// transaction for the full amount paid, plus one `receivable` `Debt` per
/// named participant for their share. Piutang repayment itself is handled
/// entirely by the existing `DebtRepository` flow — this repository only
/// owns the creation/deletion of the grouped event.
class SplitBillRepository {
  SplitBillRepository(this._db);

  final db.AppDatabase _db;

  Stream<List<SplitBill>> watchAll() {
    return (_db.select(_db.splitBills)
          ..orderBy([(s) => OrderingTerm.desc(s.id)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  /// Inserts the expense transaction (adjusting the wallet balance), the
  /// `SplitBills` grouping row, and one receivable per participant,
  /// atomically. The sum of participant shares must exactly match
  /// `totalAmountCents - payerShareCents`.
  Future<int> createSplitBill(SplitBillDraft draft) {
    if (draft.totalAmountCents <= 0) {
      throw ArgumentError('Total tagihan harus lebih dari 0');
    }
    if (draft.participants.isEmpty) {
      throw ArgumentError('Tambahkan minimal 1 orang untuk patungan');
    }

    final participantsTotal = draft.participants.fold<int>(
      0,
      (sum, p) => sum + p.amountCents,
    );
    final expectedParticipantsTotal =
        draft.totalAmountCents - draft.payerShareCents;
    if (participantsTotal != expectedParticipantsTotal) {
      throw ArgumentError(
        'Total bagian semua orang harus sama persis dengan tagihan',
      );
    }

    return _db.transaction(() async {
      final account = await (_db.select(_db.accounts)
            ..where((a) => a.id.equals(draft.accountId)))
          .getSingle();

      final newBalance = account.initialBalanceCents - draft.totalAmountCents;
      await (_db.update(_db.accounts)
            ..where((a) => a.id.equals(draft.accountId)))
          .write(db.AccountsCompanion(
        initialBalanceCents: Value(newBalance),
      ));

      final note = draft.note?.trim();

      final transactionId = await _db.into(_db.transactions).insert(
            db.TransactionsCompanion.insert(
              accountId: draft.accountId,
              categoryId: draft.categoryId,
              amountCents: draft.totalAmountCents,
              note: Value(note?.isEmpty ?? true ? null : note),
              date: draft.date,
            ),
          );

      final splitBillId = await _db.into(_db.splitBills).insert(
            db.SplitBillsCompanion.insert(
              transactionId: transactionId,
              totalAmountCents: draft.totalAmountCents,
              payerIncluded: Value(draft.payerIncluded),
              payerShareCents: Value(draft.payerShareCents),
              note: Value(note?.isEmpty ?? true ? null : note),
              date: draft.date,
            ),
          );

      final participantNote =
          note != null && note.isNotEmpty ? 'Patungan: $note' : 'Patungan';

      for (final participant in draft.participants) {
        await _db.into(_db.debts).insert(
              db.DebtsCompanion.insert(
                type: 'receivable',
                personName: participant.name.trim(),
                amountCents: participant.amountCents,
                transactionDate: draft.date,
                note: Value(participantNote),
                accountId: Value(draft.accountId),
                splitBillId: Value(splitBillId),
              ),
            );
      }

      return splitBillId;
    });
  }

  /// Deletes a split bill along with its linked transaction (reversing the
  /// wallet balance adjustment) and every participant receivable plus
  /// their recorded payments, atomically.
  Future<void> deleteSplitBill(int id) {
    return _db.transaction(() async {
      final split = await (_db.select(_db.splitBills)
            ..where((s) => s.id.equals(id)))
          .getSingle();

      final tx = await (_db.select(_db.transactions)
            ..where((t) => t.id.equals(split.transactionId)))
          .getSingleOrNull();

      if (tx != null) {
        final account = await (_db.select(_db.accounts)
              ..where((a) => a.id.equals(tx.accountId)))
            .getSingle();
        await (_db.update(_db.accounts)
              ..where((a) => a.id.equals(tx.accountId)))
            .write(db.AccountsCompanion(
          initialBalanceCents:
              Value(account.initialBalanceCents + tx.amountCents),
        ));
        await (_db.delete(_db.transactions)..where((t) => t.id.equals(tx.id)))
            .go();
      }

      final participantDebts = await (_db.select(_db.debts)
            ..where((d) => d.splitBillId.equals(id)))
          .get();
      for (final debt in participantDebts) {
        await (_db.delete(_db.debtPayments)
              ..where((p) => p.debtId.equals(debt.id)))
            .go();
      }
      await (_db.delete(_db.debts)..where((d) => d.splitBillId.equals(id)))
          .go();

      await (_db.delete(_db.splitBills)..where((s) => s.id.equals(id))).go();
    });
  }

  SplitBill _toDomain(db.SplitBill row) => SplitBill(
        id: row.id,
        transactionId: row.transactionId,
        totalAmountCents: row.totalAmountCents,
        payerIncluded: row.payerIncluded,
        payerShareCents: row.payerShareCents,
        note: row.note,
        date: row.date,
        createdAt: row.createdAt,
      );
}
