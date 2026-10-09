import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/category_item.dart';

class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  Stream<List<CategoryItem>> watchAll() {
    const sql = '''
      SELECT 
        c.id, 
        c.name, 
        c.icon, 
        c.type, 
        c.color_value, 
        COUNT(t.id) AS usage_count
      FROM categories c
      LEFT JOIN transactions t ON t.category_id = c.id
      GROUP BY c.id
      ORDER BY usage_count DESC, c.name COLLATE NOCASE ASC
    ''';
    return _db
        .customSelect(
          sql,
          readsFrom: {_db.categories, _db.transactions},
        )
        .watch()
        .map((rows) => rows.map(_fromQueryRow).toList());
  }

  Stream<List<CategoryItem>> watchByType(String type) {
    const sql = '''
      SELECT 
        c.id, 
        c.name, 
        c.icon, 
        c.type, 
        c.color_value, 
        COUNT(t.id) AS usage_count
      FROM categories c
      LEFT JOIN transactions t ON t.category_id = c.id
      WHERE c.type = ?
      GROUP BY c.id
      ORDER BY usage_count DESC, c.name COLLATE NOCASE ASC
    ''';
    return _db
        .customSelect(
          sql,
          variables: [Variable.withString(type)],
          readsFrom: {_db.categories, _db.transactions},
        )
        .watch()
        .map((rows) => rows.map(_fromQueryRow).toList());
  }

  Future<List<CategoryItem>> getByType(String type) async {
    const sql = '''
      SELECT 
        c.id, 
        c.name, 
        c.icon, 
        c.type, 
        c.color_value, 
        COUNT(t.id) AS usage_count
      FROM categories c
      LEFT JOIN transactions t ON t.category_id = c.id
      WHERE c.type = ?
      GROUP BY c.id
      ORDER BY usage_count DESC, c.name COLLATE NOCASE ASC
    ''';
    final rows = await _db.customSelect(
      sql,
      variables: [Variable.withString(type)],
      readsFrom: {_db.categories, _db.transactions},
    ).get();
    return rows.map(_fromQueryRow).toList();
  }

  CategoryItem _fromQueryRow(QueryRow row) => CategoryItem(
        id: row.read<int>('id'),
        name: row.read<String>('name'),
        icon: row.read<String>('icon'),
        type: row.read<String>('type'),
        colorValue: row.read<int>('color_value'),
        usageCount: row.read<int?>('usage_count') ?? 0,
      );
}
