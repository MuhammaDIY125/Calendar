import 'package:fpdart/fpdart.dart';

import 'package:calendar/core/error/failures.dart';
import 'package:calendar/features/event/domain/entities/event.dart';

/// Контракт репозитория для отображения данных в календаре.
///
/// Предоставляет агрегированный доступ к событиям для календарных видов.
abstract class CalendarRepository {
  /// Получить события, сгруппированные по датам, для указанного диапазона.
  Future<Either<Failure, Map<DateTime, List<Event>>>> getEventsGroupedByDate(
    DateTime start,
    DateTime end,
  );
}
