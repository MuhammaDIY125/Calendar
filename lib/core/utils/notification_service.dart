import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:calendar/features/event/domain/entities/event.dart';

/// Сервис локальных уведомлений о событиях.
///
/// Синглтон — инициализируется один раз в [main.dart].
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  NotificationService._();
  factory NotificationService() => _instance;

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'calendar_events';
  static const _channelName = 'Event Reminders';
  static const _channelDesc = 'Reminders for upcoming calendar events';

  Future<void> initialize() async {
    // Инициализация базы данных временных зон
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    // Создаём канал уведомлений для Android
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Запрос разрешений (Android 13+, iOS).
  Future<bool> requestPermissions() async {
    // iOS
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Android 13+
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return (iosGranted ?? true) && (androidGranted ?? true);
  }

  /// Запланировать уведомление для события.
  ///
  /// ID уведомления = ID события в БД.
  Future<void> scheduleEventReminder(Event event) async {
    final id = event.id;
    final reminder = event.reminderMinutes;
    if (id == null || reminder == null) return;

    // Вычисляем время уведомления
    final eventDateTime = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      event.startTime.hour,
      event.startTime.minute,
    );
    final notifyAt = eventDateTime.subtract(Duration(minutes: reminder));

    // Не планируем уведомления в прошлом
    if (notifyAt.isBefore(DateTime.now())) return;

    final tzNotifyAt = tz.TZDateTime.from(notifyAt, tz.local);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final reminderLabel = _reminderLabel(reminder);

    await _plugin.zonedSchedule(
      id,
      event.name,
      '$reminderLabel: ${event.location.isNotEmpty ? event.location : 'No location'}',
      tzNotifyAt,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Отменить уведомление для события по id.
  Future<void> cancelEventReminder(int eventId) async {
    await _plugin.cancel(eventId);
  }

  /// Отменить все запланированные уведомления.
  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  String _reminderLabel(int minutes) => switch (minutes) {
        5 => 'In 5 minutes',
        15 => 'In 15 minutes',
        30 => 'In 30 minutes',
        60 => 'In 1 hour',
        1440 => 'Tomorrow',
        _ => 'In $minutes minutes',
      };
}
