import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipediscovery/core/services/app.dart';
import 'package:recipediscovery/features/location/models/location_cuisine_context.dart';
import 'package:recipediscovery/features/location/providers/location_providers.dart';
import 'package:recipediscovery/features/recipes/models/recipe.dart';
import 'package:recipediscovery/features/recipes/providers/recipe_providers.dart';

void main() {
  testWidgets('renders recipe discovery app shell', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialRecipesProvider.overrideWith((ref) async {
            return const [
              Recipe(
                id: '52772',
                name: 'Teriyaki Chicken Casserole',
                thumbnailUrl: 'https://example.com/meal.jpg',
                category: 'Chicken',
                area: 'Japanese',
              ),
            ];
          }),
          mealTimeRecipesProvider.overrideWith((ref) async => const []),
          locationCuisineContextProvider.overrideWith((ref) async {
            return const LocationCuisineContext(
              country: 'India',
              countryCode: 'IN',
              cuisineArea: 'Indian',
            );
          }),
          locationRecipesProvider.overrideWith((ref) async => const []),
        ],
        child: const RecipeDiscoveryApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Recipe Discovery'), findsOneWidget);
    expect(find.text('Popular recipes'), findsOneWidget);
    expect(find.text('Teriyaki Chicken Casserole'), findsOneWidget);
  });
}
