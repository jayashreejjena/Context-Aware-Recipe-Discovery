import 'package:flutter/material.dart';

import '../../../core/widgets/app_placeholder.dart';

class RecipeDetailsPlaceholderScreen extends StatelessWidget {
  const RecipeDetailsPlaceholderScreen({required this.recipeId, super.key});

  static const routeName = 'recipe-details';
  static const routePath = '/recipes/:id';

  final String recipeId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Details')),
      body: AppPlaceholder(
        icon: Icons.receipt_long,
        title: 'Recipe $recipeId',
        message: 'Step 4 will replace this with the production details screen.',
      ),
    );
  }
}
