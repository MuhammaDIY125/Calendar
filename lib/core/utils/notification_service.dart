// Заглушка — будет заменена в Шаге 17

/// Сервис локальных уведомлений.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  NotificationService._();
  factory NotificationService() => _instance;

  Future<void> initialize() async {
    // TODO(step17): инициализация flutter_local_notifications
  }
}
