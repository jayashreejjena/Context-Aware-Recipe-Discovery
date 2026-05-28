import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/favorites/favorites_screen.dart';
import '../../features/location/location_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/recipes/screens/home_screen.dart';
import '../../features/recipes/screens/recipe_details_placeholder_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: HomeScreen.routePath,
    routes: [
      GoRoute(
        path: HomeScreen.routePath,
        name: HomeScreen.routeName,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RecipeDetailsPlaceholderScreen.routePath,
        name: RecipeDetailsPlaceholderScreen.routeName,
        builder: (context, state) {
          final recipeId = state.pathParameters['id']!;
          return RecipeDetailsPlaceholderScreen(recipeId: recipeId);
        },
      ),
      GoRoute(
        path: FavoritesScreen.routePath,
        name: FavoritesScreen.routeName,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: NotificationsScreen.routePath,
        name: NotificationsScreen.routeName,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: LocationScreen.routePath,
        name: LocationScreen.routeName,
        builder: (context, state) => const LocationScreen(),
      ),
    ],
  );
});
