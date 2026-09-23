import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/currencies.dart';
import '../../../core/services/exchange_rate_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/input_formatters.dart';
import '../../categories/domain/category_item.dart';
import '../../categories/presentation/category_providers.dart';
import '../domain/account.dart';
import 'account_providers.dart';
import 'widgets/wallet_picker_sheet.dart';

/// "Transfer antar dompet" — moves a balance from one wallet to another.
///
/// When the two wallets use different currencies, the destination amount is
/// converted using a live exchange rate (Yahoo Finance chart API, the same
/// source `yfinance` uses) fetched via [exchangeRateProvider].
class WalletTransferScreen extends HookConsumerWidget {
  const WalletTransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final accounts = ref.watch(accountListProvider).value ?? const <Account>[];
    final expenseCategories =
        ref.watch(expenseCategoriesProvider).value ?? const <CategoryItem>[];
    final from = useState<Account?>(null);
    final to = useState<Account?>(null);
    final amountDigits = useState('');
    final amountController = useTextEditingController(text: 'Rp 0');
    final feeCents = useState(0);
    final manualRate = useState<double?>(null);
    final actionState = ref.watch(walletActionProvider);

    useEffect(() {
      if (accounts.isNotEmpty && from.value == null && to.value == null) {
        from.value = accounts.first;
        to.value = accounts.length > 1 ? accounts[1] : accounts.first;
      }
      return null;
    }, [accounts.length]);

    final feeCategory = expenseCategories
        .where((c) => c.name == 'Biaya Admin Transfer')
        .firstOrNull;
    const feePresets = [0, 1000, 2500];
    final isCustomFee = !feePresets.contains(feeCents.value);

    final fromCurrency = from.value?.currency ?? defaultCurrency;
    final toCurrency = to.value?.currency ?? defaultCurrency;
    final crossCurrency =
        from.value != null &&
        to.value != null &&
        fromCurrency.code != toCurrency.code;

    // Reformat the nominal field's currency symbol whenever the source
    // wallet (and so its currency) changes, keeping the raw digits intact.
    useEffect(() {
      final currentNum =
          int.tryParse(amountDigits.value.isEmpty ? '0' : amountDigits.value) ??
          0;
      final formatted = formatCurrencyInput(currentNum, currency: fromCurrency);
      amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      return null;
    }, [fromCurrency.code]);

    // A manual rate only makes sense for the currency pair it was entered
    // for — drop it the moment either side of the pair changes.
    useEffect(() {
      manualRate.value = null;
      return null;
    }, [fromCurrency.code, toCurrency.code]);

    final rateAsync = crossCurrency
        ? ref.watch(exchangeRateProvider((fromCurrency.code, toCurrency.code)))
        : const AsyncValue.data(1.0);
    final autoRate = rateAsync.value;
    final rate = manualRate.value ?? autoRate;
    final rateLoading =
        crossCurrency && manualRate.value == null && rateAsync.isLoading;
    final rateFailed =
        crossCurrency && manualRate.value == null && rateAsync.hasError;

    final amount =
        int.tryParse(amountDigits.value.isEmpty ? '0' : amountDigits.value) ??
        0;
    final convertedAmount = rate != null ? (amount * rate).round() : 0;
    final sameWallet =
        from.value != null &&
        to.value != null &&
        from.value!.id == to.value!.id;
    final insufficientFunds =
        from.value != null &&
        (amount + feeCents.value) > from.value!.balanceCents;
    final canTransfer =
        from.value != null &&
        to.value != null &&
        amount > 0 &&
        !sameWallet &&
        !insufficientFunds &&
        (!crossCurrency || (rate != null && !rateLoading)) &&
        actionState is! AsyncLoading;

    Future<void> pick(ValueNotifier<Account?> target, String title) async {
      final picked = await showWalletPickerSheet(
        context,
        title: title,
        accounts: accounts,
        selected: target.value,
      );
      if (picked != null) target.value = picked;
    }

