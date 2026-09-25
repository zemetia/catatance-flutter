import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/services/backup_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Must run before `AppDatabase` is ever opened (its provider is only
  // constructed lazily on first read) — restores the most recent on-device
  // backup into place if this looks like a fresh install with no database
  // file yet, so the app doesn't start empty/demo-seeded when a backup is
  // available.
  await const BackupService().autoRestoreIfNeeded();

  runApp(const ProviderScope(child: App()));
}
