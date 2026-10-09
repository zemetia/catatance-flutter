import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' as db;
import '../domain/wishlist_item.dart';

class WishlistDraft {
  const WishlistDraft({
    required this.name,
    required this.estimatedPriceCents,
    this.reason,
    this.url,
    this.coolingDays = 30,
    this.priority = 'medium',
    this.categoryName,
    this.iconKey = 'shopping-bag',
  });

  final String name;
  final int estimatedPriceCents;
  final String? reason;
  final String? url;
  final int coolingDays;
  final String priority;
  final String? categoryName;
  final String iconKey;
}

class WishlistRepository {
  WishlistRepository(this._db);

  final db.AppDatabase _db;

  /// Watches all wishlist items ordered by status priority, then creation date.
  Stream<List<WishlistItem>> watchAll() {
    return (_db.select(_db.wishlistItems)
          ..orderBy([
            (w) => OrderingTerm.desc(w.createdAt),
          ]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  /// Watches overall summary statistics for wishlist items.
  Stream<WishlistSummary> watchSummary() {
    return watchAll().map((items) {
      var totalSavedCents = 0;
      var coolingCount = 0;
      var readyCount = 0;

      for (final item in items) {
        if (item.isCancelled) {
          totalSavedCents += item.savedAmountCents > 0
              ? item.savedAmountCents
              : item.estimatedPriceCents;
        } else if (item.isReady) {
          readyCount++;
        } else if (item.isCoolingOff) {
          coolingCount++;
        }
      }

      return WishlistSummary(
        totalSavedCents: totalSavedCents,
        coolingCount: coolingCount,
        readyCount: readyCount,
        totalCount: items.length,
      );
    });
  }

  /// Gets all items once.
  Future<List<WishlistItem>> getAll() async {
    final rows = await (_db.select(_db.wishlistItems)
          ..orderBy([
            (w) => OrderingTerm.desc(w.createdAt),
          ]))
        .get();
    return rows.map(_toDomain).toList();
  }

  /// Watches a single item by its [id].
  Stream<WishlistItem?> watchItem(int id) {
    return (_db.select(_db.wishlistItems)..where((w) => w.id.equals(id)))
        .watchSingleOrNull()
        .map((row) => row != null ? _toDomain(row) : null);
  }

  /// Gets a single item by its [id] once.
  Future<WishlistItem?> getItem(int id) async {
    final row = await (_db.select(_db.wishlistItems)..where((w) => w.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  /// Inserts a new wishlist item with cooling-off period countdown.
  Future<int> insert(WishlistDraft draft) {
    if (draft.name.trim().isEmpty) {
      throw ArgumentError('Nama barang tidak boleh kosong');
    }
    if (draft.estimatedPriceCents <= 0) {
      throw ArgumentError('Estimasi harga harus lebih dari Rp 0');
    }

    final now = DateTime.now();
    final cooling = draft.coolingDays > 0 ? draft.coolingDays : 30;
    final readyAt = now.add(Duration(days: cooling));

    return _db.into(_db.wishlistItems).insert(
          db.WishlistItemsCompanion.insert(
            name: draft.name.trim(),
            estimatedPriceCents: draft.estimatedPriceCents,
            reason: Value(draft.reason?.trim()),
            url: Value(draft.url?.trim()),
            coolingDays: Value(cooling),
            createdAt: Value(now),
            readyAt: readyAt,
            status: const Value('cooling_off'),
            priority: Value(draft.priority),
            categoryName: Value(draft.categoryName?.trim()),
            iconKey: Value(draft.iconKey),
            savedAmountCents: const Value(0),
          ),
        );
  }

  /// Updates an existing item while preserving its original creation date if unchanged.
  Future<bool> update(int id, WishlistDraft draft) async {
    final existing = await getItem(id);
    if (existing == null) return false;

    // Recalculate readyAt if coolingDays changed
    DateTime newReadyAt = existing.readyAt;
    if (existing.coolingDays != draft.coolingDays) {
      newReadyAt = existing.createdAt.add(Duration(days: draft.coolingDays));
    }

    return _db.update(_db.wishlistItems).replace(
          db.WishlistItem(
            id: id,
            name: draft.name.trim(),
            estimatedPriceCents: draft.estimatedPriceCents,
            reason: draft.reason?.trim(),
            url: draft.url?.trim(),
            coolingDays: draft.coolingDays,
            createdAt: existing.createdAt,
            readyAt: newReadyAt,
            status: existing.status,
            decisionDate: existing.decisionDate,
            decisionNote: existing.decisionNote,
            priority: draft.priority,
            categoryName: draft.categoryName?.trim(),
            iconKey: draft.iconKey,
            savedAmountCents: existing.savedAmountCents,
          ),
        );
  }

  /// Evaluates and cancels the impulse item: marks as saved!
  Future<bool> cancelAndSave(int id, {String? reason}) async {
    final item = await getItem(id);
    if (item == null) return false;

    final updated = await (_db.update(_db.wishlistItems)..where((w) => w.id.equals(id))).write(
      db.WishlistItemsCompanion(
        status: const Value('cancelled'),
        decisionDate: Value(DateTime.now()),
        decisionNote: Value(reason ?? 'Membatalkan keinginan & menghemat uang'),
        savedAmountCents: Value(item.estimatedPriceCents),
      ),
    );
    return updated > 0;
  }

  /// Marks item as purchased.
  Future<bool> markPurchased(int id, {String? note}) async {
    final updated = await (_db.update(_db.wishlistItems)..where((w) => w.id.equals(id))).write(
      db.WishlistItemsCompanion(
        status: const Value('purchased'),
        decisionDate: Value(DateTime.now()),
        decisionNote: Value(note ?? 'Dibeli setelah evaluasi matang'),
      ),
    );
    return updated > 0;
  }

  /// Marks item as converted to savings goal.
  Future<bool> markConverted(int id, {String? note}) async {
    final updated = await (_db.update(_db.wishlistItems)..where((w) => w.id.equals(id))).write(
      db.WishlistItemsCompanion(
        status: const Value('converted'),
        decisionDate: Value(DateTime.now()),
        decisionNote: Value(note ?? 'Dialihkan menjadi Target Tabungan'),
      ),
    );
    return updated > 0;
  }

  /// Extends the cooling-off duration by [additionalDays] if the user is still unsure.
  Future<bool> extendCoolingPeriod(int id, int additionalDays) async {
    final item = await getItem(id);
    if (item == null) return false;

    final newReadyAt = item.readyAt.add(Duration(days: additionalDays));
    final newCoolingDays = item.coolingDays + additionalDays;

    final updated = await (_db.update(_db.wishlistItems)..where((w) => w.id.equals(id))).write(
      db.WishlistItemsCompanion(
        coolingDays: Value(newCoolingDays),
        readyAt: Value(newReadyAt),
        status: const Value('cooling_off'),
      ),
    );
    return updated > 0;
  }

  /// Deletes an item from the wishlist.
  Future<int> delete(int id) {
    return (_db.delete(_db.wishlistItems)..where((w) => w.id.equals(id))).go();
  }

  WishlistItem _toDomain(db.WishlistItem row) => WishlistItem(
        id: row.id,
        name: row.name,
        estimatedPriceCents: row.estimatedPriceCents,
        reason: row.reason,
        url: row.url,
        coolingDays: row.coolingDays,
        createdAt: row.createdAt,
        readyAt: row.readyAt,
        status: row.status,
        decisionDate: row.decisionDate,
        decisionNote: row.decisionNote,
        priority: row.priority,
        categoryName: row.categoryName,
        iconKey: row.iconKey,
        savedAmountCents: row.savedAmountCents,
      );
}
