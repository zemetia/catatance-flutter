import '../../../core/database/app_database.dart' as db;

/// Wraps the "hapus semua data" (reset) flow — widgets never call
/// `AppDatabase.resetAllData()` directly, only through this repository.
class DataManagementRepository {
  DataManagementRepository(this._db);

  final db.AppDatabase _db;

  Future<void> resetAllData() => _db.resetAllData();
}
