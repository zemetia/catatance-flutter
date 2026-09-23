import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/currencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import 'batch_transaction_providers.dart';
import 'widgets/batch_draft_form_sheet.dart';

/// Lets the user stage several transactions locally and commit them to the
/// database in one batch, instead of saving one-by-one via
/// [AddTransactionScreen]. Built for manual use today; the same staged-list
/// shape is what a future AI parser or voice-input pipeline would fill
/// before handing the batch off to [processAll] for review and confirm.
class BatchTransactionScreen extends ConsumerWidget {
  const BatchTransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final drafts = ref.watch(batchDraftListProvider);
    final netTotal = ref.watch(batchDraftNetTotalProvider);
    final actionState = ref.watch(batchTransactionActionProvider);
    final isProcessing = actionState.isLoading;

    Future<void> addDraft() async {
      final notifier = ref.read(batchDraftListProvider.notifier);
      final draft = await showBatchDraftFormSheet(
        context,
        localId: notifier.nextLocalId(),
      );
      if (draft != null) notifier.add(draft);
    }

    Future<void> editDraft(BatchTransactionDraft draft) async {
      final updated = await showBatchDraftFormSheet(
        context,
        localId: draft.localId,
        initial: draft,
      );
      if (updated != null) {
        ref.read(batchDraftListProvider.notifier).update(draft.localId, updated);
      }
    }

    void removeDraft(BatchTransactionDraft draft) {
      ref.read(batchDraftListProvider.notifier).remove(draft.localId);
    }

    Future<void> processAll() async {
      if (drafts.isEmpty || isProcessing) return;
      final total = drafts.length;
      final processed = await ref
          .read(batchTransactionActionProvider.notifier)
          .processAll(drafts);

      if (!context.mounted) return;

      if (processed == total) {
        ref.read(batchDraftListProvider.notifier).clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$total transaksi berhasil diproses')),
        );
        if (context.canPop()) context.pop();
      } else {
        // Drop only the drafts that were actually committed; leave the
        // rest staged so the user can fix and retry instead of losing
        // everything on a partial failure.
        final notifier = ref.read(batchDraftListProvider.notifier);
        for (final draft in drafts.take(processed)) {
          notifier.remove(draft.localId);
        }
        final err = ref.read(batchTransactionActionProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Berhasil $processed dari $total transaksi. Gagal: $err',
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Batch'),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (drafts.isNotEmpty)
            IconButton(
              tooltip: 'Hapus semua',
              icon: const Icon(LucideIcons.trash, size: 20),
              onPressed: () => ref.read(batchDraftListProvider.notifier).clear(),
            ),
        ],
      ),
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
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.layers, color: scheme.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Susun beberapa transaksi dulu, lalu proses sekaligus. Cocok dipakai bareng AI atau input suara nanti.',
                        style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: drafts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: EmptyStateCard(
                          icon: LucideIcons.clipboard_list,
                          title: 'Belum ada transaksi di batch',
                          description:
                              'Tambahkan transaksi satu per satu, lalu proses semuanya sekaligus.',
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      itemCount: drafts.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final draft = drafts[index];
                        return _BatchDraftTile(
                          draft: draft,
                          onTap: () => editDraft(draft),
                          onDelete: () => removeDraft(draft),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  OutlinedButton.icon(
                    onPressed: isProcessing ? null : addDraft,
                    icon: const Icon(LucideIcons.plus, size: 18),
                    label: const Text('Tambah Transaksi'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton.icon(
                    onPressed: (drafts.isNotEmpty && !isProcessing)
                        ? processAll
                        : null,
                    icon: isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(LucideIcons.send, size: 18),
                    label: Text(
                      drafts.isEmpty
                          ? 'Proses Semua'
                          : 'Proses Semua (${drafts.length}) — Net ${formatRupiah(netTotal)}',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BatchDraftTile extends StatelessWidget {
  const _BatchDraftTile({
    required this.draft,
    required this.onTap,
    required this.onDelete,
  });

  final BatchTransactionDraft draft;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = draft.isExpense ? AppColors.expense : AppColors.income;

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.16),
                child: Icon(
                  draft.isExpense
                      ? LucideIcons.arrow_up_right
                      : LucideIcons.arrow_down_left,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.note?.isNotEmpty == true ? draft.note! : draft.categoryName,
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${draft.categoryName} • ${draft.accountName} • '
                      '${DateFormat('d MMM', 'id_ID').format(draft.date)}'
                      '${draft.savingsGoalName != null ? ' • 🎯 ${draft.savingsGoalName}' : ''}',
                      style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${draft.isExpense ? '-' : '+'}'
                '${formatCurrency(draft.amountCents, currency: Currency.maybeFromCode(draft.accountCurrencyCode) ?? defaultCurrency)}',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.trash, size: 18, color: scheme.outline),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
