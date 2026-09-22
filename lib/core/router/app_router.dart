import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_shell.dart';
import '../../features/budget/presentation/budget_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/reports/presentation/kalender_cashflow_screen.dart';
import '../../features/reports/presentation/laporan_bulanan_screen.dart';
import '../../features/reports/presentation/proyeksi_screen.dart';
import '../../features/reports/presentation/radar_harga_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/transactions/presentation/add_transaction_screen.dart';
import '../../features/transactions/presentation/transaction_list_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (_, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/transactions',
            name: 'transactions',
            builder: (_, _) => const TransactionListScreen(),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (_, _) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/budget',
            name: 'budget',
            builder: (_, _) => const BudgetScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (_, _) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/transactions/add',
        name: 'transaction-add',
        builder: (_, _) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/reports/proyeksi',
        name: 'reports-proyeksi',
        builder: (_, _) => const ProyeksiScreen(),
      ),
      GoRoute(
        path: '/reports/laporan-bulanan',
        name: 'reports-laporan-bulanan',
        builder: (_, _) => const LaporanBulananScreen(),
      ),
      GoRoute(
        path: '/reports/radar-harga',
        name: 'reports-radar-harga',
        builder: (_, _) => const RadarHargaScreen(),
      ),
      GoRoute(
        path: '/reports/kalender-cashflow',
        name: 'reports-kalender-cashflow',
        builder: (_, _) => const KalenderCashflowScreen(),
      ),
    ],
  );
});
