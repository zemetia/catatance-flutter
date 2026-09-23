import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';

/// Interactive savings calculator modal to plan goals and simulate daily/weekly/monthly commitments.
class SavingsCalculatorSheet extends HookConsumerWidget {
  const SavingsCalculatorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SavingsCalculatorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final targetAmountController = useTextEditingController(text: '15.000.000');
    final durationMonths = useState(6); // Default 6 months

    int parseTarget() {
      final clean = targetAmountController.text.replaceAll(RegExp(r'[^\d]'), '');
      return int.tryParse(clean) ?? 0;
    }

    final targetVal = parseTarget();
    final months = durationMonths.value;

    final monthlySave = months > 0 ? (targetVal / months).round() : 0;
    final weeklySave = months > 0 ? (targetVal / (months * 4.33)).round() : 0;
    final dailySave = months > 0 ? (targetVal / (months * 30)).round() : 0;

    final calculatedTargetDate = DateTime.now().add(Duration(days: months * 30));

    void setAmountPreset(int val) {
      targetAmountController.text = NumberFormat('#,###', 'id_ID').format(val);
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
                  color: const Color(0xFFC6FF3D).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.calculator,
                  color: Color(0xFFC6FF3D),
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simulasi & Kalkulator Target',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Rencanakan tabungan impian dengan hitungan presisi',
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

          // Target Nominal Input
          Text(
            'Target Dana Yang Ingin Dikumpulkan',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: targetAmountController,
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
                  targetAmountController.value = TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 8),

          // Presets
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CalcChip(
                  label: '5 Jt',
                  onTap: () => setAmountPreset(5000000),
                ),
                const SizedBox(width: 6),
                _CalcChip(
                  label: '10 Jt',
                  onTap: () => setAmountPreset(10000000),
                ),
                const SizedBox(width: 6),
                _CalcChip(
                  label: '25 Jt',
                  onTap: () => setAmountPreset(25000000),
                ),
                const SizedBox(width: 6),
                _CalcChip(
                  label: '50 Jt',
                  onTap: () => setAmountPreset(50000000),
                ),
                const SizedBox(width: 6),
                _CalcChip(
                  label: '100 Jt',
                  onTap: () => setAmountPreset(100000000),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Duration Selector
          Text(
            'Jangka Waktu / Target Tercapai ($months Bulan)',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _DurationChip(
                  label: '3 Bulan',
                  isSelected: durationMonths.value == 3,
                  onTap: () => durationMonths.value = 3,
                ),
                const SizedBox(width: 6),
                _DurationChip(
                  label: '6 Bulan',
                  isSelected: durationMonths.value == 6,
                  onTap: () => durationMonths.value = 6,
                ),
                const SizedBox(width: 6),
                _DurationChip(
                  label: '12 Bulan (1 Thn)',
                  isSelected: durationMonths.value == 12,
                  onTap: () => durationMonths.value = 12,
                ),
                const SizedBox(width: 6),
                _DurationChip(
                  label: '24 Bulan (2 Thn)',
                  isSelected: durationMonths.value == 24,
                  onTap: () => durationMonths.value = 24,
                ),
                const SizedBox(width: 6),
                _DurationChip(
                  label: '36 Bulan (3 Thn)',
                  isSelected: durationMonths.value == 36,
                  onTap: () => durationMonths.value = 36,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Result Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.18),
                  scheme.surfaceContainerHighest,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.sparkles, size: 16, color: Color(0xFFC6FF3D)),
                    const SizedBox(width: 6),
                    Text(
                      'Rekomendasi Setoran Rutin',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PeriodCard(
                      label: 'Per Bulan',
                      amount: formatRupiah(monthlySave),
                      isMain: true,
                    ),
                    const SizedBox(width: 8),
                    _PeriodCard(
                      label: 'Per Minggu',
                      amount: formatRupiah(weeklySave),
                    ),
                    const SizedBox(width: 8),
                    _PeriodCard(
                      label: 'Per Hari',
                      amount: formatRupiah(dailySave),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '💡 Sisihkan ${formatRupiah(dailySave)}/hari, impianmu terkumpul pada ${formatDate(calculatedTargetDate)}.',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Action Button to Create This Goal
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: targetVal <= 0
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      final dateParam = calculatedTargetDate.toIso8601String().substring(0, 10);
                      context.push(
                        '/savings-goals/new?name=Target%20Impian&target=$targetVal&date=$dateParam',
                      );
                    },
              icon: const Icon(LucideIcons.rocket),
              label: const Text(
                'Jadikan Target Tabungan Ini 🚀',
                style: TextStyle(
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

class _CalcChip extends StatelessWidget {
  const _CalcChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.white24)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({
    required this.label,
    required this.amount,
    this.isMain = false,
  });

  final String label;
  final String amount;
  final bool isMain;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isMain
              ? scheme.primary.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
