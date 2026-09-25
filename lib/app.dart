import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/services/home_widget_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_providers.dart';
import 'core/widgets/app_lock/app_lock_gate.dart';
import 'features/bank_notifications/presentation/widgets/bank_notification_sync_observer.dart';
import 'features/profile/presentation/backup_providers.dart';
import 'features/profile/presentation/home_widgets_providers.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initHomeWidgetNavigation();
      ref.read(backupScreenProvider.notifier).runAutoBackupIfDue();
    });
  }

  Future<void> _initHomeWidgetNavigation() async {
    final service = ref.read(homeWidgetServiceProvider);
    final router = ref.read(appRouterProvider);

    service.initNavigationListener((route) {
      router.push(route);
    });

    final initialRoute = await service.getInitialRoute();
    if (initialRoute != null && initialRoute.isNotEmpty) {
      router.push(initialRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep homescreen widget synced with latest balance & settings
    ref.watch(homeWidgetSyncProvider);

    final router = ref.watch(appRouterProvider);
    final themeSettings = ref.watch(themeSettingsProvider);

    return MaterialApp.router(
      title: 'Catatance',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(themeSettings.colorTheme),
      darkTheme: buildDarkTheme(themeSettings.colorTheme),
      themeMode: themeSettings.themeMode,
      routerConfig: router,
      builder: (context, child) => BankNotificationSyncObserver(
        child: AppLockGate(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
