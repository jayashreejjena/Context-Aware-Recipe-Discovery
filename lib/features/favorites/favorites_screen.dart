import 'package:flutter/material.dart';

import '../../core/widgets/app_placeholder.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  static const routeName = 'favorites';
  static const routePath = '/favorites';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _FavoritesAppBar(),
      body: AppPlaceholder(
        icon: Icons.favorite_border,
        title: 'No favorites yet',
        message: 'Step 5 will store favorite recipes locally with Hive.',
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
