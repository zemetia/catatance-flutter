import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' as db;
import '../domain/budget.dart';
import '../domain/budget_period_type.dart';

class BudgetDraft {
  const BudgetDraft({
    required this.categoryId,
    required this.limitCents,
    required this.periodType,
    this.customStartDate,
    this.customEndDate,
    this.carryOverEnabled = false,
  });

  final int categoryId;
  final int limitCents;
  final BudgetPeriodType periodType;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final bool carryOverEnabled;
}

/// Backs the Anggaran (budget) feature. Queries `Transactions`/`Categories`
/// directly (rather than importing the `transactions`/`categories` feature
/// repositories) per the project's no-cross-feature-import rule.
class BudgetRepository {
  BudgetRepository(this._db);

  final db.AppDatabase _db;

  /// Watches every configured budget, newest first, joined with its category.
  Stream<List<Budget>> watchAll() {
    final query = _db.select(_db.budgets).join([
      innerJoin(_db.categories, _db.categories.id.equalsExp(_db.budgets.categoryId)),
    ])
      ..orderBy([OrderingTerm.desc(_db.budgets.createdAt)]);

    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  /// Watches a single budget by its row [id].
  Stream<Budget?> watchOne(int id) {
    final query = _db.select(_db.budgets).join([
      innerJoin(_db.categories, _db.categories.id.equalsExp(_db.budgets.categoryId)),
    ])
      ..where(_db.budgets.id.equals(id));

    return query.watchSingleOrNull().map((row) => row != null ? _toDomain(row) : null);
  }

  Future<int> insert(BudgetDraft draft) {
    return _db.into(_db.budgets).insert(
          db.BudgetsCompanion.insert(
            categoryId: draft.categoryId,
            limitCents: draft.limitCents,
            periodType: Value(draft.periodType.raw),
            customStartDate: Value(draft.customStartDate),
            customEndDate: Value(draft.customEndDate),
            carryOverEnabled: Value(draft.carryOverEnabled),
          ),
        );
  }

  Future<void> update(int id, BudgetDraft draft) {
    return (_db.update(_db.budgets)..where((b) => b.id.equals(id))).write(
      db.BudgetsCompanion(
        categoryId: Value(draft.categoryId),
        limitCents: Value(draft.limitCents),
        periodType: Value(draft.periodType.raw),
        customStartDate: Value(draft.customStartDate),
        customEndDate: Value(draft.customEndDate),
        carryOverEnabled: Value(draft.carryOverEnabled),
      ),
    );
  }

  Future<void> delete(int id) {
    return (_db.delete(_db.budgets)..where((b) => b.id.equals(id))).go();
  }

  /// Live sum of expense transactions for [categoryId] within
  /// `[start, endExclusive)`.
  Stream<int> watchSpentForCategory(
    int categoryId,
    DateTime start,
    DateTime endExclusive,
  ) {
    final sum = _db.transactions.amountCents.sum();
    final query = _db.selectOnly(_db.transactions)
      ..addColumns([sum])
      ..where(
        _db.transactions.categoryId.equals(categoryId) &
            _db.transactions.date.isBiggerOrEqualValue(start) &
            _db.transactions.date.isSmallerThanValue(endExclusive),
      );

    return query.watchSingle().map((row) => row.read(sum) ?? 0);
  }

  Budget _toDomain(TypedResult row) {
    final budget = row.readTable(_db.budgets);
    final category = row.readTable(_db.categories);
    return Budget(
      id: budget.id,
      categoryId: category.id,
      categoryName: category.name,
      categoryIcon: category.icon,
      categoryColorValue: category.colorValue,
      limitCents: budget.limitCents,
      periodType: BudgetPeriodType.fromRaw(budget.periodType),
      customStartDate: budget.customStartDate,
      customEndDate: budget.customEndDate,
      carryOverEnabled: budget.carryOverEnabled,
      createdAt: budget.createdAt,
    );
  }
}
