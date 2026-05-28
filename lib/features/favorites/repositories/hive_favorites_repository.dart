import '../data/recipe_local_data_source.dart';
import '../../recipes/models/recipe.dart';
import 'favorites_repository.dart';

class HiveFavoritesRepository implements FavoritesRepository {
  const HiveFavoritesRepository(this._localDataSource);

  final RecipeLocalDataSource _localDataSource;

  @override
  List<Recipe> getFavorites() {
    return _localDataSource.getFavorites();
  }

  @override
  bool isFavorite(String recipeId) {
    return _localDataSource.isFavorite(recipeId);
  }

  @override
  Future<void> saveFavorite(Recipe recipe) {
    return _localDataSource.saveFavorite(recipe);
  }

  @override
  Future<void> removeFavorite(String recipeId) {
    return _localDataSource.removeFavorite(recipeId);
  }

  @override
  Future<void> cacheViewedRecipe(Recipe recipe) {
    return _localDataSource.cacheViewedRecipe(recipe);
  }

  @override
  Recipe? getViewedRecipe(String recipeId) {
    return _localDataSource.getViewedRecipe(recipeId);
  }
}
