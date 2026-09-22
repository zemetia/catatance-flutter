import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../data/account_repository.dart';
import '../domain/account.dart';
import 'account_providers.dart';
import 'widgets/amount_keypad.dart';

/// "Dompet baru" — create a new wallet/account.
class WalletFormScreen extends HookConsumerWidget {
  const WalletFormScreen({super.key});

  static const _types = [
    AccountType.bank,
    AccountType.eWallet,
    AccountType.cash,
    AccountType.card,
    AccountType.savings,
    AccountType.other,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final amountDigits = useState('');
    final nameController = useTextEditingController();
    final name = useValueListenable(nameController);
    final selectedType = useState(AccountType.bank);
    final selectedColor = useState(AppColors.walletPalette.first);
    final isDefault = useState(false);
    final amountEntryOpen = useState(false);

    final actionState = ref.watch(walletActionProvider);
    final canSubmit =
        name.text.trim().isNotEmpty && actionState is! AsyncLoading;
    final amount =
        int.tryParse(amountDigits.value.isEmpty ? '0' : amountDigits.value) ??
        0;

    Future<void> submit() async {
      final notifier = ref.read(walletActionProvider.notifier);
      await notifier.createWallet(
        AccountDraft(
          name: name.text.trim(),
          type: selectedType.value,
          initialBalanceCents: amount,
          colorValue: selectedColor.value.toARGB32(),
          isDefault: isDefault.value,
        ),
      );
      if (context.mounted && ref.read(walletActionProvider).hasError == false) {
        context.pop();
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        title: const Text('Dompet baru'),
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
            _SaldoAwalCard(
              amountCents: amount,
              expanded: amountEntryOpen.value,
              onTap: () => amountEntryOpen.value = !amountEntryOpen.value,
            ),
            if (amountEntryOpen.value) ...[
              const SizedBox(height: AppSpacing.md),
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
            ],
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama dompet',
                hintText: 'cth: BCA Utama',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _StaticField(
              icon: LucideIcons.repeat,
              label: 'Mata uang',
              value: 'IDR · Rp',
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Laporan & total dikonversi ke mata uang utama pakai kurs harian.',
              style: textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tipe dompet',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.15,
              children: [
                for (final type in _types)
                  _TypeOption(
                    type: type,
                    selected: type == selectedType.value,
                    onTap: () => selectedType.value = type,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  'Warna',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final color in AppColors.walletPalette)
                  _ColorSwatch(
                    color: color,
                    selected:
                        color.toARGB32() == selectedColor.value.toARGB32(),
                    onTap: () => selectedColor.value = color,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: isDefault.value,
              onChanged: (value) => isDefault.value = value,
              title: const Text('Jadikan default'),
              subtitle: const Text('Dipakai di Home & transaksi baru'),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: canSubmit ? submit : null,
              child: actionState is AsyncLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Buat dompet'),
                        SizedBox(width: AppSpacing.xs),
                        Icon(LucideIcons.arrow_right, size: 18),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaldoAwalCard extends StatelessWidget {
  const _SaldoAwalCard({
    required this.amountCents,
    required this.expanded,
    required this.onTap,
  });

  final int amountCents;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          child: Column(
            children: [
              Text(
                'Saldo awal',
                style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                formatRupiah(amountCents),
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Saldo mulai dompet ini',
                style: textTheme.bodySmall?.copyWith(color: scheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticField extends StatelessWidget {
  const _StaticField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.outline),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevrons_up_down, size: 18, color: scheme.outline),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final AccountType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = selected ? scheme.primary : scheme.outline;

    return Material(
      color: selected
          ? scheme.primary.withValues(alpha: 0.12)
          : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(type.icon, color: color),
              const SizedBox(height: AppSpacing.xs),
              Text(
                type.label,
                style: textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
        child: selected
            ? const Icon(LucideIcons.check, color: Colors.black, size: 18)
            : null,
      ),
    );
  }
}
