import 'package:fpdart/fpdart.dart';

import 'package:calendar/core/error/exceptions.dart';
import 'package:calendar/core/error/failures.dart';
import 'package:calendar/features/event/data/datasources/event_local_datasource.dart';
import 'package:calendar/features/event/data/models/event_model.dart';
import 'package:calendar/features/event/domain/entities/event.dart';
import 'package:calendar/features/event/domain/repositories/event_repository.dart';

/// Реализация репозитория событий поверх SQLite datasource.
class EventRepositoryImpl implements EventRepository {
  final EventLocalDatasource _datasource;

  const EventRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, Event>> createEvent(Event event) async {
    try {
      final model = EventModel.fromEntity(event);
      final created = await _datasource.createEvent(model);
      return Right(created);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> updateEvent(Event event) async {
    try {
      final model = EventModel.fromEntity(event);
      final updated = await _datasource.updateEvent(model);
      return Right(updated);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(int id) async {
    try {
      await _datasource.deleteEvent(id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getEventsForDate(DateTime date) async {
    try {
      final dateStr = _formatDate(date);
      final models = await _datasource.getEventsForDate(dateStr);
      return Right(models);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getEventsForRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final models = await _datasource.getEventsForRange(
        _formatDate(start),
        _formatDate(end),
      );
      return Right(models);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventById(int id) async {
    try {
      final model = await _datasource.getEventById(id);
      return Right(model);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Форматирование даты в 'YYYY-MM-DD' для SQLite
  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
