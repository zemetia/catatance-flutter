import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../accounts/presentation/account_providers.dart';
import 'savings_goal_providers.dart';

class SavingsGoalDetailScreen extends ConsumerWidget {
  const SavingsGoalDetailScreen({required this.goalId, super.key});

  final int goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final goal = ref.watch(savingsGoalDetailProvider(goalId)).value;
    final accounts = ref.watch(accountListProvider).value ?? const [];

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final sourceWallet = accounts.where((a) => a.id == goal.sourceAccountId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil),
            tooltip: 'Edit target',
            onPressed: () => context.push('/savings-goals/$goalId/edit'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash),
            tooltip: 'Hapus target',
            onPressed: () => _confirmDelete(context, ref, goal),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Top Hero Banner
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: goal.gradient,
                boxShadow: [
                  BoxShadow(
                    color: goal.gradient.colors.first.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Watermark
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Transform.rotate(
                      angle: -0.22,
                      child: Opacity(
                        opacity: 0.18,
                        child: Icon(
                          goal.iconOption.iconData,
                          size: 160,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.45),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                goal.iconOption.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                goal.progressPercentage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          goal.name,
                          style: textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.calendar,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              goal.deadlineLabel,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Big Nominal Progress
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Terkumpul',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  goal.formattedCurrent,
                                  style: textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Target',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  goal.formattedTarget,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: goal.progress == 0 ? 0.02 : goal.progress,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          goal.isAchieved
                              ? '🎉 Target telah tercapai penuh! Selamat!'
                              : 'Sisa kebutuhan: ${goal.formattedRemaining}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Deposit & Withdraw Action Buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _showDepositModal(context, ref, goal, accounts),
                    icon: const Icon(LucideIcons.plus, size: 18),
                    label: const Text('Nabung'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: goal.currentAmountCents > 0
                        ? () => _showWithdrawModal(context, ref, goal, accounts)
                        : null,
                    icon: const Icon(LucideIcons.arrow_up_right, size: 18),
                    label: const Text('Tarik Saldo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Autosave Card with live toggle and trigger
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: goal.autoSaveEnabled
                      ? const Color(0xFFC6FF3D).withValues(alpha: 0.4)
                      : scheme.outline.withValues(alpha: 0.08),
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC6FF3D).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              LucideIcons.zap,
                              size: 20,
                              color: Color(0xFFC6FF3D),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Autosave (Tabung Otomatis)',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                goal.autoSaveEnabled
                                    ? 'Status: Aktif'
                                    : 'Status: Nonaktif',
                                style: textTheme.bodySmall?.copyWith(
                                  color: goal.autoSaveEnabled
                                      ? const Color(0xFFC6FF3D)
                                      : scheme.outline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: goal.autoSaveEnabled,
                        activeTrackColor: const Color(0xFFC6FF3D),
                        onChanged: (val) {
                          if (val && goal.autoSaveAmountCents <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Atur nominal autosave terlebih dahulu melalui menu Edit',
                                ),
                              ),
                            );
                            context.push('/savings-goals/${goal.id}/edit');
                            return;
                          }
                          ref
                              .read(savingsGoalActionProvider.notifier)
                              .toggleAutoSave(goal.id, val);
                        },
                      ),
                    ],
                  ),
                  if (goal.autoSaveEnabled) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.sm),
                    _DetailRow(
                      label: 'Nominal Autosave',
                      value: formatRupiah(goal.autoSaveAmountCents),
                    ),
                    _DetailRow(
                      label: 'Frekuensi',
                      value: goal.autoSaveFrequencyLabel,
                    ),
                    if (sourceWallet != null)
                      _DetailRow(
                        label: 'Sumber Dompet',
                        value:
                            '${sourceWallet.name} (${formatRupiahCompact(sourceWallet.balanceCents)})',
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: () async {
                          final success = await ref
                              .read(savingsGoalActionProvider.notifier)
                              .executeAutoSave(goal.id);
                          if (context.mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Autosave berhasil dieksekusi! ⚡'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(LucideIcons.zap, size: 16),
                        label: const Text('Jalankan Autosave Sekarang'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Notes / Motivation Card
            if (goal.note != null && goal.note!.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.quote, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Catatan Motivasi',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      goal.note!,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Target Tabungan?'),
        content: Text(
          'Target "${goal.name}" akan dihapus permanen. Saldo tabungan (${goal.formattedCurrent}) tidak akan otomatis dikembalikan ke dompet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(savingsGoalActionProvider.notifier)
                  .deleteGoal(goal.id);
              if (context.mounted) {
                context.pop();
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showDepositModal(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
    List<dynamic> accounts,
  ) {
    int? selectedAcc = goal.sourceAccountId ?? (accounts.isNotEmpty ? accounts.first.id : null);
    final controller = TextEditingController(text: '100.000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final scheme = Theme.of(ctx).colorScheme;
          final textTheme = Theme.of(ctx).textTheme;

          return Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nabung ke "${goal.name}"',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nominal Tabungan',
                    prefixText: 'Rp ',
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (accounts.isNotEmpty) ...[
                  Text(
                    'Ambil Dari Dompet (Opsional)',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    initialValue: selectedAcc,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: scheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: accounts.map((a) {
                      return DropdownMenuItem<int>(
                        value: a.id,
                        child: Text('${a.name} (${formatRupiahCompact(a.balanceCents)})'),
                      );
                    }).toList(),
                    onChanged: (val) => setModalState(() => selectedAcc = val),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () async {
                      final digits = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
                      final amount = int.tryParse(digits) ?? 0;
                      if (amount <= 0) return;

                      if (selectedAcc != null) {
                        final wallet = accounts.where((a) => a.id == selectedAcc).firstOrNull;
                        if (wallet != null && wallet.balanceCents < amount) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Saldo dompet "${wallet.name}" tidak mencukupi (${formatRupiahCompact(wallet.balanceCents)})',
                              ),
                              backgroundColor: Theme.of(context).colorScheme.error,
                            ),
                          );
                          return;
                        }
                      }

                      Navigator.of(ctx).pop();
                      await ref.read(savingsGoalActionProvider.notifier).deposit(
                            goal.id,
                            amount,
                            sourceAccountId: selectedAcc,
                          );
                    },
                    child: const Text('Simpan Tabungan'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showWithdrawModal(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
    List<dynamic> accounts,
  ) {
    int? selectedAcc = goal.sourceAccountId ?? (accounts.isNotEmpty ? accounts.first.id : null);
    final controller = TextEditingController(text: '50.000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final scheme = Theme.of(ctx).colorScheme;
          final textTheme = Theme.of(ctx).textTheme;

          return Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tarik Saldo dari "${goal.name}"',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Saldo tersedia: ${goal.formattedCurrent}',
                  style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nominal Penarikan',
                    prefixText: 'Rp ',
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (accounts.isNotEmpty) ...[
                  Text(
                    'Kembalikan ke Dompet',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    initialValue: selectedAcc,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: scheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: accounts.map((a) {
                      return DropdownMenuItem<int>(
                        value: a.id,
                        child: Text('${a.name} (${formatRupiahCompact(a.balanceCents)})'),
                      );
                    }).toList(),
                    onChanged: (val) => setModalState(() => selectedAcc = val),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () async {
                      final digits = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
                      final amount = int.tryParse(digits) ?? 0;
                      if (amount <= 0) return;

                      if (amount > goal.currentAmountCents) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Nominal penarikan melebihi saldo tabungan (${goal.formattedCurrent})',
                            ),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                        return;
                      }

                      Navigator.of(ctx).pop();
                      await ref.read(savingsGoalActionProvider.notifier).withdraw(
                            goal.id,
                            amount,
                            targetAccountId: selectedAcc,
                          );
                    },
                    child: const Text('Konfirmasi Penarikan'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: scheme.outline, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
