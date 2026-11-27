import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/projects/presentation/screens/project_detail_screen.dart';
import '../constants/app_dimens.dart';
import '../constants/app_sections.dart';
import 'app_routes.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) {
          final name = state.uri.queryParameters['section'];
          final section = AppSection.values
              .where((s) => s.name == name)
              .firstOrNull;
          return _fadePage(state, HomeScreen(initialSection: section));
        },
        routes: [
          GoRoute(
            path: 'projects/:id',
            pageBuilder: (context, state) => _fadePage(
              state,
              ProjectDetailScreen(projectId: state.pathParameters['id']!),
            ),
          ),
        ],
      ),
    ],
    errorPageBuilder: (context, state) => _fadePage(state, const HomeScreen()),
  );
}

/// Fade + gentle rise. Skips the animation when reduced motion is requested.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.slow,
    reverseTransitionDuration: AppDurations.medium,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      final curved = animation.drive(CurveTween(curve: AppCurves.emphasized));
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
