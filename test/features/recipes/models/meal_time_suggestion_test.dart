import 'package:flutter_test/flutter_test.dart';
import 'package:recipediscovery/features/recipes/models/meal_time_suggestion.dart';

void main() {
  test('maps morning hours to breakfast recommendations', () {
    final suggestion = MealTimeSuggestion.fromDateTime(
      DateTime(2026, 5, 28, 8),
    );

    expect(suggestion.mealTime, MealTime.breakfast);
    expect(suggestion.title, 'Breakfast ideas');
    expect(suggestion.category, 'Breakfast');
  });

  test('maps afternoon hours to lunch recommendations', () {
    final suggestion = MealTimeSuggestion.fromDateTime(
      DateTime(2026, 5, 28, 14),
    );

    expect(suggestion.mealTime, MealTime.lunch);
    expect(suggestion.title, 'Lunch ideas');
    expect(suggestion.category, 'Vegetarian');
  });

  test('maps evening and night hours to dinner recommendations', () {
    final suggestion = MealTimeSuggestion.fromDateTime(
      DateTime(2026, 5, 28, 20),
    );

    expect(suggestion.mealTime, MealTime.dinner);
    expect(suggestion.title, 'Dinner ideas');
    expect(suggestion.category, 'Seafood');
  });
}
