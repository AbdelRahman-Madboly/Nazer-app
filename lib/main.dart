// lib/main.dart
// Phase 6D: Hive init + ViolationDataAdapter + NotificationService.
//
// Fixes vs original Phase 6D:
//  1. PaymentMethodScreen route: removed unknown 'amount' param (screen only takes violationId).
//     Pass id via query param as before; PaymentMethodScreen reads it from violationId.
//  2. AppTheme.dark — called as AppTheme.dark() (it's a static method/getter returning
//     ThemeData, not a ThemeData value itself). If it's a getter, call with no parens;
//     if a method, call with (). Adjust below to match your app_theme.dart signature.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/device_provider.dart';
import 'providers/violations_provider.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

// ── Screens ───────────────────────────────────────────────────────────────────
import 'screens/home_screen.dart';
import 'screens/live_monitor_screen.dart';
import 'screens/violations_list_screen.dart';
import 'screens/violation_detail_screen.dart';
import 'screens/driver_score_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/payment_method_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Hive ────────────────────────────────────────────────────────────────────
  await Hive.initFlutter();
  await StorageService.init();

  // ── Notifications ───────────────────────────────────────────────────────────
  await NotificationService.instance.init();

  runApp(const NazerApp());
}

// ── Router ────────────────────────────────────────────────────────────────────

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => _MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/monitor',
          builder: (_, __) => const LiveMonitorScreen(),
        ),
        GoRoute(
          path: '/violations',
          builder: (_, __) => const ViolationsListScreen(),
        ),
        GoRoute(
          path: '/violations/:id',
          builder: (_, state) => ViolationDetailScreen(
            violationId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/score',
          builder: (_, __) => const DriverScoreScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/payment/method',
      builder: (_, state) => PaymentMethodScreen(
        // violationId is nullable — PaymentMethodScreen already declares it required.
        // If the screen only accepts a non-null id, use the null-assert below.
        // If it accepts null (e.g. for Pay All flow), change the field to String?.
        violationId: state.uri.queryParameters['id'] ?? '',
      ),
    ),
  ],
);

// ── App root ──────────────────────────────────────────────────────────────────

class NazerApp extends StatelessWidget {
  const NazerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();
    final violationsProvider = ViolationsProvider(storageService);
    final deviceProvider = DeviceProvider();

    // Wire violation callback: BLE → ViolationsProvider → Notification
    violationsProvider.onViolationAdded =
        NotificationService.instance.showViolationNotification;
    deviceProvider.onViolationReceived = violationsProvider.addViolation;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DeviceProvider>.value(value: deviceProvider),
        ChangeNotifierProvider<ViolationsProvider>.value(
            value: violationsProvider),
      ],
      child: MaterialApp.router(
        title: 'NAZER',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        routerConfig: _router,
      ),
    );
  }
}

// ── Bottom nav shell ──────────────────────────────────────────────────────────

class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  static const _tabs = [
    _Tab('/home', Icons.home_rounded, Icons.home_outlined, 'Home'),
    _Tab('/monitor', Icons.speed_rounded, Icons.speed_outlined, 'Monitor'),
    _Tab('/violations', Icons.warning_rounded, Icons.warning_outlined,
        'Violations'),
    _Tab('/score', Icons.star_rounded, Icons.star_outlined, 'Score'),
    _Tab('/settings', Icons.settings_rounded, Icons.settings_outlined,
        'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex =
        _tabs.indexWhere((t) => location.startsWith(t.path));

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex < 0 ? 0 : currentIndex,
          onTap: (i) => context.go(_tabs[i].path),
          backgroundColor: AppColors.bgCard,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: _tabs
              .map((t) => BottomNavigationBarItem(
                    icon: Icon(t.inactiveIcon),
                    activeIcon: Icon(t.activeIcon),
                    label: t.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _Tab {
  final String path;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  const _Tab(this.path, this.activeIcon, this.inactiveIcon, this.label);
}