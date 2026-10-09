import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/transaction_item.dart';
import 'transaction_providers.dart';
import 'widgets/transaction_detail_sheet.dart';
import 'widgets/transaction_tile.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  static final _groupDateFormatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

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
        actions: [
          IconButton(
            tooltip: 'Transaksi Batch',
            icon: const Icon(LucideIcons.layers),
            onPressed: () => context.push('/transactions/batch'),
          ),
        ],
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
                label = _groupDateFormatter.format(item.date);
              }
              grouped.putIfAbsent(label, () => []).add(item);
            }

            final entries = grouped.entries.toList();

            return SmoothListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                FloatingNavBar.clearance,
              ),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return AnimatedScrollItem(
                  index: index,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        enableAnimation: false,
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
                                key: ValueKey(entry.value[i].id),
                                item: entry.value[i],
                                onTap: () => showTransactionDetailSheet(
                                  context,
                                  item: entry.value[i],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
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
}
