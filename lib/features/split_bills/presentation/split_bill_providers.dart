import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart' hide SplitBill;
import '../data/split_bill_repository.dart';
import '../domain/split_bill.dart';

final splitBillRepositoryProvider = Provider<SplitBillRepository>((ref) {
  return SplitBillRepository(ref.watch(appDatabaseProvider));
});

/// Live stream of all patungan (split bill) events.
final splitBillListProvider =
    StreamProvider.autoDispose<List<SplitBill>>((ref) {
  return ref.watch(splitBillRepositoryProvider).watchAll();
});

/// Manages async actions: creating and deleting split bill events.
class SplitBillActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<int?> createSplitBill(SplitBillDraft draft) async {
    final repo = ref.read(splitBillRepositoryProvider);
    state = const AsyncLoading();
    int? result;
    state = await AsyncValue.guard(() async {
      result = await repo.createSplitBill(draft);
    });
    if (state.hasError) throw state.error!;
    return result;
  }

  Future<void> deleteSplitBill(int id) async {
    final repo = ref.read(splitBillRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.deleteSplitBill(id));
    if (state.hasError) throw state.error!;
  }
}

final splitBillActionProvider =
    AsyncNotifierProvider<SplitBillActionNotifier, void>(
  SplitBillActionNotifier.new,
);
