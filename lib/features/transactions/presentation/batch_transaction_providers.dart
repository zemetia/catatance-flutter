import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'transaction_providers.dart';

/// One not-yet-saved transaction row staged inside the Batch Transaction
/// screen. Purely ephemeral presentation state — never persisted itself,
/// it only carries the arguments [TransactionRepository.insert] needs once
/// the whole batch is processed. Meant to be built by hand today, and by
/// an AI parser or voice-input pipeline later (hence a flat, easy-to-fill
/// shape rather than a richer domain entity).
class BatchTransactionDraft {
  BatchTransactionDraft({
    required this.localId,
    required this.isExpense,
    required this.amountCents,
    required this.accountId,
    required this.accountName,
    this.accountCurrencyCode = 'IDR',
    required this.categoryId,
    required this.categoryName,
    this.note,
    required this.date,
    this.savingsGoalId,
    this.savingsGoalName,
  });

  /// Stable client-side identity (list position can shift on edit/delete).
  final int localId;
  final bool isExpense;
  final int amountCents;
  final int accountId;
  final String accountName;
  final String accountCurrencyCode;
  final int categoryId;
  final String categoryName;
  final String? note;
  final DateTime date;
  final int? savingsGoalId;
  final String? savingsGoalName;

  BatchTransactionDraft copyWith({
    bool? isExpense,
    int? amountCents,
    int? accountId,
    String? accountName,
    String? accountCurrencyCode,
    int? categoryId,
    String? categoryName,
    String? note,
    DateTime? date,
    int? savingsGoalId,
    String? savingsGoalName,
    bool clearSavingsGoal = false,
  }) {
    return BatchTransactionDraft(
      localId: localId,
      isExpense: isExpense ?? this.isExpense,
      amountCents: amountCents ?? this.amountCents,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      accountCurrencyCode: accountCurrencyCode ?? this.accountCurrencyCode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      note: note ?? this.note,
      date: date ?? this.date,
      savingsGoalId: clearSavingsGoal ? null : (savingsGoalId ?? this.savingsGoalId),
      savingsGoalName:
          clearSavingsGoal ? null : (savingsGoalName ?? this.savingsGoalName),
    );
  }
}

class BatchDraftListNotifier extends Notifier<List<BatchTransactionDraft>> {
  int _nextLocalId = 0;

  @override
  List<BatchTransactionDraft> build() => const [];

  int nextLocalId() => _nextLocalId++;

  void add(BatchTransactionDraft draft) {
    state = [...state, draft];
  }

  void update(int localId, BatchTransactionDraft draft) {
    state = [
      for (final d in state) if (d.localId == localId) draft else d,
    ];
  }

  void remove(int localId) {
    state = state.where((d) => d.localId != localId).toList();
  }

  void clear() {
    state = const [];
  }
}

final batchDraftListProvider =
    NotifierProvider.autoDispose<BatchDraftListNotifier, List<BatchTransactionDraft>>(
  BatchDraftListNotifier.new,
);

/// Total signed amount across all staged drafts (income positive, expense
/// negative) — a quick "net effect" preview for the batch screen.
final batchDraftNetTotalProvider = Provider.autoDispose<int>((ref) {
  final drafts = ref.watch(batchDraftListProvider);
  return drafts.fold<int>(
    0,
    (sum, d) => sum + (d.isExpense ? -d.amountCents : d.amountCents),
  );
});

class BatchTransactionActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Inserts every staged draft as a real transaction, in order. Stops at
  /// the first failure (leaving already-inserted drafts committed, since
  /// each is its own independent transaction) and reports how many made it
  /// through — used by the screen to keep failed drafts staged for retry.
  Future<int> processAll(List<BatchTransactionDraft> drafts) async {
    state = const AsyncLoading();
    var processed = 0;
    state = await AsyncValue.guard(() async {
      final repo = ref.read(transactionRepositoryProvider);
      for (final draft in drafts) {
        await repo.insert(
          accountId: draft.accountId,
          categoryId: draft.categoryId,
          amountCents: draft.amountCents,
          note: draft.note,
          date: draft.date,
          savingsGoalId: !draft.isExpense ? draft.savingsGoalId : null,
        );
        processed++;
      }
    });
    return processed;
  }
}

final batchTransactionActionProvider =
    AsyncNotifierProvider.autoDispose<BatchTransactionActionNotifier, void>(
  BatchTransactionActionNotifier.new,
);
