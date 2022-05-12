import 'package:skillsly_ma/src/core/routing/route_paths.dart';
import 'package:skillsly_ma/src/features/authentication/data/auth_service.dart';
import 'package:skillsly_ma/src/features/authentication/presentation/sign_in/sign_in_screen.dart';
import 'package:skillsly_ma/src/features/authentication/presentation/sign_in/sign_in_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'not_found_screen.dart';
import 'routes.dart';

enum AppRoute {
  home,
  product,
  leaveReview,
  cart,
  checkout,
  orders,
  account,
  signIn,
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  return GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: false,
    redirect: (state) {
      final isLoggedIn = authService.currentUser != null;
      if (isLoggedIn) {
        if (state.location == RoutePaths.signIn) {
          return RoutePaths.home;
        }
      } else {
        if (state.location == RoutePaths.account) {
          return RoutePaths.home;
        }
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authService.authStateChanges()),
    routes: [
      GoRoute(
        path: RoutePaths.home,
        name: AppRoute.home.name,
        builder: (context, state) => const NotFoundScreen(),
        routes: [
          GoRoute(
            path: Routes.signIn,
            name: Routes.signIn,
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              fullscreenDialog: true,
              child: const SignInScreen(
                formType: SignInFormType.signIn,
              ),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});
