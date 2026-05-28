import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _LocationError(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(locationCuisineContextProvider);
              ref.invalidate(locationRecipesProvider);
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off,
              size: 44,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Location unavailable',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
