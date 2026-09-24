import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Small file-backed flag store, sibling to `ThemeStorage` — tracks facts
/// about the database's lifecycle that don't belong in a SQL table (e.g.
/// whether a user-triggered full data reset happened, so `AppDatabase`'s
/// `beforeOpen` demo-data seeding doesn't run again on next launch).
class AppMetaStorage {
  const AppMetaStorage();

  static const _fileName = 'app_meta.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _fileName));
  }

  Future<bool> wasDataResetByUser() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return false;
      final raw = await file.readAsString();
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map['dataResetByUser'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> markDataResetByUser() async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode({'dataResetByUser': true}));
    } catch (_) {
      // Best-effort write; non-fatal if storage fails.
    }
  }
}
