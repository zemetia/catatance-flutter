import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../accounts/presentation/account_providers.dart';
import '../savings_goal_providers.dart';

/// Modal bottom sheet allowing quick deposit into a savings goal with wallet debiting.
class QuickDepositSheet extends HookConsumerWidget {
  const QuickDepositSheet({
    required this.goals,
    this.initialGoalId,
    super.key,
  });

  final List<SavingsGoal> goals;
  final int? initialGoalId;

  static Future<void> show(
    BuildContext context, {
    required List<SavingsGoal> goals,
    int? initialGoalId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickDepositSheet(
        goals: goals,
        initialGoalId: initialGoalId,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final accounts = ref.watch(accountListProvider).value ?? const [];

    // Active goals (or all if all achieved)
    final eligibleGoals = goals.isEmpty
        ? const <SavingsGoal>[]
        : (goals.any((g) => !g.isAchieved)
            ? goals.where((g) => !g.isAchieved).toList()
            : goals);

    final selectedGoalId = useState<int?>(
      initialGoalId ?? (eligibleGoals.isNotEmpty ? eligibleGoals.first.id : null),
    );

    final currentGoal = goals.where((g) => g.id == selectedGoalId.value).firstOrNull;

    final selectedAccountId = useState<int?>(
      currentGoal?.sourceAccountId ?? (accounts.isNotEmpty ? accounts.first.id : null),
    );

    final amountController = useTextEditingController(text: '100.000');
    final isLoading = useState(false);
    final errorText = useState<String?>(null);

    int parseAmount() {
      final clean = amountController.text.replaceAll(RegExp(r'[^\d]'), '');
      return int.tryParse(clean) ?? 0;
    }

    final selectedWallet =
        accounts.where((a) => a.id == selectedAccountId.value).firstOrNull;

    Future<void> submit() async {
      final amount = parseAmount();
      if (amount <= 0) {
        errorText.value = 'Masukkan nominal tabungan yang valid';
        return;
      }

      if (selectedGoalId.value == null) {
        errorText.value = 'Pilih target tabungan terlebih dahulu';
        return;
      }

      if (selectedWallet != null && selectedWallet.balanceCents < amount) {
        errorText.value =
            'Saldo dompet ${selectedWallet.name} (${formatRupiah(selectedWallet.balanceCents)}) tidak mencukupi';
        return;
      }

      isLoading.value = true;
      errorText.value = null;

      try {
        await ref.read(savingsGoalActionProvider.notifier).deposit(
              selectedGoalId.value!,
              amount,
              sourceAccountId: selectedAccountId.value,
            );

        if (context.mounted) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Berhasil menabung ${formatRupiah(amount)} ke "${currentGoal?.name ?? 'Target'}"! 🎉',
              ),
              backgroundColor: scheme.primary,
            ),
          );
        }
      } catch (e) {
        errorText.value = e.toString().replaceAll('Exception: ', '');
      } finally {
        isLoading.value = false;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.piggy_bank,
                  color: scheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nabung Cepat',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Tambah saldo target tabungan langsung',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Target Goal Selector
          Text(
            'Target Tujuan',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          if (goals.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('Belum ada target tabungan yang dibuat'),
            )
          else
            DropdownButtonFormField<int>(
              initialValue: selectedGoalId.value,
              decoration: InputDecoration(
                filled: true,
                fillColor: scheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 12,
                ),
              ),
              items: goals.map((g) {
                return DropdownMenuItem<int>(
                  value: g.id,
                  child: Row(
                    children: [
                      Text(g.iconOption.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        g.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${g.progressPercentage})',
                        style: TextStyle(
                          color: scheme.outline,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (id) {
                selectedGoalId.value = id;
                final g = goals.where((item) => item.id == id).firstOrNull;
                if (g?.sourceAccountId != null) {
                  selectedAccountId.value = g!.sourceAccountId;
                }
              },
            ),

          if (currentGoal != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: currentGoal.gradient.colors.first.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: currentGoal.gradient.colors.first.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terkumpul: ${currentGoal.formattedCurrent}',
                    style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    currentGoal.isAchieved
                        ? '🎉 Tercapai Penuh'
                        : 'Kurang ${currentGoal.formattedRemaining}',
                    style: TextStyle(
                      color: currentGoal.isAchieved
                          ? scheme.primary
                          : scheme.outline,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // Nominal Input
          Text(
            'Nominal Yang Ingin Ditabung',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
              filled: true,
              fillColor: scheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
            ),
            onChanged: (val) {
              final digits = val.replaceAll(RegExp(r'[^\d]'), '');
              if (digits.isNotEmpty) {
                final formatted =
                    NumberFormat('#,###', 'id_ID').format(int.parse(digits));
                if (formatted != val) {
                  amountController.value = TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                }
              }
              errorText.value = null;
            },
          ),
          const SizedBox(height: 8),

          // Quick Increment Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickChip(
                  label: '+50rb',
                  onTap: () {
                    final current = parseAmount();
                    final updated = current + 50000;
                    amountController.text =
                        NumberFormat('#,###', 'id_ID').format(updated);
                  },
                ),
                const SizedBox(width: 6),
                _QuickChip(
                  label: '+100rb',
                  onTap: () {
                    final current = parseAmount();
                    final updated = current + 100000;
                    amountController.text =
                        NumberFormat('#,###', 'id_ID').format(updated);
                  },
                ),
                const SizedBox(width: 6),
                _QuickChip(
                  label: '+500rb',
                  onTap: () {
                    final current = parseAmount();
                    final updated = current + 500000;
                    amountController.text =
                        NumberFormat('#,###', 'id_ID').format(updated);
                  },
                ),
                const SizedBox(width: 6),
                _QuickChip(
                  label: '+1jt',
                  onTap: () {
                    final current = parseAmount();
                    final updated = current + 1000000;
                    amountController.text =
                        NumberFormat('#,###', 'id_ID').format(updated);
                  },
                ),
                if (currentGoal != null && !currentGoal.isAchieved) ...[
                  const SizedBox(width: 6),
                  _QuickChip(
                    label: 'Lunasi (${formatRupiahCompact(currentGoal.remainingCents)})',
                    isHighlight: true,
                    onTap: () {
                      amountController.text = NumberFormat('#,###', 'id_ID')
                          .format(currentGoal.remainingCents);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Source Wallet Picker
          if (accounts.isNotEmpty) ...[
            Text(
              'Sumber Dompet Pendebetan',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<int?>(
              initialValue: selectedAccountId.value,
              decoration: InputDecoration(
                filled: true,
                fillColor: scheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 12,
                ),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Tanpa potong dompet (Catat saja)'),
                ),
                ...accounts.map((a) {
                  return DropdownMenuItem<int?>(
                    value: a.id,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          a.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Saldo: ${formatRupiah(a.balanceCents)}',
                          style: TextStyle(
                            color: scheme.outline,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (id) => selectedAccountId.value = id,
            ),
          ],

          if (errorText.value != null) ...[
            const SizedBox(height: 10),
            Text(
              errorText.value!,
              style: TextStyle(
                color: scheme.error,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Submit CTA Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: isLoading.value ? null : submit,
              icon: isLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(LucideIcons.arrow_up_right),
              label: Text(
                isLoading.value ? 'Menyimpan...' : 'Setor Tabungan Sekarang',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.onTap,
    this.isHighlight = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isHighlight
              ? scheme.primary.withValues(alpha: 0.2)
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlight
                ? scheme.primary
                : scheme.outline.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isHighlight ? scheme.primary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
