import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/account.dart';
import 'account_providers.dart';

/// "Semua dompet" — full list of the user's wallets/accounts, grouped into
/// "Pribadi" (personal, backed by the `Accounts` table) and "Bareng" (shared
/// wallets — not modeled in the DB yet, shown as a coming-soon empty state).
class WalletListScreen extends HookConsumerWidget {
  const WalletListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tabIndex = useState(0);

    final accountsAsync = ref.watch(accountListProvider);
    final totalBalance = ref.watch(totalBalanceProvider);

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
                      'Semua dompet',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  CircleIconButton(
                    icon: LucideIcons.arrow_left_right,
                    backgroundColor: scheme.surfaceContainerHigh,
                    onTap: () => context.push('/wallets/transfer'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  CircleIconButton(
                    icon: LucideIcons.plus,
                    backgroundColor: scheme.primary,
                    onTap: () => context.push('/wallets/new'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _WalletGroupTabs(
                index: tabIndex.value,
                onChanged: (i) => tabIndex.value = i,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: accountsAsync.when(
                data: (accounts) => tabIndex.value == 0
                    ? _PersonalWallets(
                        accounts: accounts,
                        totalBalanceCents: totalBalance,
                      )
                    : const _SharedWalletsPlaceholder(),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text('Gagal memuat dompet: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletGroupTabs extends StatelessWidget {
  const _WalletGroupTabs({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const _labels = ['Pribadi', 'Bareng'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: i == index ? scheme.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Text(
                    _labels[i],
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: i == index
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: i == index ? scheme.onSurface : scheme.outline,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PersonalWallets extends ConsumerWidget {
  const _PersonalWallets({
    required this.accounts,
    required this.totalBalanceCents,
  });

  final List<Account> accounts;
  final int totalBalanceCents;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus dompet?'),
        content: Text('Dompet "${account.name}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(walletActionProvider.notifier).deleteWallet(account.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (accounts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: EmptyStateCard(
          icon: LucideIcons.wallet,
          title: 'Belum ada dompet',
          description:
              'Tambahkan bank, e-wallet, atau tunai untuk mulai mencatat.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total saldo',
                style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                formatRupiah(totalBalanceCents),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${accounts.length} dompet',
                style: textTheme.bodySmall?.copyWith(color: scheme.outline),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < accounts.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          _WalletCard(
            account: accounts[i],
            delay: Duration(milliseconds: 40 * i),
            onTap: () => context.push('/wallets/${accounts[i].id}/edit'),
            onDelete: () => _confirmDelete(context, ref, accounts[i]),
          ),
        ],
      ],
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.account,
    required this.onTap,
    required this.onDelete,
    this.delay = Duration.zero,
  });

  final Account account;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.22,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
            icon: LucideIcons.trash,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
        ],
      ),
      child: AppCard(
        delay: delay,
        onTap: onTap,
        child: Row(
          children: [
            IconBadge(
              icon: account.type.icon,
              color: account.color,
              shape: BoxShape.rectangle,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          account.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (account.isDefault) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          flex: 2,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _DefaultBadge(color: account.color),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        account.currency.flag,
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${account.currency.code} · ${account.type.label}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 4,
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    account.formattedBalance,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(LucideIcons.chevron_right, size: 18, color: scheme.outline),
          ],
        ),
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        'Default',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SharedWalletsPlaceholder extends StatelessWidget {
  const _SharedWalletsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: EmptyStateCard(
        icon: LucideIcons.users,
        title: 'Dompet bareng segera hadir',
        description: 'Fitur berbagi dompet dengan keluarga atau pasangan sedang disiapkan.',
      ),
    );
  }
}
