import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_models.freezed.dart';

/// Total expense for a single category within a date range, plus its share
/// of the range's overall expense total.
@freezed
abstract class CategorySpending with _$CategorySpending {
  const factory CategorySpending({
    required int categoryId,
    required String name,
    required String icon,
    required int colorValue,
    required int totalCents,
    required double share,
    required int count,
  }) = _CategorySpending;
}

/// Total expense/income for a single `#tag` parsed out of transaction notes,
/// plus its share of the range's overall (same-mode) total.
@freezed
abstract class TagSpending with _$TagSpending {
  const factory TagSpending({
    required String tag,
    required int totalCents,
    required double share,
    required int count,
  }) = _TagSpending;
}

/// Total expense for a single calendar day.
@freezed
abstract class DailySpending with _$DailySpending {
  const factory DailySpending({
    required DateTime date,
    required int totalCents,
  }) = _DailySpending;
}

/// Total expense for a single calendar month.
@freezed
abstract class MonthlySpending with _$MonthlySpending {
  const factory MonthlySpending({
    required DateTime month,
    required int totalCents,
  }) = _MonthlySpending;
}

/// Income and expense totals for a single calendar day, backing the
/// "Kalender Cashflow" grid — one entry per day with at least one matching
/// (non-transfer) transaction.
@freezed
abstract class DailyCashflow with _$DailyCashflow {
  const DailyCashflow._();

  const factory DailyCashflow({
    required DateTime date,
    required int incomeCents,
    required int expenseCents,
  }) = _DailyCashflow;

  int get netCents => incomeCents - expenseCents;
}

/// One transaction row for the "Kalender Cashflow" screen's selected-day
/// detail list — a reports-owned projection of a transaction (mirrors
/// `features/transactions/domain/transaction_item.dart`'s shape rather than
/// importing it, per the no-cross-feature-import rule; see THIS.md).
@freezed
abstract class CashflowTransaction with _$CashflowTransaction {
  const CashflowTransaction._();

  const factory CashflowTransaction({
    required int id,
    required String title,
    required String categoryName,
    required String categoryIcon,
    required int categoryColorValue,
    required String accountName,
    required int amountCents,
    required DateTime date,
    required bool isIncome,
    required bool isTransfer,
  }) = _CashflowTransaction;

  Color get categoryColor => Color(categoryColorValue);

  IconData get iconData => categoryIconData(categoryIcon);
}

/// Helper to resolve Lucide icon from category icon name string.
IconData categoryIconData(String iconName) => switch (iconName) {
      'utensils' => LucideIcons.utensils,
      'car' => LucideIcons.car,
      'shopping-bag' => LucideIcons.shopping_bag,
      'zap' => LucideIcons.zap,
      'gamepad-2' => LucideIcons.gamepad_2,
      'heart-pulse' => LucideIcons.heart_pulse,
      'graduation-cap' => LucideIcons.graduation_cap,
      'gift' => LucideIcons.gift,
      'briefcase' => LucideIcons.briefcase,
      'award' => LucideIcons.award,
      'trending-up' => LucideIcons.trending_up,
      'laptop' => LucideIcons.laptop,
      'circle-dollar-sign' => LucideIcons.circle_dollar_sign,
      'arrow-up-right' => LucideIcons.arrow_up_right,
      'arrow-down-left' => LucideIcons.arrow_down_left,
      'arrow-left-right' => LucideIcons.arrow_left_right,
      'credit-card' => LucideIcons.credit_card,
      'banknote' => LucideIcons.banknote,
      _ => LucideIcons.receipt,
    };

/// Aggregate result of comparing every configured [Budgets] row against its
/// category's spend for a date range — a plain computed view-model (not
/// freezed/persisted), same convention as `BudgetItem` in
/// `features/budget/presentation/budget_providers.dart`.
class BudgetComplianceSummary {
  const BudgetComplianceSummary({
    required this.total,
    required this.safeCount,
    required this.cautionCount,
    required this.overCount,
    required this.complianceScore,
  });

  final int total;
  final int safeCount;
  final int cautionCount;
  final int overCount;

  /// 0.0–1.0: `safeCount` counts fully, `cautionCount` counts 60%, `overCount`
  /// counts 0%. `1.0` when there are no budgets configured at all (nothing to
  /// violate).
  final double complianceScore;
}

