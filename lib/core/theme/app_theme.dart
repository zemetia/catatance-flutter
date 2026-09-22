import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color_theme.dart';

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

ThemeData buildLightTheme([AppColorTheme colorTheme = AppColorTheme.emerald]) =>
    FlexThemeData.light(
      colors: colorTheme.toFlexSchemeColor(),
      useMaterial3: true,
      subThemesData: _subThemes,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
    );

ThemeData buildDarkTheme([AppColorTheme colorTheme = AppColorTheme.emerald]) =>
    FlexThemeData.dark(
      colors: colorTheme.toFlexSchemeColor(),
      useMaterial3: true,
      subThemesData: _subThemes,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      darkIsTrueBlack: false,
      surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
      blendLevel: 14,
    );
