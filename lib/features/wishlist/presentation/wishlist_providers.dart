import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart' hide WishlistItem;
import '../data/wishlist_repository.dart';
import '../domain/wishlist_item.dart';

enum WishlistFilter {
  all('Semua'),
  cooling('Masa Tunggu'),
  ready('Siap Evaluasi'),
  saved('Berhasil Hemat'),
  done('Selesai / Dibeli');

  const WishlistFilter(this.label);
  final String label;
}

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return WishlistRepository(db);
});

final wishlistListProvider = StreamProvider<List<WishlistItem>>((ref) {
  return ref.watch(wishlistRepositoryProvider).watchAll();
});

final wishlistSummaryProvider = StreamProvider<WishlistSummary>((ref) {
  return ref.watch(wishlistRepositoryProvider).watchSummary();
});

final wishlistItemProvider = StreamProvider.family<WishlistItem?, int>((ref, id) {
  return ref.watch(wishlistRepositoryProvider).watchItem(id);
});

class WishlistFilterNotifier extends Notifier<WishlistFilter> {
  @override
  WishlistFilter build() => WishlistFilter.all;

  void setFilter(WishlistFilter filter) => state = filter;
}

final wishlistFilterProvider =
    NotifierProvider<WishlistFilterNotifier, WishlistFilter>(WishlistFilterNotifier.new);

final filteredWishlistListProvider = Provider<List<WishlistItem>>((ref) {
  final items = ref.watch(wishlistListProvider).value ?? const <WishlistItem>[];
  final filter = ref.watch(wishlistFilterProvider);

  return switch (filter) {
    WishlistFilter.all => items,
    WishlistFilter.cooling => items.where((i) => i.isCoolingOff).toList(),
    WishlistFilter.ready => items.where((i) => i.isReady).toList(),
    WishlistFilter.saved => items.where((i) => i.isCancelled).toList(),
    WishlistFilter.done => items.where((i) => i.isPurchased || i.isConverted).toList(),
  };
});

class WishlistActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<int?> createItem(WishlistDraft draft) async {
    state = const AsyncLoading();
    try {
      final id = await ref.read(wishlistRepositoryProvider).insert(draft);
      state = const AsyncData(null);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<bool> updateItem(int id, WishlistDraft draft) async {
    state = const AsyncLoading();
    try {
      final success = await ref.read(wishlistRepositoryProvider).update(id, draft);
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<bool> cancelAndSave(int id, {String? reason}) async {
    state = const AsyncLoading();
    try {
      final success = await ref.read(wishlistRepositoryProvider).cancelAndSave(id, reason: reason);
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<bool> markPurchased(int id, {String? note}) async {
    state = const AsyncLoading();
    try {
      final success = await ref.read(wishlistRepositoryProvider).markPurchased(id, note: note);
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<bool> markConverted(int id, {String? note}) async {
    state = const AsyncLoading();
    try {
      final success = await ref.read(wishlistRepositoryProvider).markConverted(id, note: note);
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<bool> extendPeriod(int id, int days) async {
    state = const AsyncLoading();
    try {
      final success = await ref.read(wishlistRepositoryProvider).extendCoolingPeriod(id, days);
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteItem(int id) async {
    state = const AsyncLoading();
    try {
      await ref.read(wishlistRepositoryProvider).delete(id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final wishlistActionProvider =
    AsyncNotifierProvider<WishlistActionNotifier, void>(WishlistActionNotifier.new);
