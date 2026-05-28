import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_placeholder.dart';
import '../../favorites/favorites_screen.dart';
import '../models/recipe.dart';
import '../providers/recipe_providers.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_search_bar.dart';
import 'recipe_details_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const routeName = 'home';
  static const routePath = '/';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _debounceDuration = Duration(milliseconds: 450);

  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _debouncedQuery = '';

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (!mounted) {
        return;
      }

      setState(() => _debouncedQuery = value.trim());
    });
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    setState(() => _debouncedQuery = '');
  }

  void _retryFetch() {
    if (_debouncedQuery.isEmpty) {
      ref.invalidate(initialRecipesProvider);
    } else {
      ref.invalidate(recipeSearchProvider(_debouncedQuery));
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = _debouncedQuery.isEmpty
        ? ref.watch(initialRecipesProvider)
        : ref.watch(recipeSearchProvider(_debouncedQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Discovery'),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            onPressed: () => context.pushNamed(FavoritesScreen.routeName),
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _retryFetch(),
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                sliver: SliverToBoxAdapter(
                  child: RecipeSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onClear: _clearSearch,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverToBoxAdapter(
                  child: _HomeSectionHeader(query: _debouncedQuery),
                ),
              ),
              recipesAsync.when(
                data: (recipes) =>
                    _RecipeList(recipes: recipes, query: _debouncedQuery),
                loading: () => const _RecipeListLoading(),
                error: (error, stackTrace) => _RecipeListError(
                  message: error.toString(),
                  onRetry: _retryFetch,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = query.isEmpty ? 'Popular recipes' : 'Search results';
    final subtitle = query.isEmpty
        ? 'Fresh ideas from TheMealDB'
        : 'Recipes matching "$query"';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _RecipeList extends StatelessWidget {
  const _RecipeList({required this.recipes, required this.query});

  final List<Recipe> recipes;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppPlaceholder(
          icon: Icons.search_off,
          title: query.isEmpty ? 'No recipes found' : 'No matches for "$query"',
          message: 'Try another keyword like chicken, pasta, or vegan.',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      sliver: SliverList.separated(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
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

class _RecipeListLoading extends StatelessWidget {
  const _RecipeListLoading();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      sliver: SliverList.separated(
        itemCount: 6,
        itemBuilder: (context, index) => const RecipeCardSkeleton(),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    );
  }
}

class _RecipeListError extends StatelessWidget {
  const _RecipeListError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off,
                size: 44,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Could not load recipes',
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
