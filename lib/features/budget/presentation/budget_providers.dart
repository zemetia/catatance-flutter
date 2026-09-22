import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

/// Severity of how close a budget is to (or past) its limit — drives the
/// progress bar / caption color in [BudgetProgressCard].
enum BudgetStatus { safe, caution, over }

/// A single category budget for the active period (e.g. this month).
class BudgetItem {
  const BudgetItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.spentCents,
    required this.limitCents,
    required this.daysLeft,
  });

  final int id;
  final String name;
  final IconData icon;
  final int spentCents;
  final int limitCents;
  final int daysLeft;

  double get progress => limitCents == 0 ? 0 : (spentCents / limitCents).clamp(0.0, 1.0);

  int get remainingCents => (limitCents - spentCents).clamp(0, limitCents);

  BudgetStatus get status {
    if (spentCents >= limitCents) return BudgetStatus.over;
    if (progress >= 0.8) return BudgetStatus.caution;
    return BudgetStatus.safe;
  }
}

/// A savings target the user is putting money toward.
class SavingsGoalItem {
  const SavingsGoalItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.savedCents,
    required this.targetCents,
  });

  final int id;
  final String name;
  final IconData icon;
  final int savedCents;
  final int targetCents;

  double get progress => targetCents == 0 ? 0 : (savedCents / targetCents).clamp(0.0, 1.0);
}

/// Active-period budgets. Empty until the user creates one.
final budgetListProvider = StateProvider<List<BudgetItem>>((ref) => const []);

/// Savings goals. Empty until the user creates one.
final savingsGoalListProvider = StateProvider<List<SavingsGoalItem>>((ref) => const []);

/// "September" style label for the current budget period.
final currentBudgetPeriodLabelProvider = Provider<String>((ref) {
  return DateFormat('MMMM', 'id_ID').format(DateTime.now());
});
