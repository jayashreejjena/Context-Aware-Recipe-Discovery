import 'package:dio/dio.dart';

import '../../../core/network/network_exception.dart';
import '../models/meal_category.dart';
import '../models/recipe.dart';

class MealDbApiService {
  const MealDbApiService(this._dio);

  final Dio _dio;

  Future<List<Recipe>> searchRecipes(String query) async {
    final response = await _get('/search.php', queryParameters: {'s': query});
    final meals = _readList(response.data, 'meals');

    return meals.map(Recipe.fromSearchJson).toList(growable: false);
  }

  Future<List<Recipe>> filterRecipesByArea(String area) async {
    final response = await _get('/filter.php', queryParameters: {'a': area});
    final meals = _readList(response.data, 'meals');

    return meals.map(Recipe.fromFilterJson).toList(growable: false);
  }

  Future<List<MealCategory>> fetchCategories() async {
    final response = await _get('/categories.php');
    final categories = _readList(response.data, 'categories');

    return categories.map(MealCategory.fromJson).toList(growable: false);
  }

  Future<Response<dynamic>> _get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get<dynamic>(path, queryParameters: queryParameters);
    } on DioException catch (error) {
      throw NetworkException.fromDioException(error);
    }
  }

  List<Map<String, dynamic>> _readList(Object? data, String key) {
    if (data is! Map<String, dynamic>) {
      throw const NetworkException('Unexpected response from recipe service.');
    }

    final value = data[key];
    if (value == null) {
      return const [];
    }

    if (value is! List) {
      throw const NetworkException('Unexpected recipe list format.');
    }

    return value.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}
