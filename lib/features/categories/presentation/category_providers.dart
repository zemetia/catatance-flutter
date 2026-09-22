import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/category_repository.dart';
import '../domain/category_item.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CategoryRepository(db);
});

final allCategoriesProvider =
    StreamProvider.autoDispose<List<CategoryItem>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

final expenseCategoriesProvider =
    StreamProvider.autoDispose<List<CategoryItem>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchByType('expense');
});

final incomeCategoriesProvider =
    StreamProvider.autoDispose<List<CategoryItem>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchByType('income');
});
