import 'package:flutter/material.dart';

/// Semantic colors that sit on top of the generated [ColorScheme].
/// Widgets should prefer `Theme.of(context).colorScheme` for anything
/// covered there; use [AppColors] only for finance-specific semantics.
class AppColors {
  const AppColors._();

  static const Color income = Color(0xFF2E7D32);
  static const Color incomeContainer = Color(0xFFE3F3E4);
  static const Color expense = Color(0xFFC62828);
  static const Color expenseContainer = Color(0xFFFBE4E4);
  static const Color warning = Color(0xFFF9A825);
  static const Color badge = Color(0xFFFFC107);

  static const Color shimmerBaseLight = Color(0xFFE8EAED);
  static const Color shimmerHighlightLight = Color(0xFFF5F6F8);
  static const Color shimmerBaseDark = Color(0xFF2A2C30);
  static const Color shimmerHighlightDark = Color(0xFF3A3D42);

  /// Selectable wallet accent colors (see "Warna" swatches on the new/edit
  /// wallet form) — first entry is the default for a freshly created wallet.
  static const List<Color> walletPalette = [
    Color(0xFFC6FF3D),
    Color(0xFF3DDCC6),
    Color(0xFF9B5DE5),
    Color(0xFFFF922B),
    Color(0xFFF15BB5),
    Color(0xFF339AF0),
    Color(0xFFFFD43B),
  ];
}
