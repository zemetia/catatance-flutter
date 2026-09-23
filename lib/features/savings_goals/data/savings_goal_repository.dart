import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' as db;
import '../domain/savings_goal.dart';

class SavingsGoalDraft {
  const SavingsGoalDraft({
    required this.name,
    this.iconKey = 'plane',
    this.gradientIndex = 0,
    required this.targetAmountCents,
    this.currentAmountCents = 0,
    this.targetDate,
    this.autoSaveEnabled = false,
    this.autoSaveAmountCents = 0,
    this.autoSaveFrequency = 'monthly',
    this.sourceAccountId,
    this.note,
  });

  final String name;
  final String iconKey;
  final int gradientIndex;
  final int targetAmountCents;
  final int currentAmountCents;
  final DateTime? targetDate;
  final bool autoSaveEnabled;
  final int autoSaveAmountCents;
  final String autoSaveFrequency;
  final int? sourceAccountId;
  final String? note;
}

class SavingsGoalRepository {
  SavingsGoalRepository(this._db);

  final db.AppDatabase _db;

  /// Watches all savings goals, active first, then by creation date.
  Stream<List<SavingsGoal>> watchAll() {
    return (_db.select(_db.savingsGoals)
          ..orderBy([
            (s) => OrderingTerm.desc(s.id),
          ]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  /// Gets all savings goals once.
  Future<List<SavingsGoal>> getAll() async {
    final rows = await (_db.select(_db.savingsGoals)
          ..orderBy([
            (s) => OrderingTerm.desc(s.id),
          ]))
        .get();
    return rows.map(_toDomain).toList();
  }

  /// Watches a single goal by its [id].
  Stream<SavingsGoal?> watchGoal(int id) {
    return (_db.select(_db.savingsGoals)..where((s) => s.id.equals(id)))
        .watchSingleOrNull()
        .map((row) => row != null ? _toDomain(row) : null);
  }

  /// Gets a single goal by its [id] once.
  Future<SavingsGoal?> getGoal(int id) async {
    final row = await (_db.select(_db.savingsGoals)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  /// Creates a new savings goal. If an initial deposit was made with a source wallet,
  /// deducts that amount from the wallet atomically.
  Future<int> insert(SavingsGoalDraft draft) {
    if (draft.name.trim().isEmpty) {
      throw ArgumentError('Nama target tabungan tidak boleh kosong');
    }
    if (draft.targetAmountCents <= 0) {
      throw ArgumentError('Nominal target tabungan harus lebih dari 0');
    }

    return _db.transaction(() async {
      final goalId = await _db.into(_db.savingsGoals).insert(
            db.SavingsGoalsCompanion.insert(
              name: draft.name.trim(),
              iconKey: Value(draft.iconKey),
              gradientIndex: Value(draft.gradientIndex),
              targetAmountCents: draft.targetAmountCents,
              currentAmountCents: Value(draft.currentAmountCents),
              targetDate: Value(draft.targetDate),
              autoSaveEnabled: Value(draft.autoSaveEnabled),
              autoSaveAmountCents: Value(draft.autoSaveAmountCents),
              autoSaveFrequency: Value(draft.autoSaveFrequency),
              sourceAccountId: Value(draft.sourceAccountId),
              note: Value(draft.note?.trim()),
            ),
          );

      if (draft.currentAmountCents > 0 && draft.sourceAccountId != null) {
        final account = await (_db.select(_db.accounts)
              ..where((a) => a.id.equals(draft.sourceAccountId!)))
            .getSingleOrNull();
        if (account != null) {
          if (account.initialBalanceCents < draft.currentAmountCents) {
            throw StateError('Saldo dompet tidak mencukupi untuk setoran awal');
          }
          await (_db.update(_db.accounts)
                ..where((a) => a.id.equals(account.id)))
              .write(
            db.AccountsCompanion(
              initialBalanceCents: Value(
                account.initialBalanceCents - draft.currentAmountCents,
              ),
            ),
          );
        }
      }

      return goalId;
    });
  }

  /// Updates an existing savings goal. Preserves current saved amount.
  Future<void> update(int id, SavingsGoalDraft draft) {
    if (draft.name.trim().isEmpty) {
      throw ArgumentError('Nama target tabungan tidak boleh kosong');
    }
    if (draft.targetAmountCents <= 0) {
      throw ArgumentError('Nominal target tabungan harus lebih dari 0');
    }

    return (_db.update(_db.savingsGoals)..where((s) => s.id.equals(id))).write(
      db.SavingsGoalsCompanion(
        name: Value(draft.name.trim()),
        iconKey: Value(draft.iconKey),
        gradientIndex: Value(draft.gradientIndex),
        targetAmountCents: Value(draft.targetAmountCents),
        targetDate: Value(draft.targetDate),
        autoSaveEnabled: Value(draft.autoSaveEnabled),
        autoSaveAmountCents: Value(draft.autoSaveAmountCents),
        autoSaveFrequency: Value(draft.autoSaveFrequency),
        sourceAccountId: Value(draft.sourceAccountId),
        note: Value(draft.note?.trim()),
      ),
    );
  }

  /// Deletes a savings goal.
  Future<void> delete(int id) {
    return (_db.delete(_db.savingsGoals)..where((s) => s.id.equals(id))).go();
  }

  /// Deposits funds into a savings goal, optionally deducting from a wallet.
  Future<void> deposit(
    int goalId,
    int amountCents, {
    int? sourceAccountId,
  }) {
    if (amountCents <= 0) {
      throw ArgumentError('Nominal tabungan harus lebih dari 0');
    }

    return _db.transaction(() async {
      final goal = await (_db.select(_db.savingsGoals)
            ..where((s) => s.id.equals(goalId)))
          .getSingle();

      if (sourceAccountId != null) {
        final account = await (_db.select(_db.accounts)
              ..where((a) => a.id.equals(sourceAccountId)))
            .getSingleOrNull();
        if (account != null) {
          if (account.initialBalanceCents < amountCents) {
            throw StateError('Saldo dompet tidak mencukupi untuk menabung');
          }
          await (_db.update(_db.accounts)
                ..where((a) => a.id.equals(account.id)))
              .write(
            db.AccountsCompanion(
              initialBalanceCents: Value(
                account.initialBalanceCents - amountCents,
              ),
            ),
          );
        }
      }

      await (_db.update(_db.savingsGoals)..where((s) => s.id.equals(goalId)))
          .write(
        db.SavingsGoalsCompanion(
          currentAmountCents: Value(goal.currentAmountCents + amountCents),
        ),
      );
    });
  }

  /// Withdraws funds from a savings goal, optionally returning them to a wallet.
  Future<void> withdraw(
    int goalId,
    int amountCents, {
    int? targetAccountId,
  }) {
    if (amountCents <= 0) {
      throw ArgumentError('Nominal penarikan harus lebih dari 0');
    }

    return _db.transaction(() async {
      final goal = await (_db.select(_db.savingsGoals)
            ..where((s) => s.id.equals(goalId)))
          .getSingle();

      if (amountCents > goal.currentAmountCents) {
        throw ArgumentError(
          'Nominal penarikan ($amountCents) tidak boleh melebihi saldo tabungan (${goal.currentAmountCents})',
        );
      }

      final newAmount = goal.currentAmountCents - amountCents;

      await (_db.update(_db.savingsGoals)..where((s) => s.id.equals(goalId)))
          .write(
        db.SavingsGoalsCompanion(
          currentAmountCents: Value(newAmount),
        ),
      );

      if (targetAccountId != null) {
        final account = await (_db.select(_db.accounts)
              ..where((a) => a.id.equals(targetAccountId)))
            .getSingleOrNull();
        if (account != null) {
          await (_db.update(_db.accounts)
                ..where((a) => a.id.equals(account.id)))
              .write(
            db.AccountsCompanion(
              initialBalanceCents: Value(
                account.initialBalanceCents + amountCents,
              ),
            ),
          );
        }
      }
    });
  }

  /// Toggles autosave on or off.
  Future<void> toggleAutoSave(int goalId, bool enabled) {
    return (_db.update(_db.savingsGoals)..where((s) => s.id.equals(goalId)))
        .write(
      db.SavingsGoalsCompanion(
        autoSaveEnabled: Value(enabled),
      ),
    );
  }

  /// Executes an autosave cycle for [goalId].
  Future<bool> executeAutoSave(int goalId) async {
    final goal = await getGoal(goalId);
    if (goal == null || !goal.autoSaveEnabled || goal.autoSaveAmountCents <= 0) {
      return false;
    }

    // Check if source wallet has enough funds if specified
    if (goal.sourceAccountId != null) {
      final account = await (_db.select(_db.accounts)
            ..where((a) => a.id.equals(goal.sourceAccountId!)))
          .getSingleOrNull();
      if (account == null || account.initialBalanceCents < goal.autoSaveAmountCents) {
        return false;
      }
    }

    await deposit(
      goalId,
      goal.autoSaveAmountCents,
      sourceAccountId: goal.sourceAccountId,
    );
    return true;
  }

  SavingsGoal _toDomain(db.SavingsGoal row) => SavingsGoal(
        id: row.id,
        name: row.name,
        iconKey: row.iconKey,
        gradientIndex: row.gradientIndex,
        targetAmountCents: row.targetAmountCents,
        currentAmountCents: row.currentAmountCents,
        targetDate: row.targetDate,
        autoSaveEnabled: row.autoSaveEnabled,
        autoSaveAmountCents: row.autoSaveAmountCents,
        autoSaveFrequency: row.autoSaveFrequency,
        sourceAccountId: row.sourceAccountId,
        note: row.note,
        createdAt: row.createdAt,
      );
}
