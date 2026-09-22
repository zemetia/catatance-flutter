import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.accountId,
    required this.accountName,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryType,
    required this.categoryColorValue,
    required this.amountCents,
    this.note,
    required this.date,
    required this.createdAt,
  });

  final int id;
  final int accountId;
  final String accountName;
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryType;
  final int categoryColorValue;
  final int amountCents;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  bool get isIncome => categoryType == 'income';
  Color get categoryColor => Color(categoryColorValue);

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
        _ => LucideIcons.receipt,
      };
}
