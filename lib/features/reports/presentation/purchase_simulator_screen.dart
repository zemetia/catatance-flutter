import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/input_formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../categories/presentation/category_providers.dart';
import '../domain/report_models.dart';
import 'projection_providers.dart';

enum _Verdict { unknown, blocked, caution, ok }

/// "Boleh nggak beli sesuatu?": lets the user type a hypothetical purchase
/// amount (and optionally its category) and see, before actually spending
/// it, how it lands on this month's projection, safe daily allowance, and
/// (if a budgeted category is picked) that category's remaining budget.
class PurchaseSimulatorScreen extends HookConsumerWidget {
  const PurchaseSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountCents = useState(0);
    final selectedCategoryId = useState<int?>(null);
    final controller = useTextEditingController(text: formatRupiah(0));
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final projection = ref.watch(monthProjectionProvider);
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final budgetInfo = selectedCategoryId.value != null
        ? ref.watch(categoryBudgetInfoProvider(selectedCategoryId.value!)).value
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Boleh nggak beli sesuatu?')),
      body: SafeArea(
        child: projection == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Text(
                    'Nominal rencana belanja',
                    style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (text) {
                      final digits = text.replaceAll(RegExp(r'[^\d]'), '');
                      amountCents.value = int.tryParse(digits) ?? 0;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Kategori (opsional, untuk cek budget)',
                    style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 40,
                    child: categoriesAsync.when(
                      data: (categories) => ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.xs),
                            child: ChoiceChip(
                              label: const Text('Tanpa kategori'),
                              selected: selectedCategoryId.value == null,
                              onSelected: (_) => selectedCategoryId.value = null,
                            ),
                          ),
                          for (final cat in categories)
                            Padding(
                              padding: const EdgeInsets.only(right: AppSpacing.xs),
                              child: ChoiceChip(
                                avatar: Icon(cat.iconData, size: 14, color: cat.color),
                                label: Text(cat.name),
                                selected: selectedCategoryId.value == cat.id,
                                onSelected: (_) => selectedCategoryId.value = cat.id,
                              ),
                            ),
                        ],
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SimulationResult(
                    amountCents: amountCents.value,
                    budgetInfo: budgetInfo,
                  ),
                ],
              ),
      ),
    );
  }
}

class _SimulationResult extends ConsumerWidget {
  const _SimulationResult({required this.amountCents, required this.budgetInfo});

  final int amountCents;
  final CategoryBudgetInfo? budgetInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projection = ref.watch(monthProjectionProvider)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (amountCents <= 0) {
      return AppCard(
        child: Text(
          'Masukkan nominal untuk melihat simulasinya.',
          style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
        ),
      );
    }

    final newCurrentBalance = projection.currentBalanceCents - amountCents;
    final newProjectedEnd = projection.projectedEndBalanceCents - amountCents;
    final allowanceDays = projection.daysRemaining > 0 ? projection.daysRemaining : 1;
    final newDailyAllowance = (newCurrentBalance / allowanceDays).round();

    final info = budgetInfo;
    int? newSpent;
    bool budgetWouldExceed = false;
    if (info != null) {
      newSpent = info.spentCents + amountCents;
      budgetWouldExceed = newSpent > info.limitCents;
    }
    final exceedsAllowance = amountCents > projection.dailySafeAllowanceCents;

    _Verdict verdict;
    String verdictText;
    if (newProjectedEnd < 0) {
      verdict = _Verdict.blocked;
      verdictText =
          'Jangan dulu — proyeksi akhir bulan bisa minus kalau ini dibeli sekarang.';
    } else if (budgetWouldExceed) {
      verdict = _Verdict.caution;
      verdictText = 'Hati-hati — ini bakal melebihi budget kategori itu bulan ini.';
    } else if (exceedsAllowance) {
      verdict = _Verdict.caution;
      verdictText =
          'Hati-hati — nominalnya lebih besar dari jatah harian aman saat ini.';
    } else {
      verdict = _Verdict.ok;
      verdictText = 'Boleh — masih dalam jatah harian aman dan proyeksi tetap sehat.';
    }

    final verdictColor = switch (verdict) {
      _Verdict.blocked => AppColors.expense,
      _Verdict.caution => AppColors.warning,
      _Verdict.ok => AppColors.income,
      _Verdict.unknown => scheme.outline,
    };
    final verdictIcon = switch (verdict) {
      _Verdict.blocked => LucideIcons.circle_x,
      _Verdict.caution => LucideIcons.triangle_alert,
      _Verdict.ok => LucideIcons.circle_check_big,
      _Verdict.unknown => LucideIcons.message_circle_question_mark,
    };

    Widget compareLine(
      String label,
      int before,
      int after, {
      bool warnOnIncrease = false,
    }) {
      final worse = warnOnIncrease ? after > before : after < before;
      final changed = after != before;
      final afterColor = !changed
          ? null
          : (worse ? AppColors.expense : AppColors.income);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(label, style: textTheme.bodyMedium)),
            Text(formatRupiahCompact(before), style: textTheme.bodySmall?.copyWith(color: scheme.outline)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(LucideIcons.arrow_right, size: 14),
            ),
            Text(
              formatRupiahCompact(after),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: afterColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          color: verdictColor.withValues(alpha: 0.08),
          child: Row(
            children: [
              Icon(verdictIcon, color: verdictColor),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  verdictText,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: verdictColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dampak ke kas', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.sm),
              compareLine(
                'Proyeksi akhir bulan',
                projection.projectedEndBalanceCents,
                newProjectedEnd,
              ),
              compareLine(
                'Jatah harian aman',
                projection.dailySafeAllowanceCents,
                newDailyAllowance,
              ),
              if (info != null) ...[
                const Divider(height: AppSpacing.lg),
                Text('Dampak ke budget', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.sm),
                compareLine(
                  'Terpakai dari budget',
                  info.spentCents,
                  newSpent!,
                  warnOnIncrease: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
