import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../presentation/catalog/breeds_screen.dart';
import '../presentation/detail/breed_detail_screen.dart';
import 'app_routes.dart';
import 'splash_screen.dart';

part 'app_router.g.dart';

/// The application router.
///
/// Routing is injected like any other dependency: the app reads it from
/// Riverpod, and each provider container in a test gets its own instance
/// instead of sharing global mutable state. It lives as long as the
/// application, so it is never disposed while routes are in use.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) => GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.breeds,
      builder: (context, state) => const BreedsScreen(),
    ),
    GoRoute(
      path: AppRoutes.breedDetail,
      builder: (context, state) => BreedDetailScreen(
        breedId: state.pathParameters[AppRoutes.breedIdParameter]!,
      ),
    ),
  ],
);
