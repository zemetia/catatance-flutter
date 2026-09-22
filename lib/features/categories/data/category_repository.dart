import '../../../core/database/app_database.dart';
import '../domain/category_item.dart';

class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  Stream<List<CategoryItem>> watchAll() {
    return _db.select(_db.categories).watch().map(
          (rows) => rows.map(_toDomain).toList(),
        );
  }

  Stream<List<CategoryItem>> watchByType(String type) {
    return (_db.select(_db.categories)..where((c) => c.type.equals(type)))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  Future<List<CategoryItem>> getByType(String type) async {
    final rows = await (_db.select(_db.categories)
          ..where((c) => c.type.equals(type)))
        .get();
    return rows.map(_toDomain).toList();
  }

  CategoryItem _toDomain(Category row) => CategoryItem(
        id: row.id,
        name: row.name,
        icon: row.icon,
        type: row.type,
        colorValue: row.colorValue,
      );
}
