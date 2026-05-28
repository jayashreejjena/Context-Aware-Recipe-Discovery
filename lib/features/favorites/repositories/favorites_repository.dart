import '../../recipes/models/recipe.dart';

abstract class FavoritesRepository {
  List<Recipe> getFavorites();

  bool isFavorite(String recipeId);

  Future<void> saveFavorite(Recipe recipe);

  Future<void> removeFavorite(String recipeId);

  Future<void> cacheViewedRecipe(Recipe recipe);

  Recipe? getViewedRecipe(String recipeId);
}
