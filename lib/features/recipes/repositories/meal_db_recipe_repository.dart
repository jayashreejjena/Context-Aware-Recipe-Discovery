import '../data/meal_db_api_service.dart';
import '../models/meal_category.dart';
import '../models/recipe.dart';
import 'recipe_repository.dart';

class MealDbRecipeRepository implements RecipeRepository {
  const MealDbRecipeRepository(this._apiService);

  final MealDbApiService _apiService;

  @override
  Future<List<Recipe>> searchRecipes(String query) {
    return _apiService.searchRecipes(query.trim());
  }

  @override
  Future<List<Recipe>> fetchRecipesByArea(String area) {
    return _apiService.filterRecipesByArea(area.trim());
  }

  @override
  Future<List<Recipe>> fetchRecipesByCategory(String category) {
    return _apiService.filterRecipesByCategory(category.trim());
  }

  @override
  Future<Recipe> fetchRecipeById(String id) {
    return _apiService.fetchRecipeById(id.trim());
  }

  @override
  Future<List<MealCategory>> fetchCategories() {
    return _apiService.fetchCategories();
  }
}
