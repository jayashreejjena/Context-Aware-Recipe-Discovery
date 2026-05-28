import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../recipes/models/recipe.dart';
import '../data/recipe_local_data_source.dart';
import '../repositories/favorites_repository.dart';
import '../repositories/hive_favorites_repository.dart';

final recipeLocalDataSourceProvider = Provider<RecipeLocalDataSource>((ref) {
  return RecipeLocalDataSource();
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return HiveFavoritesRepository(ref.watch(recipeLocalDataSourceProvider));
});

final favoriteRecipesProvider =
    NotifierProvider<FavoriteRecipesNotifier, List<Recipe>>(
      FavoriteRecipesNotifier.new,
    );

final viewedRecipeProvider = Provider.family<Recipe?, String>((ref, recipeId) {
  return ref.watch(favoritesRepositoryProvider).getViewedRecipe(recipeId);
});

class FavoriteRecipesNotifier extends Notifier<List<Recipe>> {
  @override
  List<Recipe> build() {
    return ref.watch(favoritesRepositoryProvider).getFavorites();
  }

  bool isFavorite(String recipeId) {
    return state.any((recipe) => recipe.id == recipeId);
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final repository = ref.read(favoritesRepositoryProvider);

    if (isFavorite(recipe.id)) {
      await repository.removeFavorite(recipe.id);
    } else {
      await repository.saveFavorite(recipe);
    }

    state = repository.getFavorites();
  }
}
