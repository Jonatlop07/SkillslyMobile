import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/features/auth/presentation/sign_in/sign_in_screen.dart';

import 'not_found_screen.dart';
import 'route_paths.dart';
import 'routes.dart';

import 'package:skillsly_ma/src/core/services/auth_service.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  return GoRouter(
    initialLocation: Routes.signIn,
    debugLogDiagnostics: false,
    redirect: (state) {
      final isLoggedIn = authService.currentUser != null;
      if (isLoggedIn) {
        if (state.location == Routes.signIn) {
          return RoutePaths.feed;
        }
      } else if (state.location != RoutePaths.signIn &&
          state.location != RoutePaths.signUp &&
          state.location != RoutePaths.passwordRecovery &&
          state.location != RoutePaths.passwordReset) {
        return RoutePaths.signIn;
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authService.authStateChanges()),
    routes: [
      GoRoute(
        path: RoutePaths.auth,
        name: Routes.auth,
        builder: (context, state) => const SignInScreen(),
        routes: [
          GoRoute(
            path: Routes.signIn,
            name: Routes.signIn,
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              fullscreenDialog: true,
              child: const SignInScreen(),
            ),
          ),
        ],
      ),

      //GoRoute(path: RoutePaths.account, name: Routes.account),
      //GoRoute(path: RoutePaths.feed, name: Routes.feed)
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});
