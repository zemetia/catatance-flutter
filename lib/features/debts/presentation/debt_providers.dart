import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart' hide Debt, DebtPayment;
import '../data/debt_repository.dart';
import '../domain/debt.dart';
import '../domain/debt_payment.dart';
import '../domain/debt_type.dart';

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepository(ref.watch(appDatabaseProvider));
});

/// Live stream of all debts and receivables from the database.
final debtListProvider = StreamProvider.autoDispose<List<Debt>>((ref) {
  return ref.watch(debtRepositoryProvider).watchAll();
});

/// Live stream of a single debt by its ID.
final debtDetailProvider =
    StreamProvider.autoDispose.family<Debt?, int>((ref, id) {
  return ref.watch(debtRepositoryProvider).watchDebt(id);
});

/// Live stream of payment logs for a single debt.
final debtPaymentsProvider =
    StreamProvider.autoDispose.family<List<DebtPayment>, int>((ref, debtId) {
  return ref.watch(debtRepositoryProvider).watchPaymentsForDebt(debtId);
});

/// Financial summary aggregating all active debts and receivables.
class DebtSummary {
  const DebtSummary({
    required this.totalDebtRemainingCents,
    required this.totalReceivableRemainingCents,
    required this.totalDebtInitialCents,
    required this.totalReceivableInitialCents,
    required this.activeDebtCount,
    required this.activeReceivableCount,
    required this.overdueCount,
  });

  final int totalDebtRemainingCents;
  final int totalReceivableRemainingCents;
  final int totalDebtInitialCents;
  final int totalReceivableInitialCents;
  final int activeDebtCount;
  final int activeReceivableCount;
  final int overdueCount;

  /// Net balance: receivable (positive asset) minus debt (liability).
  int get netRemainingCents =>
      totalReceivableRemainingCents - totalDebtRemainingCents;
}

final debtSummaryProvider = Provider.autoDispose<DebtSummary>((ref) {
  final debts = ref.watch(debtListProvider).value ?? const [];

  var totalDebtRem = 0;
  var totalRecRem = 0;
  var totalDebtInit = 0;
  var totalRecInit = 0;
  var activeDebts = 0;
  var activeRecs = 0;
  var overdues = 0;

  final now = DateTime.now();

  for (final d in debts) {
    if (d.type == DebtType.debt) {
      totalDebtInit += d.amountCents;
      if (!d.isSettled) {
        totalDebtRem += d.remainingCents;
        activeDebts++;
        if (d.isOverdueAt(now)) {
          overdues++;
        }
      }
    } else {
      totalRecInit += d.amountCents;
      if (!d.isSettled) {
        totalRecRem += d.remainingCents;
        activeRecs++;
        if (d.isOverdueAt(now)) {
          overdues++;
        }
      }
    }
  }

  return DebtSummary(
    totalDebtRemainingCents: totalDebtRem,
    totalReceivableRemainingCents: totalRecRem,
    totalDebtInitialCents: totalDebtInit,
    totalReceivableInitialCents: totalRecInit,
    activeDebtCount: activeDebts,
    activeReceivableCount: activeRecs,
    overdueCount: overdues,
  );
});

/// Filter criteria for the debt list.
enum DebtStatusFilter {
  all,
  unpaid,
  overdue,
  paid;

  String get label => switch (this) {
        DebtStatusFilter.all => 'Semua',
        DebtStatusFilter.unpaid => 'Belum Lunas',
        DebtStatusFilter.overdue => 'Lewat Tempo',
        DebtStatusFilter.paid => 'Lunas',
      };
}

enum DebtTypeFilter {
  all,
  debt,
  receivable;

  String get label => switch (this) {
        DebtTypeFilter.all => 'Semua',
        DebtTypeFilter.debt => 'Utang Saya',
        DebtTypeFilter.receivable => 'Piutang Saya',
      };
}

class DebtFilterState {
  const DebtFilterState({
    this.typeFilter = DebtTypeFilter.all,
    this.statusFilter = DebtStatusFilter.all,
    this.searchQuery = '',
  });

