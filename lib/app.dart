import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_providers.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeSettings = ref.watch(themeSettingsProvider);

    return MaterialApp.router(
      title: 'Pencatatan Keuangan',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(themeSettings.colorTheme),
      darkTheme: buildDarkTheme(themeSettings.colorTheme),
      themeMode: themeSettings.themeMode,
      routerConfig: router,
    );
  }
}
