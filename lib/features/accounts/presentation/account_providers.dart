import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart' hide Account;
import '../data/account_repository.dart';
import '../domain/account.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(appDatabaseProvider));
});

/// Live list of wallets/accounts, updates whenever the `Accounts` table changes.
final accountListProvider = StreamProvider.autoDispose<List<Account>>((ref) {
  return ref.watch(accountRepositoryProvider).watchAll();
});

/// Sum of every account's balance, derived from [accountListProvider].
final totalBalanceProvider = Provider.autoDispose<int>((ref) {
  final accounts = ref.watch(accountListProvider).value ?? const [];
  return accounts.fold(0, (sum, account) => sum + account.balanceCents);
});

/// Creates a new wallet, or moves a balance between two existing wallets.
class WalletActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createWallet(AccountDraft draft) async {
    state = const AsyncLoading();
    final repo = ref.read(accountRepositoryProvider);
    state = await AsyncValue.guard(() => repo.insert(draft));
  }

  Future<void> transfer({
    required int fromId,
    required int toId,
    required int amountCents,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(accountRepositoryProvider);
    state = await AsyncValue.guard(
      () => repo.transfer(fromId: fromId, toId: toId, amountCents: amountCents),
    );
  }

  Future<void> deleteWallet(int id) async {
    state = const AsyncLoading();
    final repo = ref.read(accountRepositoryProvider);
    state = await AsyncValue.guard(() => repo.delete(id));
  }
}

final walletActionProvider =
    AsyncNotifierProvider.autoDispose<WalletActionNotifier, void>(
      WalletActionNotifier.new,
    );
