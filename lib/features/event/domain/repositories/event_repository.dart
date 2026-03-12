import 'package:fpdart/fpdart.dart';

import 'package:calendar/core/error/failures.dart';
import 'package:calendar/features/event/domain/entities/event.dart';

/// Контракт репозитория событий.
///
/// Все методы возвращают [Either] — [Failure] при ошибке или данные при успехе.
abstract class EventRepository {
  /// Создать новое событие. Возвращает созданное событие с присвоенным id.
  Future<Either<Failure, Event>> createEvent(Event event);

  /// Обновить существующее событие.
  Future<Either<Failure, Event>> updateEvent(Event event);

  /// Удалить событие по id.
  Future<Either<Failure, void>> deleteEvent(int id);

  /// Получить все события для конкретной даты.
  Future<Either<Failure, List<Event>>> getEventsForDate(DateTime date);

  /// Получить все события в диапазоне дат (включительно).
  Future<Either<Failure, List<Event>>> getEventsForRange(
    DateTime start,
    DateTime end,
  );

  /// Получить событие по id.
  Future<Either<Failure, Event>> getEventById(int id);
}
