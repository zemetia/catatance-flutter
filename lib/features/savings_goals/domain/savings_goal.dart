import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/utils/formatters.dart';

/// Preset item for selecting an icon/emoji for a savings goal.
class SavingsGoalIconOption {
  const SavingsGoalIconOption({
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

/// Curated icons matching the fintech reference mock.
class SavingsGoalIcons {
  const SavingsGoalIcons._();

  static const List<SavingsGoalIconOption> options = [
    SavingsGoalIconOption(
      key: 'plane',
      emoji: '✈️',
      iconData: LucideIcons.plane,
      label: 'Liburan',
    ),
    SavingsGoalIconOption(
      key: 'laptop',
      emoji: '💻',
      iconData: LucideIcons.laptop,
      label: 'Elektronik',
    ),
    SavingsGoalIconOption(
      key: 'house',
      emoji: '🏠',
      iconData: LucideIcons.house,
      label: 'Rumah',
    ),
    SavingsGoalIconOption(
      key: 'car',
      emoji: '🚗',
      iconData: LucideIcons.car,
      label: 'Kendaraan',
    ),
    SavingsGoalIconOption(
      key: 'ring',
      emoji: '💍',
      iconData: LucideIcons.gem,
      label: 'Pernikahan',
    ),
    SavingsGoalIconOption(
      key: 'graduation',
      emoji: '🎓',
      iconData: LucideIcons.graduation_cap,
      label: 'Pendidikan',
    ),
    SavingsGoalIconOption(
      key: 'phone',
      emoji: '📱',
      iconData: LucideIcons.smartphone,
      label: 'Gadget',
    ),
    SavingsGoalIconOption(
      key: 'game',
      emoji: '🎮',
      iconData: LucideIcons.gamepad_2,
      label: 'Hiburan',
    ),
    SavingsGoalIconOption(
      key: 'beach',
      emoji: '🏖️',
      iconData: LucideIcons.sun,
      label: 'Wisata',
    ),
    SavingsGoalIconOption(
      key: 'baby',
      emoji: '👶',
      iconData: LucideIcons.baby,
      label: 'Anak & Keluarga',
    ),
    SavingsGoalIconOption(
      key: 'health',
      emoji: '🏥',
      iconData: LucideIcons.heart_pulse,
      label: 'Darurat & Medis',
    ),
    SavingsGoalIconOption(
      key: 'hajj',
      emoji: '🕋',
      iconData: LucideIcons.building,
      label: 'Ibadah / Umroh',
    ),
    SavingsGoalIconOption(
      key: 'motorcycle',
      emoji: '🏍️',
      iconData: LucideIcons.bike,
      label: 'Motor',
    ),
    SavingsGoalIconOption(
      key: 'gift',
      emoji: '🎁',
      iconData: LucideIcons.gift,
      label: 'Hadiah / Kado',
    ),
    SavingsGoalIconOption(
      key: 'invest',
      emoji: '🪙',
      iconData: LucideIcons.coins,
      label: 'Investasi / Emas',
    ),
  ];

  static SavingsGoalIconOption get(String key) {
    return options.firstWhere(
      (opt) => opt.key == key,
      orElse: () => options.first,
    );
  }
}

/// Curated gradient presets for the savings goal cards matching the reference image.
class SavingsGoalGradients {
  const SavingsGoalGradients._();

  static const List<LinearGradient> presets = [
    // 0: Coral Sunset / Rose (matching image row 1, #1)
    LinearGradient(
      colors: [Color(0xFFFF8A80), Color(0xFFFF5252)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 1: Periwinkle / Violet (matching image row 1, #2)
    LinearGradient(
      colors: [Color(0xFF8FA8FF), Color(0xFF6366F1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 2: Emerald Mint / Teal (matching image row 1, #3)
    LinearGradient(
      colors: [Color(0xFF2DD4BF), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 3: Peach Orange (matching image row 1, #4)
    LinearGradient(
      colors: [Color(0xFFFFA07A), Color(0xFFFF7043)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 4: Electric Sky Blue (matching image row 1, #5)
    LinearGradient(
      colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 5: Radiant Purple / Magenta (matching image row 2, #1)
    LinearGradient(
      colors: [Color(0xFFA855F7), Color(0xFFD946EF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 6: Golden Sun / Amber (matching image row 2, #2)
    LinearGradient(
      colors: [Color(0xFFFBBF24), Color(0xFFF97316)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 7: Ruby Berry / Crimson (matching image row 2, #3)
    LinearGradient(
      colors: [Color(0xFFFB7185), Color(0xFFE11D48)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 8: Deep Indigo / Ocean
    LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 9: Neon Forest
    LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  static LinearGradient at(int index) {
    if (presets.isEmpty) {
      return const LinearGradient(colors: [Colors.blue, Colors.purple]);
    }
    return presets[index.abs() % presets.length];
  }
}

/// Domain entity representing a savings target (Target Tabungan).
class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.gradientIndex,
    required this.targetAmountCents,
    this.currentAmountCents = 0,
    this.targetDate,
    this.autoSaveEnabled = false,
    this.autoSaveAmountCents = 0,
    this.autoSaveFrequency = 'monthly',
    this.sourceAccountId,
    this.note,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String iconKey;
  final int gradientIndex;
  final int targetAmountCents;
  final int currentAmountCents;
  final DateTime? targetDate;
  final bool autoSaveEnabled;
  final int autoSaveAmountCents;
  final String autoSaveFrequency; // daily | weekly | monthly
  final int? sourceAccountId;
  final String? note;
  final DateTime createdAt;

  SavingsGoalIconOption get iconOption => SavingsGoalIcons.get(iconKey);
  LinearGradient get gradient => SavingsGoalGradients.at(gradientIndex);

  /// Progress from 0.0 to 1.0.
  double get progress {
    if (targetAmountCents <= 0) return 0.0;
    return (currentAmountCents / targetAmountCents).clamp(0.0, 1.0);
  }

  /// Percentage integer (0 to 100).
  int get progressPercentInt => (progress * 100).round();

  /// Formatted percentage string (e.g. `45%`).
  String get progressPercentage => '$progressPercentInt%';

  /// Remaining amount needed in Rupiah cents.
  int get remainingCents {
    final rem = targetAmountCents - currentAmountCents;
    return rem < 0 ? 0 : rem;
  }

  /// Whether the target is fully reached.
  bool get isAchieved => currentAmountCents >= targetAmountCents && targetAmountCents > 0;

  String get formattedTarget => formatRupiah(targetAmountCents);
  String get formattedCurrent => formatRupiah(currentAmountCents);
  String get formattedRemaining => formatRupiah(remainingCents);

  /// Label for the deadline / target date.
  String get deadlineLabel {
    if (targetDate == null) return 'Tanpa deadline';
    return formatDate(targetDate!);
  }

  /// Days remaining until the target date, or null if without deadline.
  int? get daysRemaining {
    if (targetDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate!.year, targetDate!.month, targetDate!.day);
    return target.difference(today).inDays;
  }

  /// Human-friendly deadline status badge.
  String get deadlineStatusLabel {
    if (isAchieved) return 'Tercapai 🎉';
    final days = daysRemaining;
    if (days == null) return 'Tanpa deadline';
    if (days < 0) return 'Lewat ${days.abs()} hari';
    if (days == 0) return 'Hari ini';
    if (days == 1) return 'Besok';
    if (days < 30) return 'Sisa $days hari';
    final months = (days / 30).round();
    return 'Sisa ~$months bulan';
  }

  /// Label for autosave frequency in Indonesian.
  String get autoSaveFrequencyLabel {
    switch (autoSaveFrequency.toLowerCase()) {
      case 'daily':
        return 'Harian';
      case 'weekly':
        return 'Mingguan';
      case 'monthly':
      default:
        return 'Bulanan';
    }
  }

  /// Descriptive autosave badge (e.g. "Rp 500rb / bln").
  String get autoSaveSummary {
    if (!autoSaveEnabled || autoSaveAmountCents <= 0) return 'Autosave nonaktif';
    final compact = formatRupiahCompact(autoSaveAmountCents);
    switch (autoSaveFrequency.toLowerCase()) {
      case 'daily':
        return '$compact / hari';
      case 'weekly':
        return '$compact / mgg';
      case 'monthly':
      default:
        return '$compact / bln';
    }
  }

  SavingsGoal copyWith({
    int? id,
    String? name,
    String? iconKey,
    int? gradientIndex,
    int? targetAmountCents,
    int? currentAmountCents,
    DateTime? targetDate,
    bool? autoSaveEnabled,
    int? autoSaveAmountCents,
    String? autoSaveFrequency,
    int? sourceAccountId,
    String? note,
    DateTime? createdAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      gradientIndex: gradientIndex ?? this.gradientIndex,
      targetAmountCents: targetAmountCents ?? this.targetAmountCents,
      currentAmountCents: currentAmountCents ?? this.currentAmountCents,
      targetDate: targetDate ?? this.targetDate,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
      autoSaveAmountCents: autoSaveAmountCents ?? this.autoSaveAmountCents,
      autoSaveFrequency: autoSaveFrequency ?? this.autoSaveFrequency,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
