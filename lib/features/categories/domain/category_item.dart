import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.colorValue,
  });

  final int id;
  final String name;
  final String icon;
  final String type; // 'income' | 'expense'
  final int colorValue;

  bool get isIncome => type == 'income';
  Color get color => Color(colorValue);

  IconData get iconData => switch (icon) {
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
