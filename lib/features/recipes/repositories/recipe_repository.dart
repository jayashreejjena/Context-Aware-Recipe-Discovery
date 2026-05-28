import '../models/meal_category.dart';
import '../models/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> searchRecipes(String query);

  Future<List<Recipe>> fetchRecipesByArea(String area);

  Future<List<MealCategory>> fetchCategories();
}
