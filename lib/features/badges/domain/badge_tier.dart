import 'package:flutter/material.dart';

/// Difficulty/rarity tier of a badge — purely cosmetic (color + label), does
/// not affect unlock logic.
enum BadgeTier {
  bronze,
  silver,
  gold,
  platinum;

  String get label => switch (this) {
        BadgeTier.bronze => 'Perunggu',
        BadgeTier.silver => 'Perak',
        BadgeTier.gold => 'Emas',
        BadgeTier.platinum => 'Platinum',
      };

  Color get color => switch (this) {
        BadgeTier.bronze => const Color(0xFFCD7F32),
        BadgeTier.silver => const Color(0xFFA9B4C0),
        BadgeTier.gold => const Color(0xFFFFC107),
        BadgeTier.platinum => const Color(0xFF7C4DFF),
      };
}
