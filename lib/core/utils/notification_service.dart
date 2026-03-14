import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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
    log('NotificationService: начало инициализации', name: 'Notifications');

    // Инициализация базы данных временных зон
    tz.initializeTimeZones();
    log('NotificationService: временные зоны загружены', name: 'Notifications');

    // Устанавливаем локальный часовой пояс устройства.
    // DateTime.now().timeZoneName возвращает системное название зоны (напр. "Europe/Moscow").
    // Если не найдено — оставляем UTC, иначе уведомления планировались бы с неверным смещением.
    // flutter_timezone возвращает корректное IANA-имя (напр. "Asia/Tashkent"),
    // в отличие от DateTime.now().timeZoneName который на iOS даёт "+05"
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      final tzName = tzInfo.identifier;
      tz.setLocalLocation(tz.getLocation(tzName));
      log('NotificationService: timezone = "$tzName"', name: 'Notifications');
    } catch (e) {
      log('NotificationService: не удалось получить timezone ($e), используем UTC', name: 'Notifications');
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    // defaultPresent* — показывать уведомления даже когда приложение на переднем плане
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      defaultPresentBanner: true,
      defaultPresentList: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    final initialized = await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        log('NotificationService: уведомление нажато payload=${response.payload}', name: 'Notifications');
      },
    );
    log('NotificationService: plugin.initialize() = $initialized', name: 'Notifications');

    // Создаём канал уведомлений для Android с максимальным приоритетом
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    log('NotificationService: Android канал "$_channelId" создан', name: 'Notifications');

    // Запрашиваем разрешения сразу при инициализации
    final granted = await requestPermissions();
    log('NotificationService: разрешения получены = $granted', name: 'Notifications');
    log('NotificationService: инициализация завершена', name: 'Notifications');
  }

  /// Запрос разрешений (Android 13+, iOS).
  Future<bool> requestPermissions() async {
    log('NotificationService: запрашиваем разрешения...', name: 'Notifications');

    // iOS
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    log('NotificationService: iOS разрешение = $iosGranted', name: 'Notifications');

    // Android 13+
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    log('NotificationService: Android POST_NOTIFICATIONS = $androidGranted', name: 'Notifications');

    // Android — запрос разрешения на точные будильники (Android 12+)
    final exactAlarmGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
    log('NotificationService: Android EXACT_ALARM = $exactAlarmGranted', name: 'Notifications');

    final result = (iosGranted ?? true) && (androidGranted ?? true);
    log('NotificationService: итоговый результат разрешений = $result', name: 'Notifications');
    return result;
  }

  /// Запланировать уведомление для события.
  ///
  /// ID уведомления = ID события в БД.
  Future<void> scheduleEventReminder(Event event) async {
    final id = event.id;
    final reminder = event.reminderMinutes;

    log('NotificationService: scheduleEventReminder() — id=$id, reminder=$reminder, event="${event.name}"', name: 'Notifications');

    if (id == null) {
      log('NotificationService: ⚠️ пропуск — id == null', name: 'Notifications');
      return;
    }
    if (reminder == null) {
      log('NotificationService: ℹ️ пропуск — reminderMinutes == null (напоминание не задано)', name: 'Notifications');
      return;
    }

    // Вычисляем время уведомления в локальном времени устройства
    final eventDateTime = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      event.startTime.hour,
      event.startTime.minute,
    );
    final notifyAt = eventDateTime.subtract(Duration(minutes: reminder));
    final now = DateTime.now();

    log('NotificationService: событие в $eventDateTime, уведомление в $notifyAt, сейчас $now', name: 'Notifications');

    // Не планируем уведомления в прошлом
    if (notifyAt.isBefore(now)) {
      log('NotificationService: ⚠️ пропуск — время уведомления в прошлом ($notifyAt)', name: 'Notifications');
      return;
    }

    // Конвертируем в TZDateTime с учётом реального локального часового пояса
    final tzNotifyAt = tz.TZDateTime.from(notifyAt, tz.local);
    log('NotificationService: TZDateTime = $tzNotifyAt (зона: ${tz.local.name})', name: 'Notifications');

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // timeSensitive — пробивает Focus Mode / DND на iOS
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final reminderLabel = _reminderLabel(reminder);
    final body = '$reminderLabel: ${event.location.isNotEmpty ? event.location : 'No location'}';

    log('NotificationService: вызываем zonedSchedule(id=$id, title="${event.name}", body="$body")', name: 'Notifications');

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: event.name,
        body: body,
        scheduledDate: tzNotifyAt,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
      );
      log('NotificationService: ✅ уведомление запланировано (id=$id) на $tzNotifyAt', name: 'Notifications');
    } catch (e, stack) {
      log('NotificationService: ❌ ошибка zonedSchedule: $e', name: 'Notifications', error: e, stackTrace: stack);
    }
  }

  /// Отменить уведомление для события по id.
  Future<void> cancelEventReminder(int eventId) async {
    log('NotificationService: отмена уведомления id=$eventId', name: 'Notifications');
    await _plugin.cancel(id: eventId);
    log('NotificationService: уведомление id=$eventId отменено', name: 'Notifications');
  }

  /// Отменить все запланированные уведомления.
  Future<void> cancelAllReminders() async {
    log('NotificationService: отмена всех уведомлений', name: 'Notifications');
    await _plugin.cancelAll();
    log('NotificationService: все уведомления отменены', name: 'Notifications');
  }

  /// Вывести список всех активных уведомлений (для отладки).
  Future<void> debugPrintPendingNotifications() async {
    final pending = await _plugin.pendingNotificationRequests();
    log('NotificationService: запланировано уведомлений: ${pending.length}', name: 'Notifications');
    for (final n in pending) {
      log('  • id=${n.id}, title="${n.title}", body="${n.body}"', name: 'Notifications');
    }
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
