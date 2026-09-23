import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/currencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../data/split_bill_repository.dart';
import '../domain/split_bill.dart';
import 'split_bill_providers.dart';

/// Context handed over from `AddTransactionScreen` when the user taps
/// "Patungan": the nominal, wallet, category, date and note already
/// chosen there, which this screen treats as fixed (the total tagihan).
class SplitBillFormArgs {
  const SplitBillFormArgs({
    required this.accountId,
    required this.accountName,
    required this.categoryId,
    required this.categoryName,
    required this.totalAmountCents,
    required this.date,
    this.currency = defaultCurrency,
    this.note,
  });

  final int accountId;
  final String accountName;
  final int categoryId;
  final String categoryName;
  final int totalAmountCents;
  final DateTime date;
  final Currency currency;
  final String? note;
}

class _EqualShares {
  const _EqualShares({
    required this.payerShareCents,
    required this.participantShares,
  });

  final int payerShareCents;
  final List<int> participantShares;
}

_EqualShares _computeEqualShares({
  required int totalAmountCents,
  required int participantCount,
  required bool payerIncluded,
}) {
  final divisor = participantCount + (payerIncluded ? 1 : 0);
  if (divisor <= 0) {
    return _EqualShares(
      payerShareCents: 0,
      participantShares: List.filled(participantCount, 0),
    );
  }

  final base = totalAmountCents ~/ divisor;
  var remainder = totalAmountCents - base * divisor;

  var payerShare = 0;
  if (payerIncluded) {
    payerShare = base;
    if (remainder > 0) {
      payerShare += 1;
      remainder -= 1;
    }
  }

  final shares = <int>[];
  for (var i = 0; i < participantCount; i++) {
    var share = base;
    if (remainder > 0) {
      share += 1;
      remainder -= 1;
    }
    shares.add(share);
  }

  return _EqualShares(payerShareCents: payerShare, participantShares: shares);
}

/// Full-screen patungan (group bill) form: pick equal/custom split and
/// whether the payer's own share is included, name each participant, and
/// save — which creates the one expense transaction for the full amount
/// paid plus a Piutang (receivable) per named participant, atomically.
class SplitBillFormScreen extends HookConsumerWidget {
  const SplitBillFormScreen({required this.args, super.key});

  final SplitBillFormArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final mode = useState(SplitBillMode.equal);
    final payerIncluded = useState(true);
    final isSaving = useState(false);

    final nextId = useRef<int>(2);
    final participantIds = useState<List<int>>([0, 1]);
    final names = useState<Map<int, String>>({0: '', 1: ''});
    final customAmounts = useState<Map<int, int>>({0: 0, 1: 0});
    final payerCustomShare = useState<int>(0);

    final total = args.totalAmountCents;

    final equalShares = useMemoized(
      () => _computeEqualShares(
        totalAmountCents: total,
        participantCount: participantIds.value.length,
        payerIncluded: payerIncluded.value,
      ),
      [total, participantIds.value.length, payerIncluded.value],
    );

    final isCustom = mode.value == SplitBillMode.custom;

    final payerPortion = payerIncluded.value
        ? (isCustom ? payerCustomShare.value : equalShares.payerShareCents)
        : 0;
    final participantsSum = isCustom
        ? customAmounts.value.values.fold<int>(0, (sum, v) => sum + v)
        : equalShares.participantShares.fold<int>(0, (sum, v) => sum + v);
    final remaining = total - payerPortion - participantsSum;

    void addParticipant() {
      final id = nextId.value++;
      participantIds.value = [...participantIds.value, id];
      names.value = {...names.value, id: ''};
      customAmounts.value = {...customAmounts.value, id: 0};
    }

    void removeParticipant(int id) {
      if (participantIds.value.length <= 1) return;
      participantIds.value =
          participantIds.value.where((x) => x != id).toList();
      names.value = Map.of(names.value)..remove(id);
      customAmounts.value = Map.of(customAmounts.value)..remove(id);
    }

    int remainingExcludingParticipant(int id) {
      final othersSum = customAmounts.value.entries
          .where((e) => e.key != id)
          .fold<int>(0, (sum, e) => sum + e.value);
      return total - payerPortion - othersSum;
    }

    int remainingExcludingPayer() {
      final participantsOnlySum =
          customAmounts.value.values.fold<int>(0, (sum, v) => sum + v);
      return total - participantsOnlySum;
    }

