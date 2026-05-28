enum MealTime { breakfast, lunch, dinner }

class MealTimeSuggestion {
  const MealTimeSuggestion({
    required this.mealTime,
    required this.title,
    required this.subtitle,
    required this.category,
  });

  final MealTime mealTime;
  final String title;
  final String subtitle;
  final String category;

  factory MealTimeSuggestion.fromDateTime(DateTime dateTime) {
    final hour = dateTime.hour;

    if (hour >= 5 && hour < 12) {
      return const MealTimeSuggestion(
        mealTime: MealTime.breakfast,
        title: 'Breakfast ideas',
        subtitle: 'Start the day with something bright',
        category: 'Breakfast',
      );
    }

    if (hour >= 12 && hour < 17) {
      return const MealTimeSuggestion(
        mealTime: MealTime.lunch,
        title: 'Lunch ideas',
        subtitle: 'Balanced recipes for the middle of the day',
        category: 'Vegetarian',
      );
    }

    return const MealTimeSuggestion(
      mealTime: MealTime.dinner,
      title: 'Dinner ideas',
      subtitle: 'Comforting recipes for the evening',
      category: 'Seafood',
    );
  }
}
