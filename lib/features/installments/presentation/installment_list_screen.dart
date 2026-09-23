import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../accounts/presentation/account_providers.dart';
import '../domain/installment.dart';
import 'installment_providers.dart';
import 'widgets/installment_card.dart';
import 'widgets/installment_payment_bottom_sheet.dart';
import 'widgets/installment_summary_header.dart';

class InstallmentListScreen extends HookConsumerWidget {
  const InstallmentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final installmentsAsync = ref.watch(installmentListProvider);
    final summary = ref.watch(installmentSummaryProvider);
    final filtered = ref.watch(filteredInstallmentsProvider);
    final filterState = ref.watch(installmentFilterProvider);
    final filterNotifier = ref.read(installmentFilterProvider.notifier);
    final accounts = ref.watch(accountListProvider).value ?? const [];
    final accountMap = {for (final a in accounts) a.id: a.name};

    final searchController = useTextEditingController(
      text: filterState.searchQuery,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                      'Cicilan',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  CircleIconButton(
                    icon: LucideIcons.plus,
                    backgroundColor: scheme.surfaceContainerHigh,
                    onTap: () => context.push('/installments/new'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                children: [
                  InstallmentSummaryHeader(summary: summary),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: searchController,
                    onChanged: (val) => filterNotifier.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Cari nama cicilan atau catatan...',
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: InstallmentStatusFilter.values.map((status) {
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
                  installmentsAsync.when(
                    data: (_) {
                      if (filtered.isEmpty) {
                        return const EmptyStateCard(
                          icon: LucideIcons.credit_card,
                          title: 'Belum ada cicilan',
                          description:
                              'Tidak ditemukan cicilan yang cocok. Tekan tombol + di atas untuk menambah baru.',
                        );
                      }

                      return Column(
                        children: [
                          for (var i = 0; i < filtered.length; i++) ...[
                            if (i > 0) const SizedBox(height: AppSpacing.sm),
                            InstallmentCard(
                              installment: filtered[i],
                              accountName: filtered[i].accountId != null
                                  ? accountMap[filtered[i].accountId]
                                  : null,
                              onTap: () => context
                                  .push('/installments/${filtered[i].id}'),
                              onPaymentTap: () =>
                                  InstallmentPaymentBottomSheet.show(
                                context,
                                filtered[i],
                              ),
                              onDeleteTap: () => _confirmDelete(
                                context,
                                ref,
                                filtered[i],
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
                        child: Text('Gagal memuat cicilan: $err'),
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
        onPressed: () => context.push('/installments/new'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        icon: const Icon(LucideIcons.plus),
        label: const Text(
          'Tambah Cicilan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Installment installment,
  ) async {
    final notifier = ref.read(installmentActionProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Cicilan?'),
        content: Text(
          'Yakin ingin menghapus "${installment.name}" beserta riwayat pembayarannya? Transaksi yang sudah tercatat sebelumnya tidak akan dihapus.',
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

    if (confirmed == true) {
      try {
        await notifier.deleteInstallment(installment.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cicilan berhasil dihapus')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus cicilan: $e')),
          );
        }
      }
    }
  }
}
