import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/cached_recipe_image.dart';
import '../../favorites/providers/favorites_providers.dart';
import '../models/recipe.dart';
import '../providers/recipe_providers.dart';

class RecipeDetailsScreen extends ConsumerStatefulWidget {
  const RecipeDetailsScreen({
    required this.recipeId,
    this.initialRecipe,
    super.key,
  });

  static const routeName = 'recipe-details';
  static const routePath = '/recipes/:id';

  final String recipeId;
  final Recipe? initialRecipe;

  @override
  ConsumerState<RecipeDetailsScreen> createState() =>
      _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends ConsumerState<RecipeDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _favoriteController;
  late final Animation<double> _favoriteScale;

  @override
  void initState() {
    super.initState();
    _favoriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _favoriteScale =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1, end: 1.28), weight: 55),
          TweenSequenceItem(tween: Tween(begin: 1.28, end: 1), weight: 45),
        ]).animate(
          CurvedAnimation(
            parent: _favoriteController,
            curve: Curves.easeOutBack,
          ),
        );
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    await ref.read(favoriteRecipesProvider.notifier).toggleFavorite(recipe);
    _favoriteController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(recipeDetailsProvider(widget.recipeId));
    final isFavorite = ref.watch(
      favoriteRecipesProvider.select(
        (recipes) => recipes.any((recipe) => recipe.id == widget.recipeId),
      ),
    );

    return Scaffold(
      body: detailsAsync.when(
        data: (recipe) => _RecipeDetailsContent(
          recipe: recipe,
          isFavorite: isFavorite,
          favoriteScale: _favoriteScale,
          onFavoritePressed: () => _toggleFavorite(recipe),
        ),
        loading: () {
          final initialRecipe = widget.initialRecipe;
          if (initialRecipe != null) {
            return _RecipeDetailsContent(
              recipe: initialRecipe,
              isFavorite: isFavorite,
              favoriteScale: _favoriteScale,
              onFavoritePressed: () => _toggleFavorite(initialRecipe),
              isLoadingDetails: true,
            );
          }

          return const _RecipeDetailsLoading();
        },
        error: (error, stackTrace) => _RecipeDetailsError(
          message: error.toString(),
          onRetry: () => ref.invalidate(recipeDetailsProvider(widget.recipeId)),
        ),
      ),
    );
  }
}

class _RecipeDetailsContent extends StatelessWidget {
  const _RecipeDetailsContent({
    required this.recipe,
    required this.isFavorite,
    required this.favoriteScale,
    required this.onFavoritePressed,
    this.isLoadingDetails = false,
  });

  final Recipe recipe;
  final bool isFavorite;
  final Animation<double> favoriteScale;
  final VoidCallback onFavoritePressed;
  final bool isLoadingDetails;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          stretch: true,
          actions: [
            ScaleTransition(
              scale: favoriteScale,
              child: IconButton.filledTonal(
                tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
                onPressed: onFavoritePressed,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(isFavorite),
                    color: isFavorite ? Colors.redAccent : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'recipe-image-${recipe.id}',
              child: CachedRecipeImage(
                imageUrl: recipe.thumbnailUrl,
                fit: BoxFit.cover,
                iconSize: 56,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                recipe.name,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (recipe.category != null)
                    _InfoChip(icon: Icons.category, label: recipe.category!),
                  if (recipe.area != null)
                    _InfoChip(icon: Icons.public, label: recipe.area!),
                ],
              ),
              const SizedBox(height: 24),
              if (isLoadingDetails)
                const _InlineDetailsLoading()
              else ...[
                if (recipe.ingredients.isNotEmpty) ...[
                  _SectionTitle(title: 'Ingredients'),
                  const SizedBox(height: 10),
                  ...recipe.ingredients.map(
                    (ingredient) => _IngredientRow(ingredient: ingredient),
                  ),
                  const SizedBox(height: 24),
                ],
                _SectionTitle(title: 'Instructions'),
                const SizedBox(height: 10),
                Text(
                  recipe.instructions ?? 'No instructions available.',
                  style: textTheme.bodyLarge?.copyWith(height: 1.55),
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(icon, size: 18, color: colorScheme.onPrimaryContainer),
      label: Text(label),
      backgroundColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide.none,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.ingredient});

  final RecipeIngredient ingredient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ingredient.displayText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineDetailsLoading extends StatelessWidget {
  const _InlineDetailsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Loading details'),
        const SizedBox(height: 12),
        LinearProgressIndicator(borderRadius: BorderRadius.circular(999)),
      ],
    );
  }
}

class _RecipeDetailsLoading extends StatelessWidget {
  const _RecipeDetailsLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _RecipeDetailsError extends StatelessWidget {
  const _RecipeDetailsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Details')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 44,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load recipe',
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
      ),
    );
  }
}
