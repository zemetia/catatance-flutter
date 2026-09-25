import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/backup_service.dart';
import '../data/backup_repository.dart';
import '../data/backup_settings_storage.dart';

final backupServiceProvider = Provider<BackupService>((ref) => const BackupService());

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(backupServiceProvider),
  );
});

/// Combined state for the "Backup & Data" screen: available backups plus the
/// auto-backup preference, persisted via [BackupSettingsStorage].
class BackupScreenState {
  const BackupScreenState({
    required this.backups,
    required this.autoBackupEnabled,
    required this.lastBackupAt,
    required this.backupDirPath,
    this.isWorking = false,
  });

  final List<BackupFile> backups;
  final bool autoBackupEnabled;
  final DateTime? lastBackupAt;
  final String backupDirPath;
  final bool isWorking;

  BackupScreenState copyWith({
    List<BackupFile>? backups,
    bool? autoBackupEnabled,
    DateTime? lastBackupAt,
    String? backupDirPath,
    bool? isWorking,
  }) {
    return BackupScreenState(
      backups: backups ?? this.backups,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      backupDirPath: backupDirPath ?? this.backupDirPath,
      isWorking: isWorking ?? this.isWorking,
    );
  }
}

class BackupScreenNotifier extends AsyncNotifier<BackupScreenState> {
  final _settingsStorage = const BackupSettingsStorage();

  BackupRepository get _repo => ref.read(backupRepositoryProvider);

  @override
  Future<BackupScreenState> build() async {
    final settings = await _settingsStorage.load();
    final backups = await _repo.listBackups();
    final dirPath = await _repo.backupDirectoryPath();
    return BackupScreenState(
      backups: backups,
      autoBackupEnabled: settings.autoBackupEnabled,
      lastBackupAt: settings.lastBackupAt,
      backupDirPath: dirPath,
    );
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) return;
    final backups = await _repo.listBackups();
    state = AsyncData(current.copyWith(backups: backups));
  }

  /// Returns an error message on failure, `null` on success.
  Future<String?> backupNow() async {
    final current = state.value;
    if (current == null) return null;
    state = AsyncData(current.copyWith(isWorking: true));
    try {
      await _repo.createBackup();
      final now = DateTime.now();
      await _settingsStorage.save(
        BackupSettings(autoBackupEnabled: current.autoBackupEnabled, lastBackupAt: now),
      );
      final backups = await _repo.listBackups();
      state = AsyncData(
        current.copyWith(backups: backups, lastBackupAt: now, isWorking: false),
      );
      return null;
    } catch (e) {
      state = AsyncData(current.copyWith(isWorking: false));
      return e.toString();
    }
  }

  /// Overwrites the live database with [backup]. Returns an error message on
  /// failure, `null` on success — every repository provider watches
  /// `appDatabaseProvider`, so invalidating it here reconnects the whole app
  /// to the restored file without needing a full app restart.
  Future<String?> restore(BackupFile backup) async {
    final current = state.value;
    if (current == null) return null;
    state = AsyncData(current.copyWith(isWorking: true));
    try {
      await _repo.closeDatabaseForRestore();
      await _repo.restoreBackup(backup);
      ref.invalidate(appDatabaseProvider);
      state = AsyncData(current.copyWith(isWorking: false));
      return null;
    } catch (e) {
      state = AsyncData(current.copyWith(isWorking: false));
      return e.toString();
    }
  }

  Future<String?> delete(BackupFile backup) async {
    final current = state.value;
    if (current == null) return null;
    try {
      await _repo.deleteBackup(backup);
      final backups = await _repo.listBackups();
      state = AsyncData(current.copyWith(backups: backups));
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> setAutoBackupEnabled(bool value) async {
    final current = state.value;
    if (current == null) return;
    await _settingsStorage.save(
      BackupSettings(autoBackupEnabled: value, lastBackupAt: current.lastBackupAt),
    );
    state = AsyncData(current.copyWith(autoBackupEnabled: value));
  }

  /// Called once on app start (see `App._runAutoBackupIfDue`) — if auto
  /// backup is on and the last one was over a day ago, backs up silently.
  /// Reads/writes settings and the repository directly (not `state`) so it's
  /// safe to call before this notifier's own `build()` has resolved.
  Future<void> runAutoBackupIfDue() async {
    final settings = await _settingsStorage.load();
    if (!settings.autoBackupEnabled) return;
    final last = settings.lastBackupAt;
    if (last != null && DateTime.now().difference(last) < const Duration(hours: 24)) {
      return;
    }
    try {
      await _repo.createBackup();
      await _settingsStorage.save(
        BackupSettings(autoBackupEnabled: true, lastBackupAt: DateTime.now()),
      );
      await refresh();
    } catch (_) {
      // Best-effort silent auto-backup.
    }
  }
}

final backupScreenProvider =
    AsyncNotifierProvider<BackupScreenNotifier, BackupScreenState>(
      BackupScreenNotifier.new,
    );
