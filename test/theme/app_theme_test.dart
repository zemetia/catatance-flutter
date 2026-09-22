import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/theme/app_color_theme.dart';
import 'package:pencatatan_keuangan/core/theme/app_theme.dart';
import 'package:pencatatan_keuangan/core/theme/theme_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppColorTheme', () {
    test('has 7 diverse color palettes with valid metadata', () {
      expect(AppColorTheme.values.length, 7);

      for (final theme in AppColorTheme.values) {
        expect(theme.label, isNotEmpty);
        expect(theme.subtitle, isNotEmpty);
        expect(theme.primary, isNotNull);
        expect(theme.secondary, isNotNull);
        expect(theme.tertiary, isNotNull);

        final flexScheme = theme.toFlexSchemeColor();
        expect(flexScheme.primary, theme.primary);
        expect(flexScheme.secondary, theme.secondary);
        expect(flexScheme.tertiary, theme.tertiary);
      }
    });

    test('fromName returns matching theme or falls back to emerald', () {
      expect(AppColorTheme.fromName('sunset'), AppColorTheme.sunset);
      expect(AppColorTheme.fromName('violet'), AppColorTheme.violet);
      expect(AppColorTheme.fromName('non_existent'), AppColorTheme.emerald);
      expect(AppColorTheme.fromName(null), AppColorTheme.emerald);
    });

    test('buildLightTheme and buildDarkTheme generate valid ThemeData', () {
      for (final theme in AppColorTheme.values) {
        final light = buildLightTheme(theme);
        final dark = buildDarkTheme(theme);

        expect(light.brightness, Brightness.light);
        expect(dark.brightness, Brightness.dark);
        expect(light.colorScheme.primary, isNotNull);
        expect(dark.colorScheme.primary, isNotNull);
      }
    });
  });

  group('ThemeSettings', () {
    test('serializes and deserializes JSON correctly', () {
      const original = ThemeSettings(
        colorTheme: AppColorTheme.sunset,
        themeMode: ThemeMode.light,
      );

      final json = original.toJson();
      expect(json['colorTheme'], 'sunset');
      expect(json['themeMode'], 'light');

      final restored = ThemeSettings.fromJson(json);
      expect(restored.colorTheme, AppColorTheme.sunset);
      expect(restored.themeMode, ThemeMode.light);
    });

    test('handles fallback on corrupted JSON gracefully', () {
      final restored = ThemeSettings.fromJson({
        'colorTheme': 'unknown_theme',
        'themeMode': 'unknown_mode',
      });

      expect(restored.colorTheme, AppColorTheme.emerald);
      expect(restored.themeMode, ThemeMode.dark);
    });
  });

  group('ThemeSettingsNotifier', () {
    test('updates color theme and theme mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeSettingsProvider.notifier);

      notifier.setColorTheme(AppColorTheme.violet);
      expect(
        container.read(themeSettingsProvider).colorTheme,
        AppColorTheme.violet,
      );

      notifier.setThemeMode(ThemeMode.light);
      expect(
        container.read(themeSettingsProvider).themeMode,
        ThemeMode.light,
      );
    });
  });
}
