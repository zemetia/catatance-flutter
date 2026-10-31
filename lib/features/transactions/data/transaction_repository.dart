import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/transaction_item.dart';

class TransactionRepository {
  TransactionRepository(this._db);

  final AppDatabase _db;

  Stream<List<TransactionItem>> watchRecent({int limit = 50}) {
    final toAccount = _db.accounts.createAlias('to_account');
    final query = _db.select(_db.transactions).join([
      innerJoin(
        _db.accounts,
        _db.accounts.id.equalsExp(_db.transactions.accountId),
      ),
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
      leftOuterJoin(
        toAccount,
        toAccount.id.equalsExp(_db.transactions.toAccountId),
      ),
    ])
      ..orderBy([
        OrderingTerm.desc(_db.transactions.date),
        OrderingTerm.desc(_db.transactions.id),
      ])
      ..limit(limit);

    return query.watch().map((rows) {
      return rows.map((row) => _rowToItem(row, toAccount)).toList();
    });
  }

  /// Look up a single [TransactionItem] by its primary key [id], or null if
  /// not found.
  Future<TransactionItem?> getItem(int id) async {
    final toAccount = _db.accounts.createAlias('to_account');
    final query = _db.select(_db.transactions).join([
      innerJoin(
        _db.accounts,
        _db.accounts.id.equalsExp(_db.transactions.accountId),
      ),
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
      leftOuterJoin(
        toAccount,
        toAccount.id.equalsExp(_db.transactions.toAccountId),
      ),
    ])..where(_db.transactions.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _rowToItem(row, toAccount);
  }

  TransactionItem _rowToItem(TypedResult row, $AccountsTable toAccount) {
    final tx = row.readTable(_db.transactions);
    final account = row.readTable(_db.accounts);
    final category = row.readTable(_db.categories);
    final destination = row.readTableOrNull(toAccount);
    return TransactionItem(
      id: tx.id,
      accountId: account.id,
      accountName: account.name,
      accountCurrencyCode: account.currencyCode,
      categoryId: category.id,
      categoryName: category.name,
      categoryIcon: category.icon,
      categoryType: category.type,
      categoryColorValue: category.colorValue,
      amountCents: tx.amountCents,
      note: tx.note,
      date: tx.date,
      createdAt: tx.createdAt,
      toAccountName: destination?.name,
      savingsGoalId: tx.savingsGoalId,
    );
  }

  Future<int> insert({
    required int accountId,
    required int categoryId,
    required int amountCents,
    String? note,
    required DateTime date,
    int? savingsGoalId,
  }) {
    return _db.transaction(() async {
      final category = await (_db.select(_db.categories)
            ..where((c) => c.id.equals(categoryId)))
          .getSingle();
      final isIncome = category.type == 'income';
      final account = await (_db.select(_db.accounts)
            ..where((a) => a.id.equals(accountId)))
          .getSingle();

      final newBalance = isIncome
          ? account.initialBalanceCents + amountCents
          : account.initialBalanceCents - amountCents;

      await (_db.update(_db.accounts)..where((a) => a.id.equals(accountId))).write(
        AccountsCompanion(initialBalanceCents: Value(newBalance)),
      );

      final id = await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              categoryId: categoryId,
              amountCents: amountCents,
              note: Value(note),
              date: date,
              savingsGoalId: Value(isIncome ? savingsGoalId : null),
            ),
          );

      // Income earmarked for a savings target: credits the goal's saved
      // amount directly, on top of the wallet balance already credited
      // above — unlike SavingsGoalRepository.deposit, it never deducts the
      // wallet again, since this money was earned, not moved from savings.
      if (isIncome && savingsGoalId != null) {
        await _shiftGoal(savingsGoalId, amountCents);
      }

      return id;
    });
  }

  /// Why this transaction's money fields can't be edited or deleted here, or
  /// null when it is free to change. A payment recorded by Cicilan, Utang &
  /// Piutang or Patungan owns its transaction: changing the nominal, wallet
  /// or category from the ledger would silently desync that feature's own
  /// progress, so those must be changed from the owning screen instead.
  Future<String?> lockReason(int id) async {
    final installment = await (_db.select(_db.installmentPayments)
          ..where((p) => p.transactionId.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (installment != null) return 'pembayaran Cicilan';

    final debtPayment = await (_db.select(_db.debtPayments)
          ..where((p) => p.transactionId.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (debtPayment != null) return 'pembayaran Utang & Piutang';

    final split = await (_db.select(_db.splitBills)
          ..where((s) => s.transactionId.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (split != null) return 'Patungan';

    return null;
  }

  /// Edits any field of a plain income/expense transaction (date, wallet,
  /// category, nominal, note, savings target) and keeps every balance in
  /// step: the old transaction's effect on its wallet (and savings goal) is
  /// reversed, the row is rewritten, and the new effect is applied — all in
  /// one DB transaction, so switching wallet A → B with nominal U gives A
  /// back U and takes U from B (or the opposite for an income).
  Future<void> update({
    required int id,
    required int accountId,
    required int categoryId,
    required int amountCents,
    String? note,
    required DateTime date,
    int? savingsGoalId,
  }) {
    return _db.transaction(() async {
      final old = await _requireRow(id);
      final reason = await lockReason(id);
      if (reason != null) {
        throw StateError(
          'Transaksi ini bagian dari $reason. Ubah dari menu terkait.',
        );
      }
      final oldType = await _categoryType(old.categoryId);
      if (oldType != 'income' && oldType != 'expense') {
        throw StateError('Transfer hanya bisa diubah tanggal dan catatannya.');
      }
      final newType = await _categoryType(categoryId);
      if (newType != 'income' && newType != 'expense') {
        throw ArgumentError('Kategori harus pemasukan atau pengeluaran.');
      }
      if (amountCents <= 0) throw ArgumentError('Nominal harus lebih dari 0.');

      await _applyEffect(old, oldType, -1);

      final newGoalId = newType == 'income' ? savingsGoalId : null;
      await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(
          accountId: Value(accountId),
          categoryId: Value(categoryId),
          amountCents: Value(amountCents),
          note: Value(note),
          date: Value(date),
          savingsGoalId: Value(newGoalId),
        ),
      );

      final updated = await _requireRow(id);
      await _applyEffect(updated, newType, 1);
    });
  }

  /// Date/note-only edit — safe for every transaction, including transfers
  /// and payments owned by another feature, since it moves no money.
  Future<void> updateNoteAndDate({
    required int id,
    String? note,
    required DateTime date,
  }) async {
    await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(note: Value(note), date: Value(date)),
    );
  }

  /// Deletes a transaction and reverses what it did to the wallet(s) and
  /// savings goal. Payments owned by another feature must be deleted from
  /// that feature instead (they also roll back their own progress).
  Future<void> delete(int id) {
    return _db.transaction(() async {
      final row = await _requireRow(id);
      final reason = await lockReason(id);
      if (reason != null) {
        throw StateError(
          'Transaksi ini bagian dari $reason. Hapus dari menu terkait.',
        );
      }
      final type = await _categoryType(row.categoryId);
      await _applyEffect(row, type, -1);
      await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<Transaction> _requireRow(int id) async {
    final row = await (_db.select(_db.transactions)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) throw StateError('Transaksi tidak ditemukan.');
    return row;
  }

  Future<String> _categoryType(int categoryId) async {
    final category = await (_db.select(_db.categories)
          ..where((c) => c.id.equals(categoryId)))
        .getSingle();
    return category.type;
  }

  /// Applies ([sign] = 1) or reverses ([sign] = -1) everything [tx] does to
  /// balances, keyed on its category type:
  /// income / transfer_in → +amount on its wallet; expense / transfer_out →
  /// −amount; a single-row transfer → −amount on the source and
  /// +(toAmount ?? amount) on the destination. An earmarked income also
  /// moves its savings goal by the same amount.
  Future<void> _applyEffect(Transaction tx, String type, int sign) async {
    switch (type) {
      case 'income':
      case 'transfer_in':
        await _shiftWallet(tx.accountId, sign * tx.amountCents);
      case 'transfer':
        await _shiftWallet(tx.accountId, -sign * tx.amountCents);
        final toId = tx.toAccountId;
        if (toId != null) {
          await _shiftWallet(toId, sign * (tx.toAmountCents ?? tx.amountCents));
        }
      default: // expense, transfer_out
        await _shiftWallet(tx.accountId, -sign * tx.amountCents);
    }
    if (type == 'income' && tx.savingsGoalId != null) {
      await _shiftGoal(tx.savingsGoalId!, sign * tx.amountCents);
    }
  }

  Future<void> _shiftWallet(int accountId, int delta) async {
    final account = await (_db.select(_db.accounts)
          ..where((a) => a.id.equals(accountId)))
        .getSingleOrNull();
    if (account == null) return;
    await (_db.update(_db.accounts)..where((a) => a.id.equals(accountId))).write(
      AccountsCompanion(
        initialBalanceCents: Value(account.initialBalanceCents + delta),
      ),
    );
  }

  Future<void> _shiftGoal(int goalId, int delta) async {
    final goal = await (_db.select(_db.savingsGoals)
          ..where((s) => s.id.equals(goalId)))
        .getSingleOrNull();
    if (goal == null) return; // goal was deleted since — nothing to move
    final next = goal.currentAmountCents + delta;
    await (_db.update(_db.savingsGoals)..where((s) => s.id.equals(goalId)))
        .write(
      SavingsGoalsCompanion(currentAmountCents: Value(next < 0 ? 0 : next)),
    );
  }
}