    final canSubmit = !isSaving.value &&
        participantIds.value.every((id) => (names.value[id] ?? '').trim().isNotEmpty) &&
        (isCustom
            ? remaining == 0 &&
                customAmounts.value.values.every((v) => v > 0) &&
                (!payerIncluded.value || payerCustomShare.value > 0)
            : true);

    Future<void> submit() async {
      final participants = <SplitBillParticipantDraft>[
        for (var i = 0; i < participantIds.value.length; i++)
          SplitBillParticipantDraft(
            name: names.value[participantIds.value[i]]!.trim(),
            amountCents: isCustom
                ? customAmounts.value[participantIds.value[i]]!
                : equalShares.participantShares[i],
          ),
      ];

      final draft = SplitBillDraft(
        accountId: args.accountId,
        categoryId: args.categoryId,
        totalAmountCents: total,
        payerIncluded: payerIncluded.value,
        payerShareCents: payerPortion,
        participants: participants,
        date: args.date,
        note: args.note,
      );

      isSaving.value = true;
      try {
        await ref.read(splitBillActionProvider.notifier).createSplitBill(draft);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Patungan tersimpan: pengeluaran ${formatCurrencyInput(total, currency: args.currency)} + '
                '${participants.length} piutang dicatat',
              ),
            ),
          );
          context.pop(true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan patungan: $e')),
          );
        }
      } finally {
        isSaving.value = false;
      }
    }

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
                      'Patungan (Split Bill)',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
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
                  // Bill summary (fixed, set from Add Transaction screen)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total tagihan',
                              style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
                            ),
                            Text(
                              formatCurrencyInput(total, currency: args.currency),
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${args.accountName} • ${args.categoryName} • ${formatDate(args.date)}',
                          style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Mode selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        for (final m in SplitBillMode.values)
                          Expanded(
                            child: InkWell(
                              onTap: () => mode.value = m,
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: mode.value == m
                                      ? scheme.primary.withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: mode.value == m ? scheme.primary : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      m.label,
                                      style: textTheme.titleSmall?.copyWith(
                                        color: mode.value == m ? scheme.primary : scheme.onSurface,
                                        fontWeight: mode.value == m ? FontWeight.w800 : FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      m.description,
                                      textAlign: TextAlign.center,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: scheme.outline,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Payer included switch
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.user_check, size: 20, color: scheme.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saya ikut patungan',
                                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                payerIncluded.value
                                    ? 'Porsi saya jadi beban sendiri, bukan piutang'
                                    : 'Saya cuma nalangin, semua bagian jadi piutang',
                                style: textTheme.labelSmall?.copyWith(color: scheme.outline),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: payerIncluded.value,
                          onChanged: (v) => payerIncluded.value = v,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Payer share row
                  if (payerIncluded.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _ShareRow(
                        key: const ValueKey('payer'),
                        label: 'Porsi Saya',
                        icon: LucideIcons.user,
                        currency: args.currency,
                        editable: isCustom,
                        readOnlyAmountCents: isCustom ? null : equalShares.payerShareCents,
                        initialAmountCents: payerCustomShare.value,
                        onAmountChanged: (v) => payerCustomShare.value = v,
                        onFillRemaining: () {
                          final val = remainingExcludingPayer();
                          if (val <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bagian orang lain sudah menyamai/melebihi total tagihan'),
                              ),
                            );
                            return null;
                          }
                          payerCustomShare.value = val;
                          return val;
                        },
                      ),
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Orang',
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextButton.icon(
                        onPressed: addParticipant,
                        icon: const Icon(LucideIcons.user_plus, size: 16),
                        label: const Text('Tambah orang'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  for (var i = 0; i < participantIds.value.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _ParticipantRow(
                        key: ValueKey(participantIds.value[i]),
                        initialName: names.value[participantIds.value[i]] ?? '',
                        currency: args.currency,
                        editable: isCustom,
                        readOnlyAmountCents: isCustom ? null : equalShares.participantShares[i],
                        onNameChanged: (v) {
                          names.value = {...names.value, participantIds.value[i]: v};
                        },
                        onAmountChanged: (v) {
                          customAmounts.value = {
                            ...customAmounts.value,
                            participantIds.value[i]: v,
                          };
                        },
                        onFillRemaining: () {
                          final val = remainingExcludingParticipant(participantIds.value[i]);
                          if (val <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Total sudah melebihi/menyamai tagihan, kurangi bagian lain dulu'),
                              ),
                            );
                            return null;
                          }
                          customAmounts.value = {
                            ...customAmounts.value,
                            participantIds.value[i]: val,
                          };
                          return val;
                        },
                        canRemove: participantIds.value.length > 1,
                        onRemove: () => removeParticipant(participantIds.value[i]),
                      ),
                    ),

                  if (isCustom) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _RemainingBanner(
                      remainingCents: remaining,
                      currency: args.currency,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: canSubmit ? submit : null,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isSaving.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Simpan Patungan (${formatCurrencyInput(total, currency: args.currency)})',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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

/// One participant's name (+ amount, when [editable]) input row.
class _ParticipantRow extends HookWidget {
  const _ParticipantRow({
    required super.key,
    required this.initialName,
    required this.editable,
    required this.readOnlyAmountCents,
    required this.onNameChanged,
    required this.onAmountChanged,
    required this.onFillRemaining,
    required this.canRemove,
    required this.onRemove,
    this.currency = defaultCurrency,
  });

  final String initialName;
  final bool editable;
  final int? readOnlyAmountCents;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<int> onAmountChanged;
  final int? Function() onFillRemaining;
  final bool canRemove;
  final VoidCallback onRemove;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final nameController = useTextEditingController(text: initialName);
    final amountController = useTextEditingController();

    int parseAmount() {
      final clean = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(clean) ?? 0;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: editable ? 5 : 6,
            child: TextField(
              controller: nameController,
              onChanged: onNameChanged,
              decoration: const InputDecoration(
                hintText: 'Nama orang',
                isDense: true,
                border: InputBorder.none,
              ),
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          if (editable)
            Expanded(
              flex: 4,
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                onChanged: (_) => onAmountChanged(parseAmount()),
                decoration: InputDecoration(
                  hintText: '0',
                  prefixText: '${currency.symbol} ',
                  isDense: true,
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    tooltip: 'Isi sisa',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(LucideIcons.wand_sparkles, size: 16),
                    onPressed: () {
                      final filled = onFillRemaining();
                      if (filled != null) {
                        amountController.text = filled.toString();
                      }
                    },
                  ),
                ),
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            )
          else
            Expanded(
              flex: 4,
              child: Text(
                formatCurrencyInput(readOnlyAmountCents ?? 0, currency: currency),
                textAlign: TextAlign.right,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          if (canRemove) ...[
            const SizedBox(width: AppSpacing.xs),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(LucideIcons.x, size: 16, color: scheme.error),
              onPressed: onRemove,
            ),
          ],
        ],
      ),
    );
  }
}

/// The payer's own share row: read-only in equal mode, editable in custom.
class _ShareRow extends HookWidget {
  const _ShareRow({
    required super.key,
    required this.label,
    required this.icon,
    required this.editable,
    required this.readOnlyAmountCents,
    required this.initialAmountCents,
    required this.onAmountChanged,
    required this.onFillRemaining,
    this.currency = defaultCurrency,
  });

  final String label;
  final IconData icon;
  final bool editable;
  final int? readOnlyAmountCents;
  final int initialAmountCents;
  final ValueChanged<int> onAmountChanged;
  final int? Function() onFillRemaining;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final amountController = useTextEditingController(
      text: initialAmountCents > 0 ? initialAmountCents.toString() : '',
    );

    int parseAmount() {
      final clean = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(clean) ?? 0;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (editable)
            SizedBox(
              width: 150,
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                onChanged: (_) => onAmountChanged(parseAmount()),
                decoration: InputDecoration(
                  hintText: '0',
                  prefixText: '${currency.symbol} ',
                  isDense: true,
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    tooltip: 'Isi sisa',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(LucideIcons.wand_sparkles, size: 16),
                    onPressed: () {
                      final filled = onFillRemaining();
                      if (filled != null) {
                        amountController.text = filled.toString();
                      }
                    },
                  ),
                ),
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
            )
          else
            Text(
              formatCurrencyInput(readOnlyAmountCents ?? 0, currency: currency),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Shows how much of the total tagihan is still unallocated (or over) in
/// custom mode — submit stays disabled until this reads exactly 0.
class _RemainingBanner extends StatelessWidget {
  const _RemainingBanner({
    required this.remainingCents,
    this.currency = defaultCurrency,
  });

  final int remainingCents;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (color, icon, text) = switch (remainingCents) {
      0 => (AppColors.income, LucideIcons.circle_check, 'Pas! Total sudah sesuai tagihan.'),
      > 0 => (AppColors.warning, LucideIcons.circle_alert,
          'Sisa ${formatCurrencyInput(remainingCents, currency: currency)} belum dialokasikan ke siapa pun.'),
      _ => (scheme.error, LucideIcons.circle_x,
          'Kelebihan ${formatCurrencyInput(-remainingCents, currency: currency)} dari total tagihan.'),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
