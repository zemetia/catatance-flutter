import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/features/bank_notifications/presentation/widgets/category_picker_sheet.dart'
    as bank_picker;
import 'package:pencatatan_keuangan/features/budget/presentation/widgets/budget_category_picker_sheet.dart'
    as budget_picker;
import 'package:pencatatan_keuangan/features/categories/domain/category_item.dart';
import 'package:pencatatan_keuangan/features/installments/presentation/widgets/category_picker_sheet.dart'
    as installment_picker;
import 'package:pencatatan_keuangan/features/transactions/presentation/widgets/category_picker_sheet.dart';

void main() {
  final sampleCategories = List.generate(
    15,
    (index) => CategoryItem(
      id: index + 1,
      name: 'Kategori ${index + 1}',
      icon: 'utensils',
      type: 'expense',
      colorValue: 0xFF4CAF50,
      usageCount: index * 2,
    ),
  );

  void setupViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 750);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
    });
  }

  testWidgets('Transaction category picker sheet does not overflow when keyboard appears',
      (tester) async {
    setupViewport(tester);

    CategoryItem? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                selected = await showCategoryPickerSheet(
                  context,
                  categories: sampleCategories,
                  selected: null,
                  isExpense: true,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Kategori'), findsOneWidget);

    // Simulate keyboard opening (e.g. 300px keyboard)
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    // Verify no overflow errors occurred
    expect(tester.takeException(), isNull);

    // Type in search field while keyboard is open
    await tester.enterText(find.byType(TextField), 'Kategori 2');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.widgetWithText(InkWell, 'Kategori 2'), findsOneWidget);

    // Tap category item
    await tester.tap(find.widgetWithText(InkWell, 'Kategori 2'));
    await tester.pumpAndSettle();

    expect(selected?.name, 'Kategori 2');
  });

  testWidgets('Transaction category picker empty search state does not overflow with keyboard',
      (tester) async {
    setupViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCategoryPickerSheet(
                  context,
                  categories: sampleCategories,
                  selected: null,
                  isExpense: true,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'TidakAdaKategoriXYZ');
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada kategori yang cocok'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bank notifications category picker does not overflow with keyboard',
      (tester) async {
    setupViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                bank_picker.showCategoryPickerSheet(
                  context,
                  categories: sampleCategories,
                  selected: null,
                  isExpense: true,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Budget category picker does not overflow with keyboard',
      (tester) async {
    setupViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                budget_picker.showBudgetCategoryPickerSheet(
                  context,
                  categories: sampleCategories,
                  selected: null,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Installment category picker does not overflow with keyboard',
      (tester) async {
    setupViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                installment_picker.showInstallmentCategoryPickerSheet(
                  context,
                  categories: sampleCategories,
                  selected: null,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
