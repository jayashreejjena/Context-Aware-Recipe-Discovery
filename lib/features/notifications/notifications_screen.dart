import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/notification_providers.dart';
import 'services/notification_service.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static const routeName = 'notifications';
  static const routePath = '/notifications';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(notificationControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
      );
    });

    final controllerState = ref.watch(notificationControllerProvider);
    final pendingAsync = ref.watch(pendingMealRemindersProvider);
    final isBusy = controllerState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Meal Reminders')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Daily recipe prompts',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Schedule gentle reminders for breakfast, lunch, and dinner.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ...NotificationService.mealReminders.map(
            (reminder) => _ReminderTile(
              title: reminder.title,
              body: reminder.body,
              time: reminder.formattedTime,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: isBusy
                ? null
                : () => ref
                      .read(notificationControllerProvider.notifier)
                      .scheduleMealReminders(),
            icon: isBusy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.notifications_active),
            label: const Text('Schedule reminders'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: isBusy
                ? null
                : () => ref
                      .read(notificationControllerProvider.notifier)
                      .cancelMealReminders(),
            icon: const Icon(Icons.notifications_off),
            label: const Text('Cancel reminders'),
          ),
          const SizedBox(height: 18),
          pendingAsync.when(
            data: (pending) {
              final mealReminderIds = NotificationService.mealReminders
                  .map((reminder) => reminder.id)
                  .toSet();
              final activeCount = pending
                  .where((request) => mealReminderIds.contains(request.id))
                  .length;

              return Text(
                activeCount == 3
                    ? 'All three meal reminders are scheduled.'
                    : '$activeCount of 3 meal reminders are scheduled.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Text(
              'Could not read scheduled reminders.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.title,
    required this.body,
    required this.time,
  });

  final String title;
  final String body;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          child: const Icon(Icons.schedule),
        ),
        title: Text(title),
        subtitle: Text(body),
        trailing: Text(
          time,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
