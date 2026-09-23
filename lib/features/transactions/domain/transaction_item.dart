import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/constants/currencies.dart';

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.accountId,
    required this.accountName,
    this.accountCurrencyCode = 'IDR',
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryType,
    required this.categoryColorValue,
    required this.amountCents,
    this.note,
    required this.date,
    required this.createdAt,
    this.toAccountName,
  });

  final int id;
  final int accountId;
  final String accountName;
  final String accountCurrencyCode;
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryType;
  final int categoryColorValue;
  final int amountCents;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  /// Destination wallet name for a single-row `transfer` transaction — null
  /// for every other category type, and for legacy `transfer_in`/
  /// `transfer_out` rows (each of those is still its own one-sided row).
  final String? toAccountName;

  bool get isIncome => categoryType == 'income' || categoryType == 'transfer_in';
  bool get isTransfer =>
      categoryType == 'transfer' ||
      categoryType == 'transfer_in' ||
      categoryType == 'transfer_out';

  /// The primary line shown for this transaction: "Transfer dari A ke B"
  /// for a single-row transfer, otherwise the note (falling back to the
  /// category name).
  String get title {
    if (categoryType == 'transfer' && toAccountName != null) {
      return 'Transfer dari $accountName ke $toAccountName';
    }
    return note != null && note!.isNotEmpty ? note! : categoryName;
  }

  Color get categoryColor => Color(categoryColorValue);

  Currency get accountCurrency =>
      Currency.maybeFromCode(accountCurrencyCode) ?? defaultCurrency;

  IconData get iconData => switch (categoryIcon) {
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
        _ => LucideIcons.receipt,
      };
}
