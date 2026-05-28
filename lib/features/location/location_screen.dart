import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/app_placeholder.dart';
import '../recipes/screens/recipe_details_screen.dart';
import '../recipes/widgets/recipe_card.dart';
import 'providers/location_providers.dart';

class LocationScreen extends ConsumerWidget {
  const LocationScreen({super.key});

  static const routeName = 'location';
  static const routePath = '/location';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(locationCuisineContextProvider);
    final recipesAsync = ref.watch(locationRecipesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cuisine Near You')),
      body: contextAsync.when(
        data: (locationContext) => recipesAsync.when(
          data: (recipes) {
            if (recipes.isEmpty) {
              return const AppPlaceholder(
                icon: Icons.public,
                title: 'No local recipes found',
                message: 'Try searching from the home screen.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: recipes.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _LocationHeader(
                    country: locationContext.country,
                    cuisineArea: locationContext.cuisineArea,
                  );
                }

                final recipe = recipes[index - 1];
                return RecipeCard(
                  recipe: recipe,
                  onTap: () => context.pushNamed(
                    RecipeDetailsScreen.routeName,
                    pathParameters: {'id': recipe.id},
                    extra: recipe,
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            );
          },
          loading: () => const _LocationLoadingList(),
          error: (error, stackTrace) => _LocationError(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(locationCuisineContextProvider);
              ref.invalidate(locationRecipesProvider);
            },
          ),
        ),
        loading: () => const _LocationLoadingList(),
        error: (error, stackTrace) => _LocationError(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(locationCuisineContextProvider);
            ref.invalidate(locationRecipesProvider);
          },
        ),
      ),
    );
  }
}

class _LocationLoadingList extends StatelessWidget {
  const _LocationLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => const RecipeCardSkeleton(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({required this.country, required this.cuisineArea});

  final String country;
  final String cuisineArea;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$cuisineArea recipes',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on your location in $country',
            style: textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationError extends StatelessWidget {
  const _LocationError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorView(
      title: 'Location unavailable',
      message: message,
      onRetry: onRetry,
    );
  }
}
