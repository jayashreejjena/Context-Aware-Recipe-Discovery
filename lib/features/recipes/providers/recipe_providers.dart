import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../favorites/providers/favorites_providers.dart';
import '../data/meal_db_api_service.dart';
import '../models/meal_category.dart';
import '../models/recipe.dart';
import '../repositories/meal_db_recipe_repository.dart';
import '../repositories/recipe_repository.dart';

final mealDbApiServiceProvider = Provider<MealDbApiService>((ref) {
  return MealDbApiService(ref.watch(dioProvider));
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return MealDbRecipeRepository(ref.watch(mealDbApiServiceProvider));
});

final recipeSearchProvider = FutureProvider.autoDispose
    .family<List<Recipe>, String>((ref, query) {
      final normalizedQuery = query.trim();
      if (normalizedQuery.isEmpty) {
        return const <Recipe>[];
      }

      return ref.watch(recipeRepositoryProvider).searchRecipes(normalizedQuery);
    });

final areaRecipesProvider = FutureProvider.autoDispose
    .family<List<Recipe>, String>((ref, area) {
      final normalizedArea = area.trim();
      if (normalizedArea.isEmpty) {
        return const <Recipe>[];
      }

      return ref
          .watch(recipeRepositoryProvider)
          .fetchRecipesByArea(normalizedArea);
    });

final recipeDetailsProvider = FutureProvider.autoDispose.family<Recipe, String>(
  (ref, id) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError('Recipe id is required.');
    }

    return _fetchRecipeDetails(ref, normalizedId);
  },
);

Future<Recipe> _fetchRecipeDetails(Ref ref, String recipeId) async {
  final favoritesRepository = ref.watch(favoritesRepositoryProvider);

  try {
    final recipe = await ref
        .watch(recipeRepositoryProvider)
        .fetchRecipeById(recipeId);
    await favoritesRepository.cacheViewedRecipe(recipe);
    ref.invalidate(viewedRecipeProvider(recipeId));
    return recipe;
  } catch (_) {
    final cachedRecipe = favoritesRepository.getViewedRecipe(recipeId);
    if (cachedRecipe != null) {
      return cachedRecipe;
    }
    rethrow;
  }
}

final recipeCategoriesProvider = FutureProvider.autoDispose<List<MealCategory>>(
  (ref) {
    return ref.watch(recipeRepositoryProvider).fetchCategories();
  },
);

final initialRecipesProvider = FutureProvider.autoDispose<List<Recipe>>((ref) {
  return ref.watch(recipeRepositoryProvider).searchRecipes('');
});
