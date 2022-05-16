import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransitionScreen {
  static CustomTransitionPage<void> createFade(
    BuildContext context,
    GoRouterState state,
    page,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      fullscreenDialog: true,
      child: page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
