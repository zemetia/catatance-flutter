import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/utils/formatters.dart';

/// Icon preset option for wishlist items.
class WishlistIconOption {
  const WishlistIconOption({
    required this.key,
    required this.emoji,
    required this.iconData,
    required this.label,
  });

  final String key;
  final String emoji;
  final IconData iconData;
  final String label;
}

/// Curated icon presets for wishlist items.
class WishlistIcons {
  const WishlistIcons._();

  static const List<WishlistIconOption> options = [
    WishlistIconOption(
      key: 'shopping-bag',
      emoji: '🛍️',
      iconData: LucideIcons.shopping_bag,
      label: 'Belanja',
    ),
    WishlistIconOption(
      key: 'smartphone',
      emoji: '📱',
      iconData: LucideIcons.smartphone,
      label: 'Gadget',
    ),
    WishlistIconOption(
      key: 'laptop',
      emoji: '💻',
      iconData: LucideIcons.laptop,
      label: 'Laptop / PC',
    ),
    WishlistIconOption(
      key: 'headphones',
      emoji: '🎧',
      iconData: LucideIcons.headphones,
      label: 'Audio / Musik',
    ),
    WishlistIconOption(
      key: 'watch',
      emoji: '⌚',
      iconData: LucideIcons.watch,
      label: 'Jam & Aksesori',
    ),
    WishlistIconOption(
      key: 'shirt',
      emoji: '👕',
      iconData: LucideIcons.shirt,
      label: 'Fashion',
    ),
    WishlistIconOption(
      key: 'gamepad-2',
      emoji: '🎮',
      iconData: LucideIcons.gamepad_2,
      label: 'Gaming & Hobi',
    ),
    WishlistIconOption(
      key: 'camera',
      emoji: '📷',
      iconData: LucideIcons.camera,
      label: 'Fotografi',
    ),
    WishlistIconOption(
      key: 'tv',
      emoji: '📺',
      iconData: LucideIcons.tv,
      label: 'Elektronik',
    ),
    WishlistIconOption(
      key: 'bike',
      emoji: '🚲',
      iconData: LucideIcons.bike,
      label: 'Kendaraan',
    ),
    WishlistIconOption(
      key: 'sparkles',
      emoji: '✨',
      iconData: LucideIcons.sparkles,
      label: 'Keinginan Impian',
    ),
    WishlistIconOption(
      key: 'coffee',
      emoji: '☕',
      iconData: LucideIcons.coffee,
      label: 'Lifestyle',
    ),
  ];

  static WishlistIconOption get(String key) {
    return options.firstWhere(
      (opt) => opt.key == key,
      orElse: () => options.first,
    );
  }
}

/// Domain entity representing an anti-impulse wishlist item.
class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.name,
    required this.estimatedPriceCents,
    this.reason,
    this.url,
    this.coolingDays = 30,
    required this.createdAt,
    required this.readyAt,
    this.status = 'cooling_off', // 'cooling_off', 'ready', 'cancelled', 'converted', 'purchased'
    this.decisionDate,
    this.decisionNote,
    this.priority = 'medium', // 'low', 'medium', 'high'
    this.categoryName,
    this.iconKey = 'shopping-bag',
    this.savedAmountCents = 0,
  });

  final int id;
  final String name;
  final int estimatedPriceCents;
  final String? reason;
  final String? url;
  final int coolingDays;
  final DateTime createdAt;
  final DateTime readyAt;
  final String status;
  final DateTime? decisionDate;
  final String? decisionNote;
  final String priority;
  final String? categoryName;
  final String iconKey;
  final int savedAmountCents;

  WishlistIconOption get iconOption => WishlistIcons.get(iconKey);

  /// Whether the item is still in active cooling off.
  bool get isCoolingOff {
    if (status != 'cooling_off') return false;
    return DateTime.now().isBefore(readyAt);
  }

  /// Whether the cooling period has ended and it's time to evaluate.
  bool get isReady {
    if (status == 'ready') return true;
    if (status == 'cooling_off' && !DateTime.now().isBefore(readyAt)) return true;
    return false;
  }

  /// Whether the user gave up the item and saved the money!
  bool get isCancelled => status == 'cancelled';

  /// Whether it was converted into a savings goal.
  bool get isConverted => status == 'converted';

  /// Whether it was purchased.
  bool get isPurchased => status == 'purchased';

  /// Whether the item has already had a final decision.
  bool get isDecided => isCancelled || isConverted || isPurchased;

  /// Remaining days until cooling-off period completes.
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(readyAt)) return 0;
    final diffSec = readyAt.difference(now).inSeconds;
    return (diffSec / 86400).ceil().clamp(0, 9999);
  }

  /// Progress from 0.0 to 1.0 of the cooling-off waiting period.
  double get progress {
    final totalSec = readyAt.difference(createdAt).inSeconds;
    if (totalSec <= 0) return 1.0;
    final elapsedSec = DateTime.now().difference(createdAt).inSeconds;
    return (elapsedSec / totalSec).clamp(0.0, 1.0);
  }

  int get progressPercentInt => (progress * 100).round();

  String get formattedPrice => formatRupiah(estimatedPriceCents);

  String get formattedSaved =>
      formatRupiah(savedAmountCents > 0 ? savedAmountCents : estimatedPriceCents);

  String get priorityLabel => switch (priority) {
    'high' => 'Prioritas Tinggi',
    'low' => 'Prioritas Rendah',
    _ => 'Prioritas Sedang',
  };

  WishlistItem copyWith({
    int? id,
    String? name,
    int? estimatedPriceCents,
    String? reason,
    String? url,
    int? coolingDays,
    DateTime? createdAt,
    DateTime? readyAt,
    String? status,
    DateTime? decisionDate,
    String? decisionNote,
    String? priority,
    String? categoryName,
    String? iconKey,
    int? savedAmountCents,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      name: name ?? this.name,
      estimatedPriceCents: estimatedPriceCents ?? this.estimatedPriceCents,
      reason: reason ?? this.reason,
      url: url ?? this.url,
      coolingDays: coolingDays ?? this.coolingDays,
      createdAt: createdAt ?? this.createdAt,
      readyAt: readyAt ?? this.readyAt,
      status: status ?? this.status,
      decisionDate: decisionDate ?? this.decisionDate,
      decisionNote: decisionNote ?? this.decisionNote,
      priority: priority ?? this.priority,
      categoryName: categoryName ?? this.categoryName,
      iconKey: iconKey ?? this.iconKey,
      savedAmountCents: savedAmountCents ?? this.savedAmountCents,
    );
  }
}

/// Aggregated summary of all wishlist items.
class WishlistSummary {
  const WishlistSummary({
    required this.totalSavedCents,
    required this.coolingCount,
    required this.readyCount,
    required this.totalCount,
  });

  final int totalSavedCents;
  final int coolingCount;
  final int readyCount;
  final int totalCount;

  String get formattedTotalSaved => formatRupiah(totalSavedCents);
}
