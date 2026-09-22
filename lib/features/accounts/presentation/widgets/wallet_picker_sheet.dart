import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/account.dart';

/// Bottom sheet used by the transfer screen to pick a "Dari"/"Ke" wallet.
Future<Account?> showWalletPickerSheet(
  BuildContext context, {
  required String title,
  required List<Account> accounts,
  required Account? selected,
}) {
  return showModalBottomSheet<Account>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _WalletPickerSheet(
      title: title,
      accounts: accounts,
      selected: selected,
    ),
  );
}

class _WalletPickerSheet extends StatelessWidget {
  const _WalletPickerSheet({
    required this.title,
    required this.accounts,
    required this.selected,
  });

  final String title;
  final List<Account> accounts;
  final Account? selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final account in accounts) ...[
              _WalletOption(
                account: account,
                selected: account.id == selected?.id,
                onTap: () => Navigator.of(context).pop(account),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/wallets');
                },
                icon: const Icon(LucideIcons.wallet, size: 16),
                label: const Text('Kelola dompet'),
                style: TextButton.styleFrom(foregroundColor: scheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletOption extends StatelessWidget {
  const _WalletOption({
    required this.account,
    required this.selected,
    required this.onTap,
  });

  final Account account;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: selected
          ? account.color.withValues(alpha: 0.14)
          : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: selected ? account.color : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              IconBadge(
                icon: account.type.icon,
                color: account.color,
                shape: BoxShape.rectangle,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      formatRupiahCompact(account.balanceCents),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(LucideIcons.circle_check, color: account.color, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
