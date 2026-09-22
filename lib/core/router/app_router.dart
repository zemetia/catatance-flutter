import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_shell.dart';
import '../../features/accounts/presentation/wallet_form_screen.dart';
import '../../features/accounts/presentation/wallet_list_screen.dart';
import '../../features/accounts/presentation/wallet_transfer_screen.dart';
import '../../features/budget/presentation/budget_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/profile/presentation/about_screen.dart';
import '../../features/profile/presentation/account_screen.dart';
import '../../features/profile/presentation/feedback_screen.dart';
import '../../features/profile/presentation/help_screen.dart';
import '../../features/profile/presentation/language_screen.dart';
import '../../features/profile/presentation/notifications_screen.dart';
import '../../features/profile/presentation/preferences_screen.dart';
import '../../features/profile/presentation/privacy_policy_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/security_screen.dart';
import '../../features/profile/presentation/terms_screen.dart';
import '../../features/profile/presentation/theme_settings_screen.dart';
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
        path: '/wallets',
        name: 'wallets',
        builder: (_, _) => const WalletListScreen(),
      ),
      GoRoute(
        path: '/wallets/new',
        name: 'wallet-new',
        builder: (_, _) => const WalletFormScreen(),
      ),
      GoRoute(
        path: '/wallets/transfer',
        name: 'wallet-transfer',
        builder: (_, _) => const WalletTransferScreen(),
      ),
      GoRoute(
        path: '/settings/theme',
        name: 'settings-theme',
        builder: (_, _) => const ThemeSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/account',
        name: 'profile-account',
        builder: (_, _) => const AccountScreen(),
      ),
      GoRoute(
        path: '/profile/preferences',
        name: 'profile-preferences',
        builder: (_, _) => const PreferencesScreen(),
      ),
      GoRoute(
        path: '/profile/notifications',
        name: 'profile-notifications',
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile/security',
        name: 'profile-security',
        builder: (_, _) => const SecurityScreen(),
      ),
      GoRoute(
        path: '/profile/language',
        name: 'profile-language',
        builder: (_, _) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/profile/about',
        name: 'profile-about',
        builder: (_, _) => const AboutScreen(),
      ),
      GoRoute(
        path: '/profile/privacy-policy',
        name: 'profile-privacy-policy',
        builder: (_, _) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/profile/terms',
        name: 'profile-terms',
        builder: (_, _) => const TermsScreen(),
      ),
      GoRoute(
        path: '/profile/help',
        name: 'profile-help',
        builder: (_, _) => const HelpScreen(),
      ),
      GoRoute(
        path: '/profile/feedback',
        name: 'profile-feedback',
        builder: (_, _) => const FeedbackScreen(),
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
