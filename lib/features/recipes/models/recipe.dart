class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    this.category,
    this.area,
    this.instructions,
    this.youtubeUrl,
    this.sourceUrl,
    this.tags = const [],
    this.ingredients = const [],
  });

  final String id;
  final String name;
  final String thumbnailUrl;
  final String? category;
  final String? area;
  final String? instructions;
  final String? youtubeUrl;
  final String? sourceUrl;
  final List<String> tags;
  final List<RecipeIngredient> ingredients;

  bool get hasDetails => instructions != null && instructions!.isNotEmpty;

  factory Recipe.fromSearchJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? '',
      thumbnailUrl: json['strMealThumb']?.toString() ?? '',
      category: _nullableString(json['strCategory']),
      area: _nullableString(json['strArea']),
      instructions: _nullableString(json['strInstructions']),
      youtubeUrl: _nullableString(json['strYoutube']),
      sourceUrl: _nullableString(json['strSource']),
      tags: _parseTags(json['strTags']),
      ingredients: _parseIngredients(json),
    );
  }

  factory Recipe.fromFilterJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? '',
      thumbnailUrl: json['strMealThumb']?.toString() ?? '',
    );
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? thumbnailUrl,
    String? category,
    String? area,
    String? instructions,
    String? youtubeUrl,
    String? sourceUrl,
    List<String>? tags,
    List<RecipeIngredient>? ingredients,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      category: category ?? this.category,
      area: area ?? this.area,
      instructions: instructions ?? this.instructions,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      tags: tags ?? this.tags,
      ingredients: ingredients ?? this.ingredients,
    );
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  static List<String> _parseTags(Object? value) {
    final text = _nullableString(value);
    if (text == null) {
      return const [];
    }

    return text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList(growable: false);
  }

  static List<RecipeIngredient> _parseIngredients(Map<String, dynamic> json) {
    final ingredients = <RecipeIngredient>[];

    for (var index = 1; index <= 20; index++) {
      final name = _nullableString(json['strIngredient$index']);
      if (name == null) {
        continue;
      }

      ingredients.add(
        RecipeIngredient(
          name: name,
          measure: _nullableString(json['strMeasure$index']),
        ),
      );
    }

    return List.unmodifiable(ingredients);
  }
}

class RecipeIngredient {
  const RecipeIngredient({required this.name, this.measure});

  final String name;
  final String? measure;

  String get displayText {
    final value = measure;
    if (value == null || value.isEmpty) {
      return name;
    }
    return '$value $name';
  }
}
