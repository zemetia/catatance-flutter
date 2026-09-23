import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../accounts/presentation/account_providers.dart';
import '../domain/debt.dart';
import 'debt_providers.dart';
import 'widgets/debt_card.dart';
import 'widgets/debt_summary_header.dart';
import 'widgets/payment_bottom_sheet.dart';

class DebtListScreen extends HookConsumerWidget {
  const DebtListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final debtsAsync = ref.watch(debtListProvider);
    final summary = ref.watch(debtSummaryProvider);
    final filteredDebts = ref.watch(filteredDebtsProvider);
    final filterState = ref.watch(debtFilterProvider);
    final filterNotifier = ref.read(debtFilterProvider.notifier);
    final accounts = ref.watch(accountListProvider).value ?? const [];
    final accountMap = {for (final a in accounts) a.id: a.name};

    final searchController = useTextEditingController(
      text: filterState.searchQuery,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: LucideIcons.chevron_left,
                    backgroundColor: scheme.surfaceContainerHigh,
                    onTap: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Utang & Piutang',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  CircleIconButton(
                    icon: LucideIcons.plus,
                    backgroundColor: scheme.surfaceContainerHigh,
                    onTap: () => context.push('/debts/new'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  104,
                ),
                children: [
                  // Financial Overview Card
                  DebtSummaryHeader(summary: summary),
                  const SizedBox(height: AppSpacing.md),

                  // Search Box
                  TextField(
                    controller: searchController,
                    onChanged: (val) => filterNotifier.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau catatan...',
                      prefixIcon: const Icon(LucideIcons.search, size: 20),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x, size: 18),
                              onPressed: () {
                                searchController.clear();
                                filterNotifier.setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: scheme.surfaceContainerHigh,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Segmented Type Tabs: Semua / Utang Saya / Piutang Saya
                  _TypeTabs(
                    selectedType: filterState.typeFilter,
                    onChanged: (type) => filterNotifier.setTypeFilter(type),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Horizontal Status Filter Chips: Semua / Belum Lunas / Lewat Tempo / Lunas
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: DebtStatusFilter.values.map((status) {
                        final isSelected = filterState.statusFilter == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status.label),
                            selected: isSelected,
                            onSelected: (_) =>
                                filterNotifier.setStatusFilter(status),
                            showCheckmark: false,
                            labelStyle: textTheme.labelMedium?.copyWith(
                              color: isSelected
                                  ? scheme.onPrimary
                                  : scheme.onSurfaceVariant,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            backgroundColor: scheme.surfaceContainerHigh,
                            selectedColor: scheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide.none,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Items list / state
                  debtsAsync.when(
                    data: (_) {
                      if (filteredDebts.isEmpty) {
                        return const EmptyStateCard(
                          icon: LucideIcons.hand_coins,
                          title: 'Tidak ada catatan',
                          description:
                              'Tidak ditemukan catatan utang atau piutang yang cocok. Tekan tombol + di atas untuk menambah baru.',
                        );
                      }

                      return Column(
                        children: [
                          for (var i = 0; i < filteredDebts.length; i++) ...[
                            if (i > 0) const SizedBox(height: AppSpacing.sm),
                            DebtCard(
                              debt: filteredDebts[i],
                              accountName: filteredDebts[i].accountId != null
                                  ? accountMap[filteredDebts[i].accountId]
                                  : null,
                              onTap: () => context
                                  .push('/debts/${filteredDebts[i].id}'),
                              onPaymentTap: () => PaymentBottomSheet.show(
                                context,
                                filteredDebts[i],
                              ),
                              onDeleteTap: () => _confirmDelete(
                                context,
                                ref,
                                filteredDebts[i],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text('Gagal memuat catatan: $err'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/debts/new'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        icon: const Icon(LucideIcons.plus),
        label: const Text(
          'Catat Transaksi',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Debt debt,
  ) async {
    final notifier = ref.read(debtActionProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text(
          'Yakin ingin menghapus catatan untuk "${debt.personName}" beserta riwayat pembayarannya?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await notifier.deleteDebt(debt.id);
        messenger.showSnackBar(
          const SnackBar(content: Text('Catatan berhasil dihapus')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Gagal menghapus catatan: $e')),
        );
      }
    }
  }
}

class _TypeTabs extends StatelessWidget {
  const _TypeTabs({
    required this.selectedType,
    required this.onChanged,
  });

  final DebtTypeFilter selectedType;
  final ValueChanged<DebtTypeFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: DebtTypeFilter.values.map((type) {
          final isSelected = selectedType == type;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(type),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? scheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    type.label,
                    textAlign: TextAlign.center,
                    style: textTheme.labelMedium?.copyWith(
                      color:
                          isSelected ? scheme.onSurface : scheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
