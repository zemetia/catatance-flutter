import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Blue-accent brand scheme shared by light and dark themes.
final _brandColors = FlexSchemeColor.from(
  primary: const Color(0xFF3D7FFF),
  secondary: const Color(0xFF2FB8A6),
  tertiary: const Color(0xFFFF8A3D),
);

final _subThemes = FlexSubThemesData(
  defaultRadius: 14,
  inputDecoratorRadius: 12,
  elevatedButtonRadius: 12,
  filledButtonRadius: 12,
  outlinedButtonRadius: 12,
  cardRadius: 20,
  bottomSheetRadius: 20,
  cardElevation: 0,
  interactionEffects: true,
  tintedDisabledControls: true,
  useM2StyleDividerInM3: true,
);

ThemeData buildLightTheme() => FlexThemeData.light(
  colors: _brandColors,
  useMaterial3: true,
  subThemesData: _subThemes,
  fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
);

ThemeData buildDarkTheme() => FlexThemeData.dark(
  colors: _brandColors,
  useMaterial3: true,
  subThemesData: _subThemes,
  fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  darkIsTrueBlack: false,
  surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
  blendLevel: 14,
);
