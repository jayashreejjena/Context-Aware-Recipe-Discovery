import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/storage_keys.dart';
import 'core/services/app.dart';
import 'features/notifications/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<dynamic>(StorageKeys.favoritesBox),
    Hive.openBox<dynamic>(StorageKeys.viewedRecipesBox),
  ]);
  await NotificationService().initialize();

  runApp(const ProviderScope(child: RecipeDiscoveryApp()));
}
