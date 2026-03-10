import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namora/core/routing/route_names.dart';
import 'package:namora/features/splash/splash_screen.dart';
import 'package:namora/features/onboarding/onboarding_screen.dart';
import 'package:namora/features/shell/app_shell.dart';
import 'package:namora/features/legal/privacy_policy_screen.dart';
import 'package:namora/features/legal/terms_conditions_screen.dart';
import 'package:namora/features/statistics/view/statistics_screen.dart';
import 'package:namora/features/comparison/view/comparison_screen.dart';
import 'package:namora/features/favorites/view/name_detail_screen.dart';
import 'package:namora/models/favorite_model.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splashName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: RouteNames.onboardingName,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.swipe,
        name: RouteNames.swipeName,
        builder: (context, state) => const AppShell(),
      ),
      GoRoute(
        path: RouteNames.privacyPolicy,
        name: RouteNames.privacyPolicyName,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: RouteNames.termsConditions,
        name: RouteNames.termsConditionsName,
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: RouteNames.statistics,
        name: RouteNames.statisticsName,
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: RouteNames.comparison,
        name: RouteNames.comparisonName,
        builder: (context, state) => const ComparisonScreen(),
      ),
      GoRoute(
        path: RouteNames.nameDetail,
        name: RouteNames.nameDetailName,
        builder: (context, state) {
          final fav = state.extra;
          if (fav is! FavoriteModel) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Name not found'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go(RouteNames.swipe),
                      child: const Text('Go Home'),
                    ),
                  ],
                ),
              ),
            );
          }
          return NameDetailScreen(favorite: fav);
        },
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page not found', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.swipe),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