/// A reports-owned projection of the most-recently-created, not-yet-achieved
/// `SavingsGoals` row — mirrors the shape `features/savings_goals` needs
/// (name + progress), not importing that feature's own `SavingsGoal` domain
/// entity, per the no-cross-feature-import rule (same convention as
/// [CashflowTransaction] mirroring the transactions feature's shape).
class SavingsGoalInsight {
  const SavingsGoalInsight({
    required this.name,
    required this.progressPercent,
    required this.remainingCents,
  });

  final String name;
  final int progressPercent;
  final int remainingCents;
}

/// One category's configured budget limit vs. its spend so far this month —
/// backs the "Boleh nggak beli sesuatu?" simulator's per-category check.
class CategoryBudgetInfo {
  const CategoryBudgetInfo({required this.limitCents, required this.spentCents});

  final int limitCents;
  final int spentCents;
}

/// Which side of the ledger the statistics screen is currently showing.
/// [net] combines both: income counts positive, expense counts negative.
enum ReportMode { expense, income, net }

extension ReportModeLabel on ReportMode {
  String get label => switch (this) {
    ReportMode.expense => 'Pengeluaran',
    ReportMode.income => 'Pemasukan',
    ReportMode.net => 'Bersih',
  };
}

/// Wallet distribution for a single category: which wallets funded this category.
class CategoryWalletSpending {
  const CategoryWalletSpending({
    required this.accountId,
    required this.accountName,
    required this.totalCents,
    required this.share,
    required this.count,
  });

  final int accountId;
  final String accountName;
  final int totalCents;
  final double share;
  final int count;
}

/// Historical monthly total for a single category (e.g. past 6 months).
class CategoryMonthlyTrend {
  const CategoryMonthlyTrend({
    required this.month,
    required this.totalCents,
  });

  final DateTime month;
  final int totalCents;
}

/// Item in the overall "Analisis Kategori" list: compares categories, shows
/// share, transaction count, percentage change vs previous month, and budget status.
class CategoryAnalysisItem {
  const CategoryAnalysisItem({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.type,
    required this.totalCents,
    required this.previousMonthTotalCents,
    required this.share,
    required this.count,
    this.budgetLimitCents,
    this.budgetSpentCents,
  });

  final int categoryId;
  final String name;
  final String icon;
  final int colorValue;
  final String type;
  final int totalCents;
  final int previousMonthTotalCents;
  final double share;
  final int count;
  final int? budgetLimitCents;
  final int? budgetSpentCents;

  Color get color => Color(colorValue);

  IconData get iconData => categoryIconData(icon);

  double? get percentageChange {
    if (previousMonthTotalCents == 0) return null;
    return ((totalCents - previousMonthTotalCents) / previousMonthTotalCents) * 100;
  }
}

/// Comprehensive category flow detail: complete breakdown of a single category's
/// flow in a given month (wallet breakdown, historical trend, tags, transactions, and metrics).
class CategoryFlowDetail {
  const CategoryFlowDetail({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColorValue,
    required this.categoryType,
    required this.totalCents,
    required this.previousMonthTotalCents,
    required this.shareOfTotal,
    required this.transactionCount,
    required this.averageCents,
    required this.budgetLimitCents,
    required this.budgetSpentCents,
    required this.wallets,
    required this.tags,
    required this.monthlyTrends,
    required this.transactions,
    this.biggestTransaction,
  });

  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final int categoryColorValue;
  final String categoryType;
  final int totalCents;
  final int previousMonthTotalCents;
  final double shareOfTotal;
  final int transactionCount;
  final int averageCents;
  final int? budgetLimitCents;
  final int? budgetSpentCents;
  final List<CategoryWalletSpending> wallets;
  final List<TagSpending> tags;
  final List<CategoryMonthlyTrend> monthlyTrends;
  final List<CashflowTransaction> transactions;
  final CashflowTransaction? biggestTransaction;

  Color get color => Color(categoryColorValue);

  IconData get iconData => categoryIconData(categoryIcon);

  double? get percentageChange {
    if (previousMonthTotalCents == 0) return null;
    return ((totalCents - previousMonthTotalCents) / previousMonthTotalCents) * 100;
  }

  int? get budgetRemainingCents {
    if (budgetLimitCents == null) return null;
    return budgetLimitCents! - (budgetSpentCents ?? totalCents);
  }

  double? get budgetUsageRatio {
    if (budgetLimitCents == null || budgetLimitCents == 0) return null;
    return (budgetSpentCents ?? totalCents) / budgetLimitCents!;
  }
}
