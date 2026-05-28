import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final pendingMealRemindersProvider =
    FutureProvider.autoDispose<List<PendingNotificationRequest>>((ref) {
      return ref.watch(notificationServiceProvider).pendingNotifications();
    });

final notificationControllerProvider =
    NotifierProvider<NotificationController, AsyncValue<void>>(
      NotificationController.new,
    );

class NotificationController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> scheduleMealReminders() async {
    state = const AsyncLoading();

    try {
      await ref.read(notificationServiceProvider).scheduleMealReminders();
      ref.invalidate(pendingMealRemindersProvider);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> cancelMealReminders() async {
    state = const AsyncLoading();

    try {
      await ref.read(notificationServiceProvider).cancelMealReminders();
      ref.invalidate(pendingMealRemindersProvider);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
