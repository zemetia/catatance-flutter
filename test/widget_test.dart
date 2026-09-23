import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pencatatan_keuangan/app.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';
import 'package:pencatatan_keuangan/core/widgets/floating_nav_bar/floating_nav_bar.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('App boots to the dashboard shell', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());

    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const App(),
        ),
      );
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    });

    expect(find.text('Beranda'), findsWidgets);
    expect(find.byType(FloatingNavBar), findsOneWidget);

    await tester.runAsync(() async {
      await db.close();
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
  });
}