  final DebtTypeFilter typeFilter;
  final DebtStatusFilter statusFilter;
  final String searchQuery;

  DebtFilterState copyWith({
    DebtTypeFilter? typeFilter,
    DebtStatusFilter? statusFilter,
    String? searchQuery,
  }) {
    return DebtFilterState(
      typeFilter: typeFilter ?? this.typeFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DebtFilterNotifier extends Notifier<DebtFilterState> {
  @override
  DebtFilterState build() => const DebtFilterState();

  void setTypeFilter(DebtTypeFilter filter) {
    state = state.copyWith(typeFilter: filter);
  }

  void setStatusFilter(DebtStatusFilter filter) {
    state = state.copyWith(statusFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void reset() {
    state = const DebtFilterState();
  }
}

final debtFilterProvider =
    NotifierProvider.autoDispose<DebtFilterNotifier, DebtFilterState>(
  DebtFilterNotifier.new,
);

/// Filtered list of debts based on current search query, type, and status filter.
final filteredDebtsProvider = Provider.autoDispose<List<Debt>>((ref) {
  final allDebts = ref.watch(debtListProvider).value ?? const [];
  final filter = ref.watch(debtFilterProvider);
  final now = DateTime.now();

  return allDebts.where((debt) {
    // 1. Type filter
    if (filter.typeFilter == DebtTypeFilter.debt &&
        debt.type != DebtType.debt) {
      return false;
    }
    if (filter.typeFilter == DebtTypeFilter.receivable &&
        debt.type != DebtType.receivable) {
      return false;
    }

    // 2. Status filter
    if (filter.statusFilter == DebtStatusFilter.unpaid && debt.isSettled) {
      return false;
    }
    if (filter.statusFilter == DebtStatusFilter.paid && !debt.isSettled) {
      return false;
    }
    if (filter.statusFilter == DebtStatusFilter.overdue) {
      if (debt.isSettled || !debt.isOverdueAt(now)) return false;
    }

    // 3. Search query
    if (filter.searchQuery.trim().isNotEmpty) {
      final q = filter.searchQuery.trim().toLowerCase();
      final matchesName = debt.personName.toLowerCase().contains(q);
      final matchesNote = debt.note?.toLowerCase().contains(q) ?? false;
      if (!matchesName && !matchesNote) return false;
    }

    return true;
  }).toList();
});

/// Manages async actions: creating, updating, deleting, paying, and settling debts.
class DebtActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<int?> createDebt(DebtDraft draft) async {
    final repo = ref.read(debtRepositoryProvider);
    state = const AsyncLoading();
    int? result;
    state = await AsyncValue.guard(() async {
      result = await repo.insertDebt(draft);
    });
    if (state.hasError) throw state.error!;
    return result;
  }

  Future<void> updateDebt(int id, DebtDraft draft) async {
    final repo = ref.read(debtRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.updateDebt(id, draft),
    );
    if (state.hasError) throw state.error!;
  }

  Future<void> deleteDebt(int id) async {
    final repo = ref.read(debtRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.deleteDebt(id),
    );
    if (state.hasError) throw state.error!;
  }

  Future<void> recordPayment(DebtPaymentDraft draft) async {
    final repo = ref.read(debtRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.recordPayment(draft),
    );
    if (state.hasError) throw state.error!;
  }

  Future<void> deletePayment(int paymentId) async {
    final repo = ref.read(debtRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.deletePayment(paymentId),
    );
    if (state.hasError) throw state.error!;
  }

  Future<void> settleDebt(
    int debtId, {
    DateTime? paymentDate,
    String? note,
  }) async {
    final repo = ref.read(debtRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.settleDebt(
            debtId,
            paymentDate: paymentDate,
            note: note,
          ),
    );
    if (state.hasError) throw state.error!;
  }
}

final debtActionProvider =
    AsyncNotifierProvider<DebtActionNotifier, void>(
  DebtActionNotifier.new,
);
