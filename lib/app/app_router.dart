import 'package:go_router/go_router.dart';

import '../features/breeds/presentation/screens/breed_detail_screen.dart';
import '../features/breeds/presentation/screens/breeds_screen.dart';
import '../features/breeds/presentation/screens/splash_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/breeds', builder: (context, state) => const BreedsScreen()),
    GoRoute(
      path: '/breeds/:id',
      builder: (context, state) =>
          BreedDetailScreen(breedId: state.pathParameters['id']!),
    ),
  ],
);
