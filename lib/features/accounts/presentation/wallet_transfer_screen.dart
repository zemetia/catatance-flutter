import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../domain/account.dart';
import 'account_providers.dart';
import 'widgets/amount_keypad.dart';
import 'widgets/wallet_picker_sheet.dart';

/// "Transfer antar dompet" — moves a balance from one wallet to another.
class WalletTransferScreen extends HookConsumerWidget {
  const WalletTransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final accounts = ref.watch(accountListProvider).value ?? const <Account>[];
    final from = useState<Account?>(null);
    final to = useState<Account?>(null);
    final amountDigits = useState('');
    final actionState = ref.watch(walletActionProvider);

    useEffect(() {
      if (accounts.isNotEmpty && from.value == null && to.value == null) {
        from.value = accounts.first;
        to.value = accounts.length > 1 ? accounts[1] : accounts.first;
      }
      return null;
    }, [accounts.length]);

    final amount =
        int.tryParse(amountDigits.value.isEmpty ? '0' : amountDigits.value) ??
        0;
    final sameWallet =
        from.value != null &&
        to.value != null &&
        from.value!.id == to.value!.id;
    final insufficientFunds =
        from.value != null && amount > from.value!.balanceCents;
    final canTransfer =
        from.value != null &&
        to.value != null &&
        amount > 0 &&
        !sameWallet &&
        !insufficientFunds &&
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
                  Text(
                    formatRupiah(amount),
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
                text: 'Saldo tidak cukup untuk transfer ini.',
                scheme: scheme,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AmountKeypad(
              onKey: (key) {
                if (key == 'backspace') {
                  if (amountDigits.value.isNotEmpty) {
                    amountDigits.value = amountDigits.value.substring(
                      0,
                      amountDigits.value.length - 1,
                    );
                  }
                } else if (key != '.' && amountDigits.value.length < 12) {
                  amountDigits.value = amountDigits.value == '0'
                      ? key
                      : amountDigits.value + key;
                }
              },
            ),
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
                      formatRupiahCompact(account!.balanceCents),
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
