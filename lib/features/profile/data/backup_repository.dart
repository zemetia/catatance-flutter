import '../../../core/database/app_database.dart' as db;
import '../../../core/services/backup_service.dart';

/// Wraps [BackupService] with the live [db.AppDatabase] — widgets/providers
/// never call `BackupService`/`AppDatabase` directly, only through here
/// (same reasoning as `DataManagementRepository`).
class BackupRepository {
  BackupRepository(this._db, this._service);

  final db.AppDatabase _db;
  final BackupService _service;

  Future<String> backupDirectoryPath() async => (await _service.backupDirectory()).path;

  Future<List<BackupFile>> listBackups() => _service.listBackups();

  Future<BackupFile> createBackup() => _service.createBackup(_db);

  Future<void> restoreBackup(BackupFile backup) => _service.restoreBackup(backup);

  Future<void> deleteBackup(BackupFile backup) => _service.deleteBackup(backup);

  /// Closes the live connection so [restoreBackup] can safely overwrite the
  /// database file on disk — caller must invalidate `appDatabaseProvider`
  /// afterwards to open a fresh connection against the restored file.
  Future<void> closeDatabaseForRestore() => _db.close();
}
