import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Persisted preferences for the "Backup & Data" screen.
class BackupSettings {
  const BackupSettings({this.autoBackupEnabled = false, this.lastBackupAt});

  final bool autoBackupEnabled;
  final DateTime? lastBackupAt;

  Map<String, dynamic> toJson() => {
    'autoBackupEnabled': autoBackupEnabled,
    'lastBackupAt': lastBackupAt?.toIso8601String(),
  };

  factory BackupSettings.fromJson(Map<String, dynamic> json) {
    final raw = json['lastBackupAt'] as String?;
    return BackupSettings(
      autoBackupEnabled: json['autoBackupEnabled'] == true,
      lastBackupAt: raw != null ? DateTime.tryParse(raw) : null,
    );
  }
}

/// Lightweight file-backed storage for backup preferences, sibling to
/// `ThemeStorage`/`AppMetaStorage`.
class BackupSettingsStorage {
  const BackupSettingsStorage();

  static const _fileName = 'backup_settings.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _fileName));
  }

  Future<BackupSettings> load() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return const BackupSettings();
      final raw = await file.readAsString();
      return BackupSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const BackupSettings();
    }
  }

  Future<void> save(BackupSettings settings) async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(settings.toJson()));
    } catch (_) {
      // Best-effort write; non-fatal if storage fails.
    }
  }
}