    Future<void> submit() async {
      final notifier = ref.read(walletActionProvider.notifier);
      await notifier.transfer(
        fromId: from.value!.id,
        toId: to.value!.id,
        amountCents: amount,
        convertedAmountCents: crossCurrency ? convertedAmount : amount,
        feeCents: feeCents.value,
        feeCategoryId: feeCategory?.id,
      );
      if (context.mounted && ref.read(walletActionProvider).hasError == false) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Transfer berhasil')));
        context.pop();
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        title: const Text('Transfer antar dompet'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: Column(
                children: [
                  _WalletSelector(
                    label: 'Dari dompet',
                    account: from.value,
                    onTap: () => pick(from, 'Dari dompet'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: scheme.outline.withValues(alpha: 0.15),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: scheme.primary,
                            child: IconButton(
                              icon: Icon(
                                LucideIcons.arrow_up_down,
                                color: scheme.onPrimary,
                                size: 18,
                              ),
                              onPressed: () {
                                final swap = from.value;
                                from.value = to.value;
                                to.value = swap;
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: scheme.outline.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _WalletSelector(
                    label: 'Ke dompet',
                    account: to.value,
                    onTap: () => pick(to, 'Ke dompet'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Column(
                children: [
                  Text(
                    'NOMINAL',
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.outline,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  IntrinsicWidth(
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        ThousandsSeparatorInputFormatter(currency: fromCurrency),
                      ],
                      textAlign: TextAlign.center,
                      autofocus: true,
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: (val) {
                        final clean = val.replaceAll(RegExp(r'[^\d]'), '');
                        amountDigits.value = clean == '0' ? '' : clean;
                      },
                    ),
                  ),
                  if (crossCurrency) ...[
                    const SizedBox(height: AppSpacing.xs),
                    if (rateLoading)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Mengambil kurs ${fromCurrency.code}/${toCurrency.code}...',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.outline,
                            ),
                          ),
                        ],
                      )
                    else if (rateFailed)
                      Text(
                        'Gagal mengambil kurs ${fromCurrency.code}/${toCurrency.code}',
                        style: textTheme.bodySmall?.copyWith(color: scheme.error),
                      )
                    else if (rate != null) ...[
                      Text(
                        '≈ ${formatCurrencyInput(convertedAmount, currency: toCurrency)}'
                        ' (kurs 1 ${fromCurrency.code} = ${rate.toStringAsFixed(4)}'
                        ' ${toCurrency.code}'
                        '${manualRate.value != null ? ', manual' : ''})',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.outline,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () async {
                              final result = await _showManualRateDialog(
                                context,
                                from: fromCurrency,
                                to: toCurrency,
                                initial: rate,
                              );
                              if (result != null && result > 0) {
                                manualRate.value = result;
                              }
                            },
                            child: Text(
                              'Ganti rate manual',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          if (manualRate.value != null) ...[
                            Text(
                              ' · ',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.outline,
                              ),
                            ),
                            InkWell(
                              onTap: () => manualRate.value = null,
                              child: Text(
                                'pakai kurs otomatis',
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ] else
                      const SizedBox.shrink(),
                  ],
                ],
              ),
            ),
            if (sameWallet) ...[
              const SizedBox(height: AppSpacing.sm),
              _ValidationNote(
                text: 'Dompet asal dan tujuan tidak boleh sama.',
                scheme: scheme,
              ),
            ] else if (insufficientFunds) ...[
              const SizedBox(height: AppSpacing.sm),
              _ValidationNote(
                text: 'Saldo tidak cukup untuk transfer dan biaya admin ini.',
                scheme: scheme,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              'BIAYA ADMIN TRANSFER',
              textAlign: TextAlign.center,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.outline,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final preset in feePresets)
                  ChoiceChip(
                    label: Text(
                      preset == 0
                          ? 'Tidak ada'
                          : formatCurrencyInput(preset, currency: fromCurrency),
                    ),
                    selected: !isCustomFee && feeCents.value == preset,
                    onSelected: (_) => feeCents.value = preset,
                  ),
                ChoiceChip(
                  label: Text(
                    isCustomFee
                        ? formatCurrencyInput(
                            feeCents.value,
                            currency: fromCurrency,
                          )
                        : 'Lainnya',
                  ),
                  selected: isCustomFee,
                  onSelected: (_) async {
                    final result = await _showCustomFeeDialog(
                      context,
                      currency: fromCurrency,
                      initial: isCustomFee ? feeCents.value : 0,
                    );
                    if (result != null) feeCents.value = result;
                  },
                ),
              ],
            ),
            if (feeCents.value > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Text(
                  'Akan dicatat sebagai pengeluaran "Biaya Admin Transfer" dari dompet asal.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: canTransfer ? submit : null,
              child: actionState is AsyncLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Transfer sekarang'),
                        SizedBox(width: AppSpacing.xs),
                        Icon(LucideIcons.arrow_left_right, size: 18),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletSelector extends StatelessWidget {
  const _WalletSelector({
    required this.label,
    required this.account,
    required this.onTap,
  });

  final String label;
  final Account? account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: (account?.color ?? scheme.outline).withValues(
                alpha: 0.18,
              ),
              child: Icon(
                account?.type.icon ?? LucideIcons.wallet,
                color: account?.color ?? scheme.outline,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                  ),
                  Text(
                    account?.name ?? 'Pilih dompet',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (account != null)
                    Text(
                      account!.formattedBalanceCompact,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            Icon(LucideIcons.chevrons_up_down, size: 18, color: scheme.outline),
          ],
        ),
      ),
    );
  }
}

/// Prompts for a custom admin-fee amount, typed in [currency] (the source
/// wallet's own currency, per the transfer screen's "biaya admin" spec).
Future<int?> _showCustomFeeDialog(
  BuildContext context, {
  required Currency currency,
  required int initial,
}) {
  final controller = TextEditingController(
    text: initial > 0 ? formatCurrencyInput(initial, currency: currency) : '',
  );
  return showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Biaya admin lainnya'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        inputFormatters: [ThousandsSeparatorInputFormatter(currency: currency)],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final digits = controller.text.replaceAll(RegExp(r'[^\d]'), '');
            Navigator.of(context).pop(int.tryParse(digits) ?? 0);
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}

/// Prompts for a manual "1 [from] = ? [to]" exchange rate, overriding the
/// live-fetched one for this transfer.
Future<double?> _showManualRateDialog(
  BuildContext context, {
  required Currency from,
  required Currency to,
  double? initial,
}) {
  final controller = TextEditingController(
    text: initial != null ? initial.toStringAsFixed(4) : '',
  );
  return showDialog<double>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Ubah kurs ${from.code}/${to.code}'),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        autofocus: true,
        decoration: InputDecoration(
          prefixText: '1 ${from.code} = ',
          suffixText: to.code,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final value = double.tryParse(controller.text.replaceAll(',', '.'));
            Navigator.of(context).pop(value);
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}

class _ValidationNote extends StatelessWidget {
  const _ValidationNote({required this.text, required this.scheme});

  final String text;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: scheme.error),
      ),
    );
  }
}
