import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_shell.dart';
import '../../features/accounts/presentation/wallet_form_screen.dart';
import '../../features/badges/presentation/badges_screen.dart';
import '../../features/bank_notifications/presentation/bank_app_picker_screen.dart';
import '../../features/bank_notifications/presentation/bank_notification_review_screen.dart';
import '../../features/bank_notifications/presentation/bank_notification_settings_screen.dart';
import '../../features/accounts/presentation/wallet_list_screen.dart';
import '../../features/accounts/presentation/wallet_transfer_screen.dart';
import '../../features/budget/presentation/budget_form_screen.dart';
import '../../features/budget/presentation/budget_list_screen.dart';
import '../../features/budget/presentation/budget_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/debts/presentation/debt_detail_screen.dart';
import '../../features/debts/presentation/debt_form_screen.dart';
import '../../features/debts/presentation/debt_list_screen.dart';
import '../../features/installments/presentation/installment_detail_screen.dart';
import '../../features/installments/presentation/installment_form_screen.dart';
import '../../features/installments/presentation/installment_list_screen.dart';
import '../../features/profile/presentation/about_screen.dart';
import '../../features/profile/presentation/account_screen.dart';
import '../../features/profile/presentation/feedback_screen.dart';
import '../../features/profile/presentation/help_screen.dart';
import '../../features/profile/presentation/home_widgets_screen.dart';
import '../../features/profile/presentation/language_screen.dart';
import '../../features/profile/presentation/notifications_screen.dart';
import '../../features/profile/presentation/pin_change_screen.dart';
import '../../features/profile/presentation/pin_setup_screen.dart';
import '../../features/profile/presentation/preferences_screen.dart';
import '../../features/profile/presentation/privacy_policy_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/security_screen.dart';
import '../../features/profile/presentation/widgets/pin_confirm_screen.dart';
import '../../features/profile/presentation/terms_screen.dart';
import '../../features/profile/presentation/theme_settings_screen.dart';
import '../../features/reports/presentation/kalender_cashflow_screen.dart';
import '../../features/reports/presentation/laporan_bulanan_screen.dart';
import '../../features/reports/presentation/proyeksi_screen.dart';
import '../../features/reports/presentation/purchase_simulator_screen.dart';
import '../../features/reports/presentation/radar_harga_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/savings_goals/presentation/savings_goal_detail_screen.dart';
import '../../features/savings_goals/presentation/savings_goal_form_screen.dart';
import '../../features/savings_goals/presentation/savings_goal_list_screen.dart';
import '../../features/split_bills/presentation/split_bill_form_screen.dart';
import '../../features/transactions/presentation/add_transaction_screen.dart';
import '../../features/transactions/presentation/batch_transaction_screen.dart';
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
        path: '/transactions/batch',
        name: 'transaction-batch',
        builder: (_, _) => const BatchTransactionScreen(),
      ),
      GoRoute(
        path: '/split-bills/new',
        name: 'split-bill-new',
        builder: (_, state) {
          final args = state.extra! as SplitBillFormArgs;
          return SplitBillFormScreen(args: args);
        },
      ),
      GoRoute(
        path: '/badges',
        name: 'badges',
        builder: (_, _) => const BadgesScreen(),
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
        path: '/wallets/:id/edit',
        name: 'wallet-edit',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return WalletFormScreen(accountId: id);
        },
      ),
      GoRoute(
        path: '/budget/all',
        name: 'budget-all',
        builder: (_, _) => const BudgetListScreen(),
      ),
      GoRoute(
        path: '/budget/new',
        name: 'budget-new',
        builder: (_, state) {
          final categoryId = state.uri.queryParameters['categoryId'];
          return BudgetFormScreen(
            initialCategoryId: categoryId != null ? int.tryParse(categoryId) : null,
          );
        },
      ),
      GoRoute(
        path: '/budget/:id/edit',
        name: 'budget-edit',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return BudgetFormScreen(budgetId: id);
        },
      ),
      GoRoute(
        path: '/savings-goals',
        name: 'savings-goals',
        builder: (_, _) => const SavingsGoalListScreen(),
      ),
      GoRoute(
        path: '/savings-goals/new',
        name: 'savings-goal-new',
        builder: (_, state) {
          final query = state.uri.queryParameters;
          return SavingsGoalFormScreen(
            initialName: query['name'],
            initialIconKey: query['icon'],
            initialGradientIndex: int.tryParse(query['gradient'] ?? ''),
            initialTargetAmountCents: int.tryParse(query['target'] ?? ''),
            initialTargetDate: query['date'] != null
                ? DateTime.tryParse(query['date']!)
                : null,
          );
        },
      ),
      GoRoute(
        path: '/savings-goals/:id',
        name: 'savings-goal-detail',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return SavingsGoalDetailScreen(goalId: id);
        },
      ),
      GoRoute(
        path: '/savings-goals/:id/edit',
        name: 'savings-goal-edit',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return SavingsGoalFormScreen(goalId: id);
        },
      ),
      GoRoute(
        path: '/debts',
        name: 'debts',
        builder: (_, _) => const DebtListScreen(),
      ),
      GoRoute(
        path: '/debts/new',
        name: 'debt-new',
        builder: (_, _) => const DebtFormScreen(),
      ),
      GoRoute(
        path: '/debts/:id',
        name: 'debt-detail',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return DebtDetailScreen(debtId: id);
        },
      ),
      GoRoute(
        path: '/debts/:id/edit',
        name: 'debt-edit',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return DebtFormScreen(debtId: id);
        },
      ),
      GoRoute(
        path: '/installments',
        name: 'installments',
        builder: (_, _) => const InstallmentListScreen(),
      ),
      GoRoute(
        path: '/installments/new',
        name: 'installment-new',
        builder: (_, _) => const InstallmentFormScreen(),
      ),
      GoRoute(
        path: '/installments/:id',
        name: 'installment-detail',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return InstallmentDetailScreen(installmentId: id);
        },
      ),
      GoRoute(
        path: '/installments/:id/edit',
        name: 'installment-edit',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return InstallmentFormScreen(installmentId: id);
        },
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
        path: '/profile/security/pin-setup',
        name: 'profile-security-pin-setup',
        builder: (_, _) => const PinSetupScreen(),
      ),
      GoRoute(
        path: '/profile/security/pin-change',
        name: 'profile-security-pin-change',
        builder: (_, _) => const PinChangeScreen(),
      ),
      GoRoute(
        path: '/profile/security/pin-confirm',
        name: 'profile-security-pin-confirm',
        builder: (_, state) {
          final args = state.extra! as PinConfirmArgs;
          return PinConfirmScreen(title: args.title, subtitle: args.subtitle);
        },
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
        path: '/profile/widgets',
        name: 'profile-widgets',
        builder: (_, _) => const HomeWidgetsScreen(),
      ),
      GoRoute(
        path: '/profile/bank-notifications',
        name: 'profile-bank-notifications',
        builder: (_, _) => const BankNotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/bank-notifications/pick-app',
        name: 'bank-notifications-pick-app',
        builder: (_, _) => const BankAppPickerScreen(),
      ),
      GoRoute(
        path: '/bank-notifications/review',
        name: 'bank-notifications-review',
        builder: (_, _) => const BankNotificationReviewScreen(),
      ),
      GoRoute(
        path: '/reports/proyeksi',
        name: 'reports-proyeksi',
        builder: (_, _) => const ProyeksiScreen(),
      ),
      GoRoute(
        path: '/reports/proyeksi/simulasi',
        name: 'reports-proyeksi-simulasi',
        builder: (_, _) => const PurchaseSimulatorScreen(),
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
