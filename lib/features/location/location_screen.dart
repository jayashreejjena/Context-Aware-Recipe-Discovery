import 'package:flutter/material.dart';

import '../../core/widgets/app_placeholder.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  static const routeName = 'location';
  static const routePath = '/location';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppPlaceholder(
        icon: Icons.public,
        title: 'Cuisine near you',
        message: 'Step 7 will map device country to cuisine suggestions.',
      ),
    );
  }
}
