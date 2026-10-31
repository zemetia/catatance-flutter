import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../accounts/presentation/account_providers.dart';
import '../kalender_cashflow_providers.dart';

/// Horizontal "Semua dompet" / per-wallet chips filtering the whole
/// "Kalender Cashflow" screen, and pre-selecting that wallet when a
/// transaction is added from a calendar day.
class CashflowWalletFilter extends ConsumerWidget {
  const CashflowWalletFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountListProvider).value ?? const [];
    final selectedId = ref.watch(kalenderWalletFilterProvider);

    if (accounts.length < 2) return const SizedBox.shrink();

    void select(int? id) =>
        ref.read(kalenderWalletFilterProvider.notifier).state = id;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ChoiceChip(
            label: const Text('Semua dompet'),
            selected: selectedId == null,
            onSelected: (_) => select(null),
          ),
          for (final account in accounts) ...[
            const SizedBox(width: AppSpacing.sm),
            ChoiceChip(
              label: Text(account.name),
              selected: selectedId == account.id,
              onSelected: (_) => select(account.id),
            ),
          ],
        ],
      ),
    );
  }
}
