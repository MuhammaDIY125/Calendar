import 'package:flutter/material.dart';

import 'package:calendar/app.dart';
import 'package:calendar/core/di/injection.dart';
import 'package:calendar/core/utils/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Регистрация зависимостей
  await configureDependencies();

  // Инициализация сервиса уведомлений
  await NotificationService().initialize();

  runApp(const App());
}
