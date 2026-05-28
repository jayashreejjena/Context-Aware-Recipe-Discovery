import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../recipes/models/recipe.dart';
import '../../recipes/providers/recipe_providers.dart';
import '../models/location_cuisine_context.dart';
import '../services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

final locationCuisineContextProvider =
    FutureProvider.autoDispose<LocationCuisineContext>((ref) {
      return ref.watch(locationServiceProvider).getCuisineContext();
    });

final locationRecipesProvider = FutureProvider.autoDispose<List<Recipe>>((ref) {
  final contextAsync = ref.watch(locationCuisineContextProvider);

  return contextAsync.when(
    data: (context) {
      return ref
          .watch(recipeRepositoryProvider)
          .fetchRecipesByArea(context.cuisineArea);
    },
    loading: () => const <Recipe>[],
    error: (error, stackTrace) => const <Recipe>[],
  );
});
