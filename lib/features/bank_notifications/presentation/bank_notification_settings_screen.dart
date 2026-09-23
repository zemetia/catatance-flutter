import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../accounts/domain/account.dart';
import '../../accounts/presentation/account_providers.dart';
import '../../accounts/presentation/widgets/wallet_picker_sheet.dart';
import '../domain/bank_notification_mapping.dart';
import '../domain/known_bank_apps.dart';
import 'bank_notification_providers.dart';

class BankNotificationSettingsScreen extends ConsumerWidget {
  const BankNotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final statusAsync = ref.watch(notificationListenerStatusProvider);
    final mappingsAsync = ref.watch(bankMappingListProvider);
    final accounts = ref.watch(accountListProvider).value ?? const [];
    final accountById = {for (final a in accounts) a.id: a};
    final pendingCount = ref.watch(pendingCapturesProvider).value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tangkap Notifikasi Bank'),
        centerTitle: false,
        actions: [
          if (pendingCount > 0)
            TextButton(
              onPressed: () => context.push('/bank-notifications/review'),
              child: Text('Tinjau ($pendingCount)'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          statusAsync.when(
            data: (enabled) => _StatusCard(
              enabled: enabled,
              onActivate: () =>
                  ref.read(bankNotificationBridgeProvider).openListenerSettings(),
            ),
            loading: () => _StatusCard(enabled: null, onActivate: () {}),
            error: (_, _) => _StatusCard(
              enabled: false,
              onActivate: () =>
                  ref.read(bankNotificationBridgeProvider).openListenerSettings(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text(
                'Pemetaan Aplikasi',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              CircleIconButton(
                icon: LucideIcons.plus,
                backgroundColor: scheme.surfaceContainerHigh,
                onTap: () => _addMapping(context, ref, accounts),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pilih notifikasi dari aplikasi bank/e-wallet mana yang otomatis dideteksi, dan dompet mana yang harus diperbarui.',
            style: textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: AppSpacing.md),
          mappingsAsync.when(
            data: (mappings) {
              if (mappings.isEmpty) {
                return const EmptyStateCard(
                  icon: LucideIcons.scan_line,
                  title: 'Belum ada pemetaan',
                  description:
                      'Tekan tombol + untuk memetakan notifikasi dari aplikasi bank ke salah satu dompetmu.',
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < mappings.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.sm),
                    _MappingCard(
                      mapping: mappings[i],
                      walletName: accountById[mappings[i].accountId]?.name ?? '—',
                      walletColor: accountById[mappings[i].accountId]?.color,
                      onToggle: (enabled) => ref
                          .read(bankMappingActionProvider.notifier)
                          .updateMapping(
                            mappings[i].id,
                            BankNotificationMappingDraft(
                              packageName: mappings[i].packageName,
                              appLabel: mappings[i].appLabel,
                              accountId: mappings[i].accountId,
                              isEnabled: enabled,
                            ),
                          ),
                      onDelete: () => ref
                          .read(bankMappingActionProvider.notifier)
                          .deleteMapping(mappings[i].id),
                    ),
                  ],
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text('Gagal memuat pemetaan: $err'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addMapping(
    BuildContext context,
    WidgetRef ref,
    List<Account> accountsList,
  ) async {
    if (accountsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan dompet terlebih dahulu')),
      );
      return;
    }

    final app = await context.push<KnownBankApp>('/profile/bank-notifications/pick-app');
    if (app == null || !context.mounted) return;

    final wallet = await showWalletPickerSheet(
      context,
      title: 'Simpan ke dompet mana?',
      accounts: accountsList,
      selected: null,
    );
    if (wallet == null) return;

    await ref
        .read(bankMappingActionProvider.notifier)
        .createMapping(
          BankNotificationMappingDraft(
            packageName: app.packageName,
            appLabel: app.label,
            accountId: wallet.id,
          ),
        );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.enabled, required this.onActivate});

  /// null while still loading.
  final bool? enabled;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEnabled = enabled == true;

    return AppCard(
      child: Row(
        children: [
          IconBadge(
            icon: isEnabled ? LucideIcons.shield_check : LucideIcons.shield_alert,
            color: isEnabled ? scheme.primary : scheme.error,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnabled ? 'Akses notifikasi aktif' : 'Akses notifikasi belum aktif',
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  isEnabled
                      ? 'Aplikasi dapat membaca notifikasi dari dompet yang kamu petakan.'
                      : 'Aktifkan akses notifikasi agar transaksi dapat terdeteksi otomatis.',
                  style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
              ],
            ),
          ),
          if (!isEnabled)
            FilledButton(
              onPressed: onActivate,
              child: const Text('Aktifkan'),
            ),
        ],
      ),
    );
  }
}

class _MappingCard extends StatelessWidget {
  const _MappingCard({
    required this.mapping,
    required this.walletName,
    required this.walletColor,
    required this.onToggle,
    required this.onDelete,
  });

  final BankNotificationMapping mapping;
  final String walletName;
  final Color? walletColor;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Slidable(
      key: ValueKey('bank_mapping_${mapping.id}'),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.22,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
            icon: LucideIcons.trash,
            label: 'Hapus',
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
        ],
      ),
      child: AppCard(
        child: Row(
          children: [
            IconBadge(icon: LucideIcons.landmark, color: walletColor ?? scheme.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mapping.appLabel,
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(LucideIcons.wallet, size: 12, color: scheme.outline),
                      const SizedBox(width: 4),
                      Text(
                        walletName,
                        style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Switch(value: mapping.isEnabled, onChanged: onToggle),
          ],
        ),
      ),
    );
  }
}
