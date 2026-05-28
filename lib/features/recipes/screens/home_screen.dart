import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_placeholder.dart';
import '../../favorites/favorites_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = 'home';
  static const routePath = '/';

  @override
  Widget build(BuildContext context) {
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
      body: const AppPlaceholder(
        icon: Icons.restaurant_menu,
        title: 'Smart recipes start here',
        message: 'Step 2 will connect TheMealDB and load real recipe data.',
      ),
    );
  }
}
