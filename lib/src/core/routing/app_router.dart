import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/core/routing/main_drawer.dart';
import 'package:skillsly_ma/src/core/routing/route_paths.dart';
import 'package:skillsly_ma/src/core/routing/transition_screen.dart';
import 'package:skillsly_ma/src/features/authentication/data/auth_service.dart';
import 'package:skillsly_ma/src/features/authentication/presentation/sign_in/sign_in_screen.dart';
import 'package:skillsly_ma/src/features/authentication/presentation/sign_in/sign_in_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/features/authentication/presentation/sign_up/sign_up_screen.dart';
import 'package:skillsly_ma/src/features/authentication/presentation/sign_up/sign_up_state.dart';

import 'not_found_screen.dart';
import 'routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  return GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: false,
    redirect: (state) {
      final isLoggedIn = authService.isLoggedIn();
      final isLoggingIn = state.subloc == RoutePaths.signIn || state.subloc == RoutePaths.signUp;
      if (!isLoggedIn) return isLoggingIn ? null : RoutePaths.signIn;
      if (isLoggingIn) return RoutePaths.feed;
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authService.authStateChanges()),
    routes: [
      GoRoute(
        path: RoutePaths.home,
        name: Routes.home,
        builder: (context, state) => const NotFoundScreen(),
        routes: [
          GoRoute(
            path: Routes.signIn,
            name: Routes.signIn,
            pageBuilder: (context, state) => TransitionScreen.createFade(
              context,
              state,
              const SignInScreen(
                formType: SignInFormType.signIn,
              ),
            ),
          ),
          GoRoute(
            path: Routes.signUp,
            name: Routes.signUp,
            pageBuilder: (context, state) => TransitionScreen.createFade(
                context,
                state,
                const SignUpScreen(
                  formType: SignUpFormType.signUp,
                )),
          ),
          GoRoute(
            path: Routes.feed,
            name: Routes.feed,
            pageBuilder: (context, state) => TransitionScreen.createFade(
              context,
              state,
              Scaffold(
                appBar: AppBar(title: Text('Feed'.hardcoded)),
                drawer: const MainDrawer(),
              ),
            ),
          ),
          GoRoute(
            path: Routes.chat,
            name: Routes.chat,
            pageBuilder: (context, state) => TransitionScreen.createFade(
              context,
              state,
              Scaffold(
                appBar: AppBar(title: Text('Chat'.hardcoded)),
                drawer: const MainDrawer(),
              ),
            ),
          ),
          GoRoute(
            path: Routes.account,
            name: Routes.account,
            pageBuilder: (context, state) => TransitionScreen.createFade(
              context,
              state,
              Scaffold(
                appBar: AppBar(title: Text('Mi cuenta'.hardcoded)),
                drawer: const MainDrawer(),
              ),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});
