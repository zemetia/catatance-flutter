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
      // Soft-tinted surfaces instead of a stark FFFFFF background — every
      // surface picks up a faint wash of the seed color so cards read as
      // "off-white", not paper-white.
      surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
      blendLevel: 9,
    );

ThemeData buildDarkTheme([AppColorTheme colorTheme = AppColorTheme.emerald]) =>
    FlexThemeData.dark(
      colors: colorTheme.toFlexSchemeColor(),
      useMaterial3: true,
      subThemesData: _subThemes,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      // Never true black — surfaces stay a soft charcoal tinted with the
      // seed color so cards/sheets read as "near-black", not 000000.
      darkIsTrueBlack: false,
      surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
      blendLevel: 18,
    );
