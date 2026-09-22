import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_color_theme.dart';

/// Immutable model holding the user's active theme configuration.
class ThemeSettings {
  const ThemeSettings({
    this.colorTheme = AppColorTheme.emerald,
    this.themeMode = ThemeMode.dark,
  });

  final AppColorTheme colorTheme;
  final ThemeMode themeMode;

  ThemeSettings copyWith({
    AppColorTheme? colorTheme,
    ThemeMode? themeMode,
  }) {
    return ThemeSettings(
      colorTheme: colorTheme ?? this.colorTheme,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() => {
    'colorTheme': colorTheme.name,
    'themeMode': themeMode.name,
  };

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    final themeName = json['colorTheme'] as String?;
    final modeName = json['themeMode'] as String?;

    final colorTheme = AppColorTheme.fromName(themeName);
    final themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => ThemeMode.dark,
    );

    return ThemeSettings(
      colorTheme: colorTheme,
      themeMode: themeMode,
    );
  }
}

/// Lightweight file-backed storage for theme preferences.
class ThemeStorage {
  const ThemeStorage();

  static const _fileName = 'theme_settings.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _fileName));
  }

  Future<ThemeSettings?> load() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ThemeSettings.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(ThemeSettings settings) async {
    try {
      final file = await _getFile();
      final raw = jsonEncode(settings.toJson());
      await file.writeAsString(raw);
    } catch (_) {
      // Best-effort write; non-fatal if storage fails.
    }
  }
}

/// Riverpod notifier managing active theme settings and auto-persisting changes.
class ThemeSettingsNotifier extends Notifier<ThemeSettings> {
  final _storage = const ThemeStorage();

  @override
  ThemeSettings build() {
    _loadPersistedSettings();
    return const ThemeSettings();
  }

  Future<void> _loadPersistedSettings() async {
    final saved = await _storage.load();
    if (saved != null) {
      state = saved;
    }
  }

  void setColorTheme(AppColorTheme colorTheme) {
    state = state.copyWith(colorTheme: colorTheme);
    _storage.save(state);
  }

  void setThemeMode(ThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
    _storage.save(state);
  }
}

final themeSettingsProvider =
    NotifierProvider<ThemeSettingsNotifier, ThemeSettings>(
  ThemeSettingsNotifier.new,
);
