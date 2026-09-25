import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';

/// One backup snapshot on disk.
class BackupFile {
  const BackupFile({
    required this.file,
    required this.createdAt,
    required this.sizeBytes,
  });

  final File file;
  final DateTime createdAt;
  final int sizeBytes;

  String get fileName => p.basename(file.path);
}

/// Copies the local SQLite database to/from a `Catatance/Backup` folder on
/// device storage, so a user can manually back up their data and restore it
/// later (e.g. after reinstalling the app) — no backend/cloud involved,
/// consistent with this app's local-first design (see DATABASE.md).
class BackupService {
  const BackupService();

  static const _backupFolderPath = 'Catatance/Backup';
  static const _maxBackupsKept = 15;
  static const _filePrefix = 'catatance_backup_';

  /// Folder backups are written to/read from. Prefers the device's
  /// app-specific external storage (no runtime permission needed, browsable
  /// via a file manager under `Android/data/<applicationId>/files/Catatance`)
  /// and falls back to the app's documents directory on platforms without
  /// one (iOS, desktop).
  Future<Directory> backupDirectory() async {
    Directory? root;
    try {
      root = await getExternalStorageDirectory();
    } catch (_) {
      root = null;
    }
    root ??= await getApplicationDocumentsDirectory();

    final dir = Directory(p.join(root.path, _backupFolderPath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _liveDatabaseFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, '${AppDatabase.fileBaseName}.sqlite'));
  }

  /// Checkpoints the WAL into the main database file — so the copy below is
  /// a self-contained snapshot, no separate `-wal`/`-shm` sidecars needed to
  /// restore it later — then copies it into the backup folder with a
  /// timestamped name.
  Future<BackupFile> createBackup(AppDatabase db) async {
    await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');

    final source = await _liveDatabaseFile();
    if (!await source.exists()) {
      throw StateError('Belum ada data untuk dicadangkan.');
    }

    final dir = await backupDirectory();
    final target = File(
      p.join(dir.path, '$_filePrefix${_timestamp(DateTime.now())}.sqlite'),
    );
    await source.copy(target.path);
    await _pruneOldBackups();

    final stat = await target.stat();
    return BackupFile(file: target, createdAt: stat.modified, sizeBytes: stat.size);
  }

  Future<List<BackupFile>> listBackups() async {
    final dir = await backupDirectory();
    if (!await dir.exists()) return const [];

    final entities = await dir.list().toList();
    final files = entities.whereType<File>().where(
      (f) => p.basename(f.path).startsWith(_filePrefix) && f.path.endsWith('.sqlite'),
    );

    final entries = <BackupFile>[];
    for (final file in files) {
      final stat = await file.stat();
      entries.add(BackupFile(file: file, createdAt: stat.modified, sizeBytes: stat.size));
    }
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  /// Overwrites the live database file with [backup]'s contents. Caller must
  /// close the active `AppDatabase` connection first and invalidate
  /// `appDatabaseProvider` afterwards so a fresh connection opens against the
  /// restored file.
  Future<void> restoreBackup(BackupFile backup) async {
    final target = await _liveDatabaseFile();
    if (!await target.parent.exists()) {
      await target.parent.create(recursive: true);
    }
    await backup.file.copy(target.path);

    // Drop stale WAL/SHM sidecars from the previous session — the restored
    // file is already a checkpointed, self-contained snapshot.
    for (final suffix in ['-wal', '-shm']) {
      final sidecar = File('${target.path}$suffix');
      if (await sidecar.exists()) await sidecar.delete();
    }
  }

  Future<void> deleteBackup(BackupFile backup) async {
    if (await backup.file.exists()) await backup.file.delete();
  }

  /// Runs once before `AppDatabase` is ever opened (called from `main()`).
  /// If this is a fresh install (no live database file yet) but a backup
  /// already exists on disk, restores the most recent one automatically
  /// instead of starting from an empty/demo-seeded database.
  Future<void> autoRestoreIfNeeded() async {
    final liveFile = await _liveDatabaseFile();
    if (await liveFile.exists()) return;

    final backups = await listBackups();
    if (backups.isEmpty) return;

    try {
      await restoreBackup(backups.first);
    } catch (_) {
      // Best-effort — on failure the app just falls back to a fresh/
      // demo-seeded database as usual.
    }
  }

  Future<void> _pruneOldBackups() async {
    final backups = await listBackups();
    if (backups.length <= _maxBackupsKept) return;
    for (final old in backups.skip(_maxBackupsKept)) {
      await deleteBackup(old);
    }
  }

  String _timestamp(DateTime time) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${time.year}${two(time.month)}${two(time.day)}_'
        '${two(time.hour)}${two(time.minute)}${two(time.second)}';
  }
}
