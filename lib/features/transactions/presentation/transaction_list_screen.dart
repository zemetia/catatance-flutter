import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/transaction_item.dart';
import 'transaction_providers.dart';
import 'widgets/transaction_tile.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(LucideIcons.arrow_left),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: transactionsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: EmptyStateCard(
                    icon: LucideIcons.receipt,
                    title: 'Belum ada transaksi',
                    description:
                        'Catat pengeluaran atau pemasukan pertamamu sekarang.',
                  ),
                ),
              );
            }

            // Group transactions by date string
            final grouped = <String, List<TransactionItem>>{};
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final yesterday = today.subtract(const Duration(days: 1));

            for (final item in items) {
              final itemDay =
                  DateTime(item.date.year, item.date.month, item.date.day);
              String label;
              if (itemDay == today) {
                label = 'Hari ini';
              } else if (itemDay == yesterday) {
                label = 'Kemarin';
              } else {
                label = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(item.date);
              }
              grouped.putIfAbsent(label, () => []).add(item);
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                FloatingNavBar.clearance,
              ),
              children: [
                for (final entry in grouped.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.md,
                      bottom: AppSpacing.xs,
                      left: AppSpacing.xs,
                    ),
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: scheme.outline,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < entry.value.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: scheme.surfaceContainerHighest,
                            ),
                          TransactionTile(
                            item: entry.value[i],
                            onTap: () => _showTransactionDetail(
                              context,
                              ref,
                              entry.value[i],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text('Gagal memuat transaksi: $err'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  void _showTransactionDetail(
    BuildContext context,
    WidgetRef ref,
    TransactionItem item,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item.note ?? item.categoryName,
                  style: Theme.of(sheetContext)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Kategori: ${item.categoryName} • Rekening: ${item.accountName}',
                  style: Theme.of(sheetContext).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  icon: const Icon(LucideIcons.trash, color: Colors.red),
                  label: const Text('Hapus Transaksi',
                      style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    await ref
                        .read(transactionRepositoryProvider)
                        .delete(item.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaksi dihapus')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
