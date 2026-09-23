import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart'
    hide Installment, InstallmentPayment;
import '../data/installment_repository.dart';
import '../domain/installment.dart';
import '../domain/installment_payment.dart';

final installmentRepositoryProvider = Provider<InstallmentRepository>((ref) {
  return InstallmentRepository(ref.watch(appDatabaseProvider));
});

/// Live stream of all installment plans.
final installmentListProvider =
    StreamProvider.autoDispose<List<Installment>>((ref) {
  return ref.watch(installmentRepositoryProvider).watchAll();
});

/// Live stream of a single installment plan by its ID.
final installmentDetailProvider =
    StreamProvider.autoDispose.family<Installment?, int>((ref, id) {
  return ref.watch(installmentRepositoryProvider).watchInstallment(id);
});

/// Live stream of payment history for a single installment plan.
final installmentPaymentsProvider = StreamProvider.autoDispose
    .family<List<InstallmentPayment>, int>((ref, installmentId) {
  return ref
      .watch(installmentRepositoryProvider)
      .watchPaymentsForInstallment(installmentId);
});

/// Aggregated overview across all installment plans.
class InstallmentSummary {
  const InstallmentSummary({
    required this.activeCount,
    required this.totalRemainingCents,
    required this.totalMonthlyCommitmentCents,
    required this.overdueCount,
  });

  final int activeCount;
  final int totalRemainingCents;
  final int totalMonthlyCommitmentCents;
  final int overdueCount;
}

final installmentSummaryProvider =
    Provider.autoDispose<InstallmentSummary>((ref) {
  final installments = ref.watch(installmentListProvider).value ?? const [];
  final now = DateTime.now();

  var activeCount = 0;
  var totalRemaining = 0;
  var totalMonthly = 0;
  var overdueCount = 0;

  for (final installment in installments) {
    if (installment.isCompleted) continue;
    activeCount++;
    totalRemaining += installment.remainingAmountCents;
    totalMonthly += installment.installmentAmountCents;
    if (installment.isOverdueAt(now)) overdueCount++;
  }

  return InstallmentSummary(
    activeCount: activeCount,
    totalRemainingCents: totalRemaining,
    totalMonthlyCommitmentCents: totalMonthly,
    overdueCount: overdueCount,
  );
});

/// Filter criteria for the installment list.
enum InstallmentStatusFilter {
  all,
  active,
  overdue,
  completed;

  String get label => switch (this) {
        InstallmentStatusFilter.all => 'Semua',
        InstallmentStatusFilter.active => 'Aktif',
        InstallmentStatusFilter.overdue => 'Lewat Tempo',
        InstallmentStatusFilter.completed => 'Lunas',
      };
}

class InstallmentFilterState {
  const InstallmentFilterState({
    this.statusFilter = InstallmentStatusFilter.all,
    this.searchQuery = '',
  });

  final InstallmentStatusFilter statusFilter;
  final String searchQuery;

  InstallmentFilterState copyWith({
    InstallmentStatusFilter? statusFilter,
    String? searchQuery,
  }) {
    return InstallmentFilterState(
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class InstallmentFilterNotifier extends Notifier<InstallmentFilterState> {
  @override
  InstallmentFilterState build() => const InstallmentFilterState();

  void setStatusFilter(InstallmentStatusFilter filter) {
    state = state.copyWith(statusFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final installmentFilterProvider = NotifierProvider.autoDispose<
    InstallmentFilterNotifier, InstallmentFilterState>(
  InstallmentFilterNotifier.new,
);

/// Filtered list of installment plans based on the current search/status filter.
final filteredInstallmentsProvider =
    Provider.autoDispose<List<Installment>>((ref) {
  final all = ref.watch(installmentListProvider).value ?? const [];
  final filter = ref.watch(installmentFilterProvider);
  final now = DateTime.now();

  return all.where((installment) {
    switch (filter.statusFilter) {
      case InstallmentStatusFilter.active:
        if (installment.isCompleted) return false;
      case InstallmentStatusFilter.completed:
        if (!installment.isCompleted) return false;
      case InstallmentStatusFilter.overdue:
        if (!installment.isOverdueAt(now)) return false;
      case InstallmentStatusFilter.all:
        break;
    }

    if (filter.searchQuery.trim().isNotEmpty) {
      final q = filter.searchQuery.trim().toLowerCase();
      final matchesName = installment.name.toLowerCase().contains(q);
      final matchesNote = installment.note?.toLowerCase().contains(q) ?? false;
      if (!matchesName && !matchesNote) return false;
    }

    return true;
  }).toList();
});

/// Manages async actions: creating, updating, deleting, paying, and paying
/// off installment plans.
class InstallmentActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<int?> createInstallment(InstallmentDraft draft) async {
    final repo = ref.read(installmentRepositoryProvider);
    state = const AsyncLoading();
    int? result;
    state = await AsyncValue.guard(() async {
      result = await repo.insertInstallment(draft);
    });
    if (state.hasError) throw state.error!;
    return result;
  }

  Future<void> updateInstallment(int id, InstallmentDraft draft) async {
    final repo = ref.read(installmentRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.updateInstallment(id, draft));
    if (state.hasError) throw state.error!;
  }

  Future<void> deleteInstallment(int id) async {
    final repo = ref.read(installmentRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.deleteInstallment(id));
    if (state.hasError) throw state.error!;
  }

  Future<void> payInstallment(InstallmentPaymentDraft draft) async {
    final repo = ref.read(installmentRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.payInstallment(draft));
    if (state.hasError) throw state.error!;
  }

  Future<void> payoffRemaining(
    int installmentId, {
    DateTime? paymentDate,
    String? note,
  }) async {
    final repo = ref.read(installmentRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.payoffRemaining(
        installmentId,
        paymentDate: paymentDate,
        note: note,
      ),
    );
    if (state.hasError) throw state.error!;
  }

  Future<void> deletePayment(int paymentId) async {
    final repo = ref.read(installmentRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.deletePayment(paymentId));
    if (state.hasError) throw state.error!;
  }
}

final installmentActionProvider =
    AsyncNotifierProvider<InstallmentActionNotifier, void>(
  InstallmentActionNotifier.new,
);
