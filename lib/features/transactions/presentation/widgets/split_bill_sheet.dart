import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';

class SplitBillResult {
  const SplitBillResult({
    required this.finalAmount,
    required this.totalAmount,
    required this.personCount,
    required this.amountPerPerson,
    required this.onlyMyShare,
  });

  final int finalAmount;
  final int totalAmount;
  final int personCount;
  final int amountPerPerson;
  final bool onlyMyShare;
}

/// Bottom sheet for splitting an expense bill among people.
Future<SplitBillResult?> showSplitBillSheet(
  BuildContext context, {
  required int initialAmount,
}) {
  return showModalBottomSheet<SplitBillResult>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
    ),
    builder: (context) => _SplitBillSheet(initialAmount: initialAmount),
  );
}

class _SplitBillSheet extends HookWidget {
  const _SplitBillSheet({required this.initialAmount});

  final int initialAmount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final personCount = useState(2);
    final onlyMyShare = useState(true);

    final total = initialAmount > 0 ? initialAmount : 100000;
    final count = personCount.value;
    final perPerson = (total / count).round();
    final finalAmount = onlyMyShare.value ? perPerson : total;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs + 2),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.users, size: 20, color: scheme.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Kalkulator Patungan (Split Bill)',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Bill summary card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total tagihan:',
                        style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
                      ),
                      Text(
                        formatRupiah(total),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jumlah orang:',
                            style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                          ),
                          Text(
                            '$count orang',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: count > 2
                                ? () => personCount.value--
                                : null,
                            icon: const Icon(LucideIcons.minus, size: 18),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '$count',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          IconButton.filledTonal(
                            onPressed: count < 20
                                ? () => personCount.value++
                                : null,
                            icon: const Icon(LucideIcons.plus, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Highlight per person amount
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Porsi per orang:',
                        style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                      ),
                      Text(
                        formatRupiah(perPerson),
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Icon(LucideIcons.user_check, color: scheme.primary, size: 28),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Mode radio options
            RadioGroup<bool>(
              groupValue: onlyMyShare.value,
              onChanged: (v) => onlyMyShare.value = v ?? true,
              child: Column(
                children: [
                  RadioListTile<bool>(
                    value: true,
                    title: const Text('Catat bagian saya saja'),
                    subtitle: Text(
                      'Nominal diubah ke ${formatRupiah(perPerson)}',
                      style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<bool>(
                    value: false,
                    title: const Text('Catat total tagihan'),
                    subtitle: Text(
                      'Simpan ${formatRupiah(total)} dan cantumkan rincian patungan di catatan',
                      style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop(
                  SplitBillResult(
                    finalAmount: finalAmount,
                    totalAmount: total,
                    personCount: count,
                    amountPerPerson: perPerson,
                    onlyMyShare: onlyMyShare.value,
                  ),
                );
              },
              icon: const Icon(LucideIcons.check, size: 18),
              label: Text(
                'Terapkan Patungan (${formatRupiah(finalAmount)})',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
