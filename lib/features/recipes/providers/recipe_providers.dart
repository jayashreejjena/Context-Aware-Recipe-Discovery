import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
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

final recipeCategoriesProvider = FutureProvider.autoDispose<List<MealCategory>>(
  (ref) {
    return ref.watch(recipeRepositoryProvider).fetchCategories();
  },
);

final initialRecipesProvider = FutureProvider.autoDispose<List<Recipe>>((ref) {
  return ref.watch(recipeRepositoryProvider).searchRecipes('');
});
