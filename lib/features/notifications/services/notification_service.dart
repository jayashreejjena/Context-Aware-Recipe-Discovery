import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/meal_reminder.dart';

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const mealReminders = [
    MealReminder(
      id: 800,
      title: 'Breakfast inspiration',
      body: 'Find a breakfast recipe to start the day.',
      hour: 8,
      minute: 0,
    ),
    MealReminder(
      id: 1400,
      title: 'Lunch recipe break',
      body: 'Discover a fresh lunch idea for today.',
      hour: 14,
      minute: 0,
    ),
    MealReminder(
      id: 2000,
      title: 'Dinner discovery',
      body: 'Pick a dinner recipe before the evening rush.',
      hour: 20,
      minute: 0,
    ),
  ];

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    await _configureTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(initializationSettings);
  }

  Future<bool> requestPermissions() async {
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    final macosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    if (Platform.isAndroid) {
      return androidGranted ?? true;
    }
    if (Platform.isIOS) {
      return iosGranted ?? false;
    }
    if (Platform.isMacOS) {
      return macosGranted ?? false;
    }

    return true;
  }

  Future<void> scheduleMealReminders() async {
    final granted = await requestPermissions();
    if (!granted) {
      throw const NotificationPermissionException(
        'Notification permission was not granted.',
      );
    }

    await cancelMealReminders();

    for (final reminder in mealReminders) {
      await _plugin.zonedSchedule(
        reminder.id,
        reminder.title,
        reminder.body,
        _nextInstanceOf(reminder.hour, reminder.minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_reminders',
            'Meal reminders',
            channelDescription: 'Breakfast, lunch, and dinner recipe prompts.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelMealReminders() async {
    for (final reminder in mealReminders) {
      await _plugin.cancel(reminder.id);
    }
  }

  Future<List<PendingNotificationRequest>> pendingNotifications() {
    return _plugin.pendingNotificationRequests();
  }

  Future<void> _configureTimezone() async {
    tz.initializeTimeZones();

    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}

class NotificationPermissionException implements Exception {
  const NotificationPermissionException(this.message);

  final String message;

  @override
  String toString() => message;
}
