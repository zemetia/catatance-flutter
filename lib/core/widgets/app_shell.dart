import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';

import 'floating_nav_bar/floating_nav_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const _tabs = [
    _ShellTab(
      path: '/',
      item: FloatingNavItem(
        icon: LucideIcons.house,
        activeIcon: LucideIcons.house,
        label: 'Beranda',
      ),
    ),
    _ShellTab(
      path: '/reports',
      item: FloatingNavItem(
        icon: LucideIcons.chart_spline,
        activeIcon: LucideIcons.chart_spline,
        label: 'Statistik',
      ),
    ),
    _ShellTab(
      path: '/budget',
      item: FloatingNavItem(
        icon: LucideIcons.wallet,
        activeIcon: LucideIcons.wallet,
        label: 'Anggaran',
      ),
    ),
    _ShellTab(
      path: '/profile',
      item: FloatingNavItem(
        icon: LucideIcons.circle_user_round,
        activeIcon: LucideIcons.circle_user_round,
        label: 'Profil',
      ),
    ),
  ];

  int _indexForLocation(String location) {
    final index = _tabs.indexWhere((tab) => tab.path == location);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: FloatingNavBar(
        items: [for (final tab in _tabs) tab.item],
        currentIndex: currentIndex,
        onItemSelected: (index) => context.go(_tabs[index].path),
        onCenterActionPressed: () => context.push('/transactions/add'),
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab({required this.path, required this.item});

  final String path;
  final FloatingNavItem item;
}
