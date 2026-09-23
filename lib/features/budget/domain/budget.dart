import 'package:flutter/material.dart';

import '../../categories/domain/category_item.dart';
import 'budget_period_type.dart';

/// A persisted budget configuration for one category (joined with its
/// category's display info). Spending/period-progress is computed live by
/// the presentation layer, not stored here.
class Budget {
  const Budget({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColorValue,
    required this.limitCents,
    required this.periodType,
    this.customStartDate,
    this.customEndDate,
    required this.carryOverEnabled,
    required this.createdAt,
  });

  final int id;
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final int categoryColorValue;
  final int limitCents;
  final BudgetPeriodType periodType;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final bool carryOverEnabled;
  final DateTime createdAt;

  Color get categoryColor => Color(categoryColorValue);

  IconData get iconData => CategoryItem.iconFor(categoryIcon);

  BudgetPeriod periodAt(DateTime reference) => resolveBudgetPeriod(
    periodType,
    reference,
    customStart: customStartDate,
    customEndInclusive: customEndDate,
  );

  BudgetPeriod? previousPeriodAt(DateTime reference) =>
      resolvePreviousBudgetPeriod(periodType, reference);
}
