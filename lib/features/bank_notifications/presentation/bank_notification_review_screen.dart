import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../accounts/domain/account.dart';
import '../../accounts/presentation/account_providers.dart';
import '../../accounts/presentation/widgets/wallet_picker_sheet.dart';
import '../../categories/domain/category_item.dart';
import '../../categories/presentation/category_providers.dart';
import '../domain/captured_bank_notification.dart';
import 'bank_notification_providers.dart';
import 'widgets/captured_notification_card.dart';
import 'widgets/category_picker_sheet.dart';

class BankNotificationReviewScreen extends ConsumerWidget {
  const BankNotificationReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturesAsync = ref.watch(pendingCapturesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi Terdeteksi'), centerTitle: false),
      body: capturesAsync.when(
        data: (captures) {
          if (captures.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: EmptyStateCard(
                  icon: LucideIcons.scan_line,
                  title: 'Tidak ada yang perlu ditinjau',
                  description:
                      'Notifikasi bank yang terdeteksi akan muncul di sini untuk dikonfirmasi.',
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: captures.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final capture = captures[index];
              return CapturedNotificationCard(
                capture: capture,
                onTap: () => _showConfirmSheet(context, ref, capture),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat: $err')),
      ),
    );
  }

  Future<void> _showConfirmSheet(
    BuildContext context,
    WidgetRef ref,
    CapturedBankNotification capture,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ConfirmSheetBody(capture: capture),
    );
  }
}

class _ConfirmSheetBody extends ConsumerStatefulWidget {
  const _ConfirmSheetBody({required this.capture});

  final CapturedBankNotification capture;

  @override
  ConsumerState<_ConfirmSheetBody> createState() => _ConfirmSheetBodyState();
}

class _ConfirmSheetBodyState extends ConsumerState<_ConfirmSheetBody> {
  late final TextEditingController _amountController;
  late bool _isExpense;
  Account? _wallet;
  CategoryItem? _category;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final capture = widget.capture;
    _amountController = TextEditingController(
      text: formatRupiah(capture.parsedAmountCents ?? 0),
    );
    _isExpense = capture.direction != 'income';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int get _amountCents {
    final digits = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(digits) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final capture = widget.capture;

    final accounts = ref.watch(accountListProvider).value ?? const [];
    if (_wallet == null && capture.accountId != null) {
      final match = accounts.where((a) => a.id == capture.accountId);
      if (match.isNotEmpty) _wallet = match.first;
    }

    final categoriesAsync = _isExpense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);
    final categories = categoriesAsync.value ?? const [];
    if (_category != null && !categories.any((c) => c.id == _category!.id)) {
      _category = null;
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konfirmasi Transaksi',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              capture.content,
              style: textTheme.bodySmall?.copyWith(color: scheme.outline),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
            _DirectionToggle(
              isExpense: _isExpense,
              onChanged: (value) => setState(() {
                _isExpense = value;
                _category = null;
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [_ThousandsSeparatorInputFormatter()],
              decoration: const InputDecoration(labelText: 'Nominal'),
            ),
            const SizedBox(height: AppSpacing.md),
            _PickerTile(
              label: 'Dompet',
              value: _wallet?.name ?? 'Pilih dompet',
              icon: LucideIcons.wallet,
              onTap: () async {
                final picked = await showWalletPickerSheet(
                  context,
                  title: 'Pilih dompet',
                  accounts: accounts,
                  selected: _wallet,
                );
                if (picked != null) setState(() => _wallet = picked);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _PickerTile(
              label: 'Kategori',
              value: _category?.name ?? 'Pilih kategori',
              icon: LucideIcons.tag,
              onTap: () async {
                final picked = await showCategoryPickerSheet(
                  context,
                  categories: categories,
                  selected: _category,
                  isExpense: _isExpense,
                );
                if (picked != null) setState(() => _category = picked);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : () => _dismiss(context),
                    child: const Text('Abaikan'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting || _wallet == null || _category == null
                        ? null
                        : () => _confirm(context),
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Konfirmasi'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    setState(() => _submitting = true);
    try {
      await ref
          .read(capturedNotificationActionProvider.notifier)
          .confirm(
            widget.capture.id,
            accountId: _wallet!.id,
            categoryId: _category!.id,
            amountCents: _amountCents,
            date: widget.capture.postedAt,
          );
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _dismiss(BuildContext context) async {
    setState(() => _submitting = true);
    try {
      await ref
          .read(capturedNotificationActionProvider.notifier)
          .dismiss(widget.capture.id);
      if (context.mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _DirectionToggle extends StatelessWidget {
  const _DirectionToggle({required this.isExpense, required this.onChanged});

  final bool isExpense;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _DirectionOption(
              label: 'Pengeluaran',
              selected: isExpense,
              color: AppColors.expense,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _DirectionOption(
              label: 'Pemasukan',
              selected: !isExpense,
              color: AppColors.income,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionOption extends StatelessWidget {
  const _DirectionOption({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, size: 18, color: scheme.outline),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: textTheme.bodySmall?.copyWith(color: scheme.outline)),
              const Spacer(),
              Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Icon(LucideIcons.chevron_right, size: 16, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: 'Rp 0',
        selection: TextSelection.collapsed(offset: 4),
      );
    }

    final capped = digits.length > 12 ? digits.substring(0, 12) : digits;
    final formatted = formatRupiah(int.tryParse(capped) ?? 0);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
