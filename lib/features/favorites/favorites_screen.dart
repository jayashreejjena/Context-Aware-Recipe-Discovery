import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_placeholder.dart';
import '../recipes/screens/recipe_details_screen.dart';
import '../recipes/widgets/recipe_card.dart';
import 'providers/favorites_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  static const routeName = 'favorites';
  static const routePath = '/favorites';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteRecipesProvider);

    return Scaffold(
      appBar: const _FavoritesAppBar(),
      body: favorites.isEmpty
          ? const AppPlaceholder(
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              message: 'Recipes you save will stay available offline.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final recipe = favorites[index];
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
            ),
    );
  }
}

class _FavoritesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _FavoritesAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Favorites'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
