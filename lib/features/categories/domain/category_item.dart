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

  IconData get iconData => iconFor(icon);

  /// Resolves a category's stored kebab-case `icon` string (e.g. `utensils`)
  /// to its Lucide glyph. Shared by anything that only has the raw icon
  /// string on hand (e.g. joined DB rows) without a full [CategoryItem].
  static IconData iconFor(String icon) => switch (icon) {
        'utensils' => LucideIcons.utensils,
        'coffee' => LucideIcons.coffee,
        'car' => LucideIcons.car,
        'fuel' => LucideIcons.fuel,
        'route' => LucideIcons.route,
        'square-parking' => LucideIcons.square_parking,
        'repeat' => LucideIcons.repeat,
        'shopping-bag' => LucideIcons.shopping_bag,
        'shopping-cart' => LucideIcons.shopping_cart,
        'shirt' => LucideIcons.shirt,
        'zap' => LucideIcons.zap,
        'gamepad-2' => LucideIcons.gamepad_2,
        'joystick' => LucideIcons.joystick,
        'tv' => LucideIcons.tv,
        'heart-pulse' => LucideIcons.heart_pulse,
        'heart' => LucideIcons.heart,
        'shield' => LucideIcons.shield,
        'graduation-cap' => LucideIcons.graduation_cap,
        'wifi' => LucideIcons.wifi,
        'smartphone' => LucideIcons.smartphone,
        'hand-heart' => LucideIcons.hand_heart,
        'gift' => LucideIcons.gift,
        'house' => LucideIcons.house,
        'hand-coins' => LucideIcons.hand_coins,
        'baby' => LucideIcons.baby,
        'dog' => LucideIcons.dog,
        'package' => LucideIcons.package,
        'sparkles' => LucideIcons.sparkles,
        'dumbbell' => LucideIcons.dumbbell,
        'cigarette' => LucideIcons.cigarette,
        'wine' => LucideIcons.wine,
        'plane' => LucideIcons.plane,
        'hotel' => LucideIcons.hotel,
        'washing-machine' => LucideIcons.washing_machine,
        'wallet' => LucideIcons.wallet,
        'bitcoin' => LucideIcons.bitcoin,
        'palette' => LucideIcons.palette,
        'app-window' => LucideIcons.app_window,
        'party-popper' => LucideIcons.party_popper,
        'stethoscope' => LucideIcons.stethoscope,
        'scale' => LucideIcons.scale,
        'briefcase' => LucideIcons.briefcase,
        'briefcase-business' => LucideIcons.briefcase_business,
        'piggy-bank' => LucideIcons.piggy_bank,
        'award' => LucideIcons.award,
        'trending-up' => LucideIcons.trending_up,
        'laptop' => LucideIcons.laptop,
        'percent' => LucideIcons.percent,
        'key' => LucideIcons.key,
        'coins' => LucideIcons.coins,
        'landmark' => LucideIcons.landmark,
        'handshake' => LucideIcons.handshake,
        'at-sign' => LucideIcons.at_sign,
        'gem' => LucideIcons.gem,
        'circle-dollar-sign' => LucideIcons.circle_dollar_sign,
        'credit-card' => LucideIcons.credit_card,
        'banknote' => LucideIcons.banknote,
        'arrow-up-right' => LucideIcons.arrow_up_right,
        'arrow-down-left' => LucideIcons.arrow_down_left,
        'store' => LucideIcons.store,
        'users' => LucideIcons.users,
        'megaphone' => LucideIcons.megaphone,
        'truck' => LucideIcons.truck,
        'wrench' => LucideIcons.wrench,
        'hammer' => LucideIcons.hammer,
        'file-text' => LucideIcons.file_text,
        'layout-dashboard' => LucideIcons.layout_dashboard,
        'boxes' => LucideIcons.boxes,
        'stamp' => LucideIcons.stamp,
        _ => LucideIcons.receipt,
      };
}
