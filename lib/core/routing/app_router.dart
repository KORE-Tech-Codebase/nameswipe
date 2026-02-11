import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nameswipe/core/routing/route_names.dart';
import 'package:nameswipe/features/splash/splash_screen.dart';
import 'package:nameswipe/features/onboarding/onboarding_screen.dart';
import 'package:nameswipe/features/shell/app_shell.dart';
import 'package:nameswipe/features/legal/privacy_policy_screen.dart';
import 'package:nameswipe/features/legal/terms_conditions_screen.dart';

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
