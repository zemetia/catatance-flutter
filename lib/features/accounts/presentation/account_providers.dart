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
