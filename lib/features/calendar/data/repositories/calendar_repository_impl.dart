import 'package:fpdart/fpdart.dart';

import 'package:calendar/core/error/exceptions.dart';
import 'package:calendar/core/error/failures.dart';
import 'package:calendar/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:calendar/features/event/data/datasources/event_local_datasource.dart';
import 'package:calendar/features/event/domain/entities/event.dart';

/// Реализация календарного репозитория.
///
/// Загружает события из SQLite и группирует их по датам.
class CalendarRepositoryImpl implements CalendarRepository {
  final EventLocalDatasource _datasource;

  const CalendarRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, Map<DateTime, List<Event>>>> getEventsGroupedByDate(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final startStr = _formatDate(start);
      final endStr = _formatDate(end);
      final models = await _datasource.getEventsForRange(startStr, endStr);

      // Группируем по дате (без времени)
      final Map<DateTime, List<Event>> grouped = {};
      for (final model in models) {
        final key = DateTime(model.date.year, model.date.month, model.date.day);
        grouped.putIfAbsent(key, () => []).add(model);
      }

      return Right(grouped);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
