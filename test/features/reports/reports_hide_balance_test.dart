import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/security/security_providers.dart';
import 'package:pencatatan_keuangan/features/reports/domain/report_models.dart';
import 'package:pencatatan_keuangan/features/reports/presentation/reports_providers.dart';
import 'package:pencatatan_keuangan/features/reports/presentation/widgets/category_donut_card.dart';
import 'package:pencatatan_keuangan/features/reports/presentation/widgets/expense_bar_chart_card.dart';
import 'package:pencatatan_keuangan/features/reports/presentation/widgets/net_worth_card.dart';
import 'package:pencatatan_keuangan/features/reports/presentation/widgets/top_categories_card.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  final sampleCategories = [
    const CategorySpending(
      categoryId: 1,
      name: 'Makanan',
      icon: 'utensils',
      colorValue: 0xFFFF5722,
      totalCents: 350000,
      share: 0.7,
      count: 3,
    ),
  ];

  Widget buildWidget({required bool hideBalance, required Widget child}) {
    return ProviderScope(
      overrides: [
        hideBalanceProvider.overrideWithValue(hideBalance),
        weeklyTotalProvider.overrideWith((ref) => Stream.value(500000)),
        dailySpendingProvider.overrideWith((ref) => Stream.value([])),
        categoryBreakdownProvider.overrideWith((ref) => Stream.value(sampleCategories)),
        netWorthProvider.overrideWith((ref) => Stream.value(10000000)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: child),
        ),
      ),
    );
  }

  group('ReportsScreen balance visibility based on hideBalance security setting', () {
    void setupViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('Numbers are visible directly when hideBalance is false', (tester) async {
      setupViewport(tester);
      await tester.pumpWidget(
        buildWidget(
          hideBalance: false,
          child: const Column(
            children: [
              ExpenseBarChartCard(),
              CategoryDonutCard(),
              NetWorthCard(),
              TopCategoriesCard(),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // ExpenseBarChartCard: shows real value, not masked
      expect(find.text('Rp500rb'), findsAtLeastNWidgets(1));
      expect(find.text('••••••'), findsNothing);

      // CategoryDonutCard: shows percentage directly and center total, not "Tahan untuk lihat total"
      expect(find.text('70%'), findsAtLeastNWidgets(1));
      expect(find.text('••%'), findsNothing);
      expect(find.text('Tahan untuk lihat total'), findsNothing);

      // NetWorthCard: shows net worth directly
      expect(find.text('Rp10jt'), findsOneWidget);
      expect(find.text('Rp ••••••••'), findsNothing);

      // TopCategoriesCard: shows amount directly
      expect(find.text('Rp350rb • 70%'), findsOneWidget);
      expect(find.text('•••••• • 70%'), findsNothing);
    });

    testWidgets('Numbers are hidden when hideBalance is true, and revealable on tap', (tester) async {
      setupViewport(tester);
      await tester.pumpWidget(
        buildWidget(
          hideBalance: true,
          child: const Column(
            children: [
              ExpenseBarChartCard(),
              CategoryDonutCard(),
              NetWorthCard(),
              TopCategoriesCard(),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // ExpenseBarChartCard: masked with ••••••
      expect(find.text('••••••'), findsOneWidget);

      // CategoryDonutCard: percentage masked with ••% and center prompt present
      expect(find.text('••%'), findsOneWidget);
      expect(find.text('Ketuk untuk lihat total'), findsOneWidget);

      // NetWorthCard: masked with Rp ••••••••
      expect(find.text('Rp ••••••••'), findsOneWidget);

      // TopCategoriesCard: amount masked with •••••• • 70%
      expect(find.text('•••••• • 70%'), findsOneWidget);

      // Tap to reveal weekly total in ExpenseBarChartCard
      await tester.tap(find.text('••••••'));
      await tester.pumpAndSettle();
      expect(find.text('Rp500rb'), findsAtLeastNWidgets(1));

      // Tap to reveal percentage in CategoryDonutCard
      await tester.tap(find.text('••%'));
      await tester.pumpAndSettle();
      expect(find.text('70%'), findsAtLeastNWidgets(1));

      // Tap to reveal net worth
      await tester.tap(find.text('Rp ••••••••'));
      await tester.pumpAndSettle();
      expect(find.text('Rp10jt'), findsOneWidget);

      // Tap to reveal top category amount
      await tester.tap(find.text('•••••• • 70%'));
      await tester.pumpAndSettle();
      expect(find.text('Rp350rb • 70%'), findsOneWidget);
    });
  });
}

