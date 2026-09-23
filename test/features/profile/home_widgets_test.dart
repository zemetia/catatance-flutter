import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';
import 'package:pencatatan_keuangan/core/services/home_widget_service.dart';
import 'package:pencatatan_keuangan/features/profile/presentation/home_widgets_providers.dart';
import 'package:pencatatan_keuangan/features/profile/presentation/home_widgets_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('HomeWidgetSettings', () {
    test('Default settings are correct', () {
      const settings = HomeWidgetSettings();
      expect(settings.hideBalanceByDefault, isFalse);
      expect(settings.showActiveWalletsCount, isTrue);
      expect(settings.cardStyle, WidgetCardStyle.darkFintech);
    });

    test('copyWith updates fields properly', () {
      const settings = HomeWidgetSettings();
      final updated = settings.copyWith(
        hideBalanceByDefault: true,
        showActiveWalletsCount: false,
        cardStyle: WidgetCardStyle.minimalist,
      );
      expect(updated.hideBalanceByDefault, isTrue);
      expect(updated.showActiveWalletsCount, isFalse);
      expect(updated.cardStyle, WidgetCardStyle.minimalist);
    });
  });

  group('HomeWidgetService', () {
    test('updateWidgetData handles platform exceptions gracefully', () async {
      final service = HomeWidgetService();
      // On desktop / test environment without native channel, it safely returns false
      final result = await service.updateWidgetData(
        balanceCents: 5000000,
        formattedBalance: 'Rp 5.000.000',
      );
      expect(result, isFalse);
    });

    test('requestPinWidget handles platform exceptions gracefully', () async {
      final service = HomeWidgetService();
      final result = await service.requestPinWidget();
      expect(result, isFalse);
    });

    test('getInitialRoute returns null when no pending route', () async {
      final service = HomeWidgetService();
      final result = await service.getInitialRoute();
      expect(result, isNull);
    });
  });

  group('HomeWidgetsScreen Widget Test', () {
    testWidgets('Renders header, primary implemented widget, settings, and upcoming designs',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = AppDatabase(NativeDatabase.memory());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: HomeWidgetsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify app bar title
      expect(find.text('Widget Layar Utama'), findsOneWidget);

      // Verify implemented widget headline
      expect(find.text('Total Saldo & Akses Cepat (+)'), findsOneWidget);
      expect(find.text('SIAP PAKAI'), findsOneWidget);
      expect(find.text('TOTAL SALDO'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Pasang ke Layar'), findsOneWidget);
      expect(find.text('Tes (+)'), findsOneWidget);

      // Verify customization card
      expect(find.text('Pengaturan Widget'), findsOneWidget);
      expect(find.text('Sembunyikan Saldo secara Default'), findsOneWidget);

      // Verify upcoming widget designs showcase
      await tester.scrollUntilVisible(find.text('Varian Desain Widget'), 300);
      expect(find.text('Varian Desain Widget'), findsOneWidget);
      expect(find.text('Pintasan Cepat Transaksi'), findsOneWidget);
      expect(find.text('Monitoring Anggaran Bulanan'), findsOneWidget);
      expect(find.text('Pengeluaran Hari Ini & Terkini'), findsOneWidget);
      expect(find.text('Saldo Minimalis Ringkas'), findsOneWidget);

      await db.close();
    });
  });
}
