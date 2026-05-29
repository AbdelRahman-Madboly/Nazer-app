import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/live_monitor_screen.dart';
import 'screens/violations_list_screen.dart';
import 'screens/violation_detail_screen.dart';
import 'screens/driver_score_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/payment_method_screen.dart';
import 'screens/payment_form_screen.dart';
import 'screens/payment_success_screen.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash',        builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/home',          builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/live',          builder: (_, __) => const LiveMonitorScreen()),
    GoRoute(path: '/violations',    builder: (_, __) => const ViolationsListScreen()),
    GoRoute(
      path: '/violations/:id',
      builder: (_, state) => ViolationDetailScreen(violationId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/score',         builder: (_, __) => const DriverScoreScreen()),
    GoRoute(path: '/settings',      builder: (_, __) => const SettingsScreen()),
    GoRoute(
      path: '/payment/method',
      builder: (_, state) => PaymentMethodScreen(violationId: state.uri.queryParameters['id'] ?? ''),
    ),
    GoRoute(
      path: '/payment/form',
      builder: (_, state) => PaymentFormScreen(
        violationId: state.uri.queryParameters['id'] ?? '',
        method: state.uri.queryParameters['method'] ?? '',
      ),
    ),
    GoRoute(
      path: '/payment/success',
      builder: (_, state) => PaymentSuccessScreen(violationId: state.uri.queryParameters['id'] ?? ''),
    ),
  ],
);

class NazerApp extends StatelessWidget {
  const NazerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NAZER',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: _router,
    );
  }
}
