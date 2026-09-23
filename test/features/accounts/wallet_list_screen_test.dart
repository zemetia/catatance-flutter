import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';
import 'package:pencatatan_keuangan/features/accounts/data/account_repository.dart';
import 'package:pencatatan_keuangan/features/accounts/domain/account.dart';
import 'package:pencatatan_keuangan/features/accounts/presentation/account_providers.dart';
import 'package:pencatatan_keuangan/features/accounts/presentation/wallet_list_screen.dart';

void main() {
  late AppDatabase db;
  late AccountRepository repository;

  setUpAll(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = AccountRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  void setupViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> disposeTester(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets(
    'WalletListScreen displays detailed money amount instead of compact reduction (e.g. 6.700.000 instead of 6,7jt)',
    (tester) async {
      setupViewport(tester);

      // Insert an account with exactly 6,700,000 as mentioned in the requirement
      await repository.insert(
        const AccountDraft(
          name: 'Tabungan Contoh',
          type: AccountType.bank,
          currencyCode: 'IDR',
          colorValue: 0xFF4CAF50,
          initialBalanceCents: 6700000,
          isDefault: false,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            accountRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: WalletListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ensure that 6,700,000 is rendered in detail (Rp 6.700.000) and NOT reduced to Rp6,7jt
      expect(find.text('Rp 6.700.000'), findsOneWidget);
      expect(find.textContaining('6,7jt'), findsNothing);

      // Verify that total balance is also displayed in full detail without compact reduction
      // Seeded accounts: 12.500.000 + 5.200.000 + 750.000 + 850.000 + 6.700.000 = 26.000.000
      expect(find.text('Rp 26.000.000'), findsOneWidget);
      expect(find.textContaining('26jt'), findsNothing);

      // Also verify seeded accounts are rendered with detailed amounts
      expect(find.text('Rp 12.500.000'), findsOneWidget);
      expect(find.textContaining('12,5jt'), findsNothing);
      expect(find.text('Rp 5.200.000'), findsOneWidget);
      expect(find.textContaining('5,2jt'), findsNothing);

      await disposeTester(tester);
    },
  );

  testWidgets(
    'WalletListScreen renders correctly on narrow viewport with large balance without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.insert(
        const AccountDraft(
          name: 'Rekening Tabungan Utama Sangat Panjang Sekali',
          type: AccountType.bank,
          currencyCode: 'IDR',
          colorValue: 0xFF4CAF50,
          initialBalanceCents: 9876543210,
          isDefault: true,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            accountRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: WalletListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify top total saldo card renders full detailed balance without compact reduction
      expect(find.text('Rp 9.895.843.210'), findsOneWidget);

      // Scroll to find the large balance account card in the list
      await tester.scrollUntilVisible(
        find.text('Rp 9.876.543.210'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Rp 9.876.543.210'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await disposeTester(tester);
    },
  );
}

