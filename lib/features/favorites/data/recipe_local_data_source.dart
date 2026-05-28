import 'package:hive/hive.dart';

import '../../../core/constants/storage_keys.dart';
import '../../recipes/models/recipe.dart';

class RecipeLocalDataSource {
  RecipeLocalDataSource({
    Box<dynamic>? favoritesBox,
    Box<dynamic>? viewedRecipesBox,
  }) : _favoritesBox =
           favoritesBox ?? Hive.box<dynamic>(StorageKeys.favoritesBox),
       _viewedRecipesBox =
           viewedRecipesBox ?? Hive.box<dynamic>(StorageKeys.viewedRecipesBox);

  final Box<dynamic> _favoritesBox;
  final Box<dynamic> _viewedRecipesBox;

  List<Recipe> getFavorites() {
    return _favoritesBox.values
        .whereType<Map<dynamic, dynamic>>()
        .map(Recipe.fromLocalJson)
        .where((recipe) => recipe.id.isNotEmpty)
        .toList(growable: false)
        .reversed
        .toList(growable: false);
  }

  bool isFavorite(String recipeId) {
    return _favoritesBox.containsKey(recipeId);
  }

  Future<void> saveFavorite(Recipe recipe) {
    return _favoritesBox.put(recipe.id, recipe.toLocalJson());
  }

  Future<void> removeFavorite(String recipeId) {
    return _favoritesBox.delete(recipeId);
  }

  Future<void> cacheViewedRecipe(Recipe recipe) {
    return _viewedRecipesBox.put(recipe.id, recipe.toLocalJson());
  }

  Recipe? getViewedRecipe(String recipeId) {
    final value = _viewedRecipesBox.get(recipeId);
    if (value is! Map<dynamic, dynamic>) {
      return null;
    }

    final recipe = Recipe.fromLocalJson(value);
    if (recipe.id.isEmpty) {
      return null;
    }

    return recipe;
  }
}
