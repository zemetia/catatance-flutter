import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction_item.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TransactionRepository(db);
});

final recentTransactionsProvider =
    StreamProvider.autoDispose<List<TransactionItem>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchRecent(limit: 50);
});

final dashboardRecentTransactionsProvider =
    StreamProvider.autoDispose<List<TransactionItem>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchRecent(limit: 5);
});
