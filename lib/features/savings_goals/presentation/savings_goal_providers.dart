import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart' hide SavingsGoal;
import '../data/savings_goal_repository.dart';
import '../domain/savings_goal.dart';

export '../data/savings_goal_repository.dart' show SavingsGoalDraft;
export '../domain/savings_goal.dart';

final savingsGoalRepositoryProvider = Provider<SavingsGoalRepository>((ref) {
  return SavingsGoalRepository(ref.watch(appDatabaseProvider));
});

/// Watches all saved savings targets.
final savingsGoalListProvider =
    StreamProvider.autoDispose<List<SavingsGoal>>((ref) {
  return ref.watch(savingsGoalRepositoryProvider).watchAll();
});

/// Watches a single savings target by its [id].
final savingsGoalDetailProvider =
    StreamProvider.autoDispose.family<SavingsGoal?, int>((ref, id) {
  return ref.watch(savingsGoalRepositoryProvider).watchGoal(id);
});

/// Total target across all goals.
final totalSavingsTargetProvider = Provider.autoDispose<int>((ref) {
  final goals = ref.watch(savingsGoalListProvider).value ?? const <SavingsGoal>[];
  return goals.fold<int>(0, (sum, g) => sum + g.targetAmountCents);
});

/// Total saved funds across all goals.
final totalSavedAmountProvider = Provider.autoDispose<int>((ref) {
  final goals = ref.watch(savingsGoalListProvider).value ?? const <SavingsGoal>[];
  return goals.fold<int>(0, (sum, g) => sum + g.currentAmountCents);
});

/// Number of goals that have reached 100%.
final achievedGoalsCountProvider = Provider.autoDispose<int>((ref) {
  final goals = ref.watch(savingsGoalListProvider).value ?? const <SavingsGoal>[];
  return goals.where((g) => g.isAchieved).length;
});

/// Total active autosave monthly commitment across all goals.
final totalMonthlyAutoSaveProvider = Provider.autoDispose<int>((ref) {
  final goals = ref.watch(savingsGoalListProvider).value ?? const <SavingsGoal>[];
  return goals.fold<int>(0, (sum, g) {
    if (!g.autoSaveEnabled || g.autoSaveAmountCents <= 0 || g.isAchieved) return sum;
    switch (g.autoSaveFrequency.toLowerCase()) {
      case 'daily':
        return sum + (g.autoSaveAmountCents * 30);
      case 'weekly':
        return sum + ((g.autoSaveAmountCents * 4.33).round());
      case 'monthly':
      default:
        return sum + g.autoSaveAmountCents;
    }
  });
});

/// Count of goals with active autosave.
final activeAutoSaveCountProvider = Provider.autoDispose<int>((ref) {
  final goals = ref.watch(savingsGoalListProvider).value ?? const <SavingsGoal>[];
  return goals.where((g) => g.autoSaveEnabled && !g.isAchieved).length;
});

/// Nearest upcoming goal with a future target date that is not achieved yet.
final nearestSavingsGoalProvider = Provider.autoDispose<SavingsGoal?>((ref) {
  final goals = ref.watch(savingsGoalListProvider).value ?? const <SavingsGoal>[];
  final pendingWithDates = goals
      .where((g) => !g.isAchieved && g.targetDate != null)
      .toList()
    ..sort((a, b) => a.targetDate!.compareTo(b.targetDate!));
  return pendingWithDates.firstOrNull;
});

class SavingsGoalActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<int?> createGoal(SavingsGoalDraft draft) async {
    state = const AsyncLoading();
    int? result;
    state = await AsyncValue.guard(() async {
      result = await ref.read(savingsGoalRepositoryProvider).insert(draft);
    });
    return result;
  }

  Future<void> updateGoal(int id, SavingsGoalDraft draft) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(savingsGoalRepositoryProvider).update(id, draft),
    );
  }

  Future<void> deleteGoal(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(savingsGoalRepositoryProvider).delete(id),
    );
  }

  Future<void> deposit(
    int goalId,
    int amountCents, {
    int? sourceAccountId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(savingsGoalRepositoryProvider).deposit(
            goalId,
            amountCents,
            sourceAccountId: sourceAccountId,
          ),
    );
  }

  Future<void> withdraw(
    int goalId,
    int amountCents, {
    int? targetAccountId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(savingsGoalRepositoryProvider).withdraw(
            goalId,
            amountCents,
            targetAccountId: targetAccountId,
          ),
    );
  }

  Future<void> toggleAutoSave(int goalId, bool enabled) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(savingsGoalRepositoryProvider).toggleAutoSave(goalId, enabled),
    );
  }

  Future<bool> executeAutoSave(int goalId) async {
    state = const AsyncLoading();
    bool success = false;
    state = await AsyncValue.guard(() async {
      success = await ref.read(savingsGoalRepositoryProvider).executeAutoSave(goalId);
    });
    return success;
  }
}

final savingsGoalActionProvider =
    AsyncNotifierProvider.autoDispose<SavingsGoalActionNotifier, void>(
  SavingsGoalActionNotifier.new,
);
