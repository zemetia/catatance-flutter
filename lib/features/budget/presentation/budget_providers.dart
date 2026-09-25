import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart' hide Budget;
import '../../../core/utils/formatters.dart';
import '../data/budget_repository.dart';
import '../domain/budget.dart';
import '../domain/budget_period_type.dart';

export '../data/budget_repository.dart' show BudgetDraft;
export '../domain/budget.dart' show Budget;
export '../domain/budget_period_type.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(appDatabaseProvider));
});

/// Raw persisted budget configs, joined with their category.
final budgetConfigListProvider = StreamProvider.autoDispose<List<Budget>>((ref) {
  return ref.watch(budgetRepositoryProvider).watchAll();
});

/// A single budget config by its row id (for the edit form).
final budgetDetailProvider =
    StreamProvider.autoDispose.family<Budget?, int>((ref, id) {
  return ref.watch(budgetRepositoryProvider).watchOne(id);
});

typedef _SpentKey = ({int categoryId, DateTime start, DateTime endExclusive});

final _categorySpentProvider =
    StreamProvider.autoDispose.family<int, _SpentKey>((ref, key) {
  return ref
      .watch(budgetRepositoryProvider)
      .watchSpentForCategory(key.categoryId, key.start, key.endExclusive);
});

/// Severity of how close a budget is to (or past) its limit — drives the
/// progress bar / caption color in [BudgetProgressCard].
enum BudgetStatus { safe, caution, over }

/// A single category budget resolved for its *current* active period: real
/// spend + carry-over pulled live from SQLite transactions.
class BudgetItem {
  const BudgetItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.spentCents,
    required this.limitCents,
    required this.carryOverCents,
    required this.periodType,
    required this.periodLabel,
    required this.daysLeft,
    required this.carryOverEnabled,
  });

  final int id;
  final int categoryId;
  final String name;
  final IconData icon;
  final int spentCents;
  final int limitCents;
  final int carryOverCents;
  final BudgetPeriodType periodType;
  final String periodLabel;
  final int daysLeft;
  final bool carryOverEnabled;

  /// Effective spending ceiling for the active period: the budget's own
  /// limit plus any leftover carried over from the previous period.
  int get totalLimitCents => limitCents + carryOverCents;

  double get progress =>
      totalLimitCents == 0 ? 0 : (spentCents / totalLimitCents).clamp(0.0, 1.0);

  int get remainingCents => (totalLimitCents - spentCents).clamp(0, totalLimitCents);

  BudgetStatus get status {
    if (spentCents >= totalLimitCents) return BudgetStatus.over;
    if (progress >= 0.8) return BudgetStatus.caution;
    return BudgetStatus.safe;
  }
}

/// Live, period-aware budgets for every configured [Budget], recomputed
/// automatically whenever matching transactions change.
final liveBudgetListProvider = Provider.autoDispose<List<BudgetItem>>((ref) {
  final configs = ref.watch(budgetConfigListProvider).value ?? const [];
  final now = DateTime.now();

  return [for (final config in configs) _watchBudgetItem(ref, config, now)];
});

BudgetItem _watchBudgetItem(Ref ref, Budget config, DateTime now) {
  final period = config.periodAt(now);
  final spent = ref
          .watch(
            _categorySpentProvider((
              categoryId: config.categoryId,
              start: period.start,
              endExclusive: period.endExclusive,
            )),
          )
          .value ??
      0;

  var carryOverCents = 0;
  if (config.carryOverEnabled) {
    final previousPeriod = config.previousPeriodAt(now);
    if (previousPeriod != null) {
      final previousSpent = ref
              .watch(
                _categorySpentProvider((
                  categoryId: config.categoryId,
                  start: previousPeriod.start,
                  endExclusive: previousPeriod.endExclusive,
                )),
              )
              .value ??
          0;
      final previousRemaining = config.limitCents - previousSpent;
      if (previousRemaining > 0) carryOverCents = previousRemaining;
    }
  }

  return BudgetItem(
    id: config.id,
    categoryId: config.categoryId,
    name: config.categoryName,
    icon: config.iconData,
    spentCents: spent,
    limitCents: config.limitCents,
    carryOverCents: carryOverCents,
    periodType: config.periodType,
    periodLabel: _periodLabel(config.periodType, period),
    daysLeft: period.daysLeftFrom(now),
    carryOverEnabled: config.carryOverEnabled,
  );
}

String _periodLabel(BudgetPeriodType type, BudgetPeriod period) {
  if (type == BudgetPeriodType.monthly) {
    return DateFormat('MMMM yyyy', 'id_ID').format(period.start);
  }
  return '${formatDateShort(period.start)} - ${formatDateShort(period.lastIncludedDay)}';
}

/// Manages async create/update/delete actions on budgets.
class BudgetActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<int?> createBudget(BudgetDraft draft) async {
    state = const AsyncLoading();
    int? result;
    state = await AsyncValue.guard(() async {
      result = await ref.read(budgetRepositoryProvider).insert(draft);
    });
    return result;
  }

  Future<void> updateBudget(int id, BudgetDraft draft) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(budgetRepositoryProvider).update(id, draft),
    );
  }

  Future<void> deleteBudget(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(budgetRepositoryProvider).delete(id),
    );
  }
}

final budgetActionProvider = AsyncNotifierProvider<BudgetActionNotifier, void>(
  BudgetActionNotifier.new,
);

/// "September" style label for the current budget period.
final currentBudgetPeriodLabelProvider = Provider<String>((ref) {
  return DateFormat('MMMM', 'id_ID').format(DateTime.now());
});
