import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';
import 'package:pencatatan_keuangan/features/accounts/data/account_repository.dart';
import 'package:pencatatan_keuangan/features/accounts/presentation/account_providers.dart';
import 'package:pencatatan_keuangan/features/accounts/presentation/wallet_transfer_screen.dart';

void main() {
  late AppDatabase db;
  late AccountRepository repository;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = AccountRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> disposeTester(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  }

  Widget buildWidget({DateTime? initialDate}) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        accountRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        home: WalletTransferScreen(initialDate: initialDate),
      ),
    );
  }

  testWidgets('WalletTransferScreen renders Tanggal Transfer with default today', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('Tanggal Transfer'), findsOneWidget);
    expect(find.textContaining('Hari ini'), findsOneWidget);
    expect(find.text('Transfer sekarang'), findsOneWidget);

    await disposeTester(tester);
  });

  testWidgets('WalletTransferScreen displays custom initialDate and button label', (tester) async {
    final customDate = DateTime(2026, 8, 15);
    await tester.pumpWidget(buildWidget(initialDate: customDate));
    await tester.pumpAndSettle();

    expect(find.text('Tanggal Transfer'), findsOneWidget);
    expect(find.text('15 Agu 2026'), findsOneWidget);
    expect(find.text('Transfer (15 Agu)'), findsOneWidget);

    await disposeTester(tester);
  });
}
