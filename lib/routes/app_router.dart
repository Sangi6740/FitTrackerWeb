import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../screens/main_layout.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/daily_tracker/daily_tracker_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/auth/auth_screen.dart';

// Stream to listen to auth changes for router updates
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final dynamic _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isGoingToAuth = state.matchedLocation == '/auth';

    if (user == null && !isGoingToAuth) {
      return '/auth';
    }
    if (user != null && isGoingToAuth) {
      return '/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/tracker',
          builder: (context, state) => const DailyTrackerScreen(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
      ],
    ),
  ],
);
