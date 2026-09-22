import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// Available curated color themes for the app.
///
/// Designed to offer diverse, eye-friendly aesthetics and avoid single-color
/// eye fatigue.
enum AppColorTheme {
  emerald(
    label: 'Hijau Zamrud',
    subtitle: 'Sejuk & adem di mata',
    primary: Color(0xFF059669),
    secondary: Color(0xFF0D9488),
    tertiary: Color(0xFFD97706),
  ),
  ocean(
    label: 'Biru Samudra',
    subtitle: 'Klasik fintech & profesional',
    primary: Color(0xFF3D7FFF),
    secondary: Color(0xFF2FB8A6),
    tertiary: Color(0xFFFF8A3D),
  ),
  sunset(
    label: 'Jingga Senja',
    subtitle: 'Hangat & rileks tanpa silau',
    primary: Color(0xFFEA580C),
    secondary: Color(0xFFD97706),
    tertiary: Color(0xFF059669),
  ),
  violet(
    label: 'Ungu Bangsawan',
    subtitle: 'Elegan, berkelas, & modern',
    primary: Color(0xFF7C3AED),
    secondary: Color(0xFF0D9488),
    tertiary: Color(0xFFF43F5E),
  ),
  teal(
    label: 'Toska Segar',
    subtitle: 'Keseimbangan damai & tenang',
    primary: Color(0xFF0D9488),
    secondary: Color(0xFF0284C7),
    tertiary: Color(0xFFEAB308),
  ),
  rose(
    label: 'Mawar Karang',
    subtitle: 'Lembut, hangat, & ekspresif',
    primary: Color(0xFFE11D48),
    secondary: Color(0xFF8B5CF6),
    tertiary: Color(0xFFF59E0B),
  ),
  slate(
    label: 'Monokrom Modern',
    subtitle: 'Minimalis & kontras lembut',
    primary: Color(0xFF64748B),
    secondary: Color(0xFF0EA5E9),
    tertiary: Color(0xFF10B981),
  );

  const AppColorTheme({
    required this.label,
    required this.subtitle,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  final String label;
  final String subtitle;
  final Color primary;
  final Color secondary;
  final Color tertiary;

  /// Builds a [FlexSchemeColor] for [FlexThemeData].
  FlexSchemeColor toFlexSchemeColor() {
    return FlexSchemeColor.from(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
    );
  }

  /// Helper to safely parse by name or fallback to default.
  static AppColorTheme fromName(String? name) {
    if (name == null) return AppColorTheme.emerald;
    return AppColorTheme.values.firstWhere(
      (theme) => theme.name == name,
      orElse: () => AppColorTheme.emerald,
    );
  }
}
