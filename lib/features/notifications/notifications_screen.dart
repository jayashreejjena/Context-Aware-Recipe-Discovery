import 'package:flutter/material.dart';

import '../../core/widgets/app_placeholder.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const routeName = 'notifications';
  static const routePath = '/notifications';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppPlaceholder(
        icon: Icons.notifications_none,
        title: 'Meal reminders',
        message: 'Step 9 will schedule breakfast, lunch, and dinner alerts.',
      ),
    );
  }
}
