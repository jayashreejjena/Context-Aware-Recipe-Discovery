import 'package:flutter_test/flutter_test.dart';
import 'package:recipediscovery/features/recipes/models/recipe.dart';

void main() {
  test('parses full recipe details from TheMealDB search payload', () {
    final recipe = Recipe.fromSearchJson({
      'idMeal': '52772',
      'strMeal': 'Teriyaki Chicken Casserole',
      'strMealThumb': 'https://example.com/meal.jpg',
      'strCategory': 'Chicken',
      'strArea': 'Japanese',
      'strInstructions': 'Bake until cooked.',
      'strTags': 'Meat,Casserole',
      'strIngredient1': 'Chicken',
      'strMeasure1': '3 cups',
      'strIngredient2': 'Soy Sauce',
      'strMeasure2': '1/2 cup',
      'strIngredient3': '',
      'strMeasure3': '',
    });

    expect(recipe.id, '52772');
    expect(recipe.name, 'Teriyaki Chicken Casserole');
    expect(recipe.hasDetails, isTrue);
    expect(recipe.tags, ['Meat', 'Casserole']);
    expect(recipe.ingredients, hasLength(2));
    expect(recipe.ingredients.first.displayText, '3 cups Chicken');
  });

  test('parses compact recipe summaries from filter payload', () {
    final recipe = Recipe.fromFilterJson({
      'idMeal': '52959',
      'strMeal': 'Baked salmon with fennel',
      'strMealThumb': 'https://example.com/salmon.jpg',
    });

    expect(recipe.id, '52959');
    expect(recipe.hasDetails, isFalse);
    expect(recipe.ingredients, isEmpty);
  });
}
