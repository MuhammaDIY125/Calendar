import 'package:fpdart/fpdart.dart';

import 'package:calendar/core/error/failures.dart';
import 'package:calendar/core/usecases/usecase.dart';
import 'package:calendar/features/event/domain/entities/event.dart';
import 'package:calendar/features/event/domain/repositories/event_repository.dart';

class GetEventsForDate extends UseCase<List<Event>, GetEventsForDateParams> {
  final EventRepository _repository;

  GetEventsForDate(this._repository);

  @override
  Future<Either<Failure, List<Event>>> call(GetEventsForDateParams params) =>
      _repository.getEventsForDate(params.date);
}

class GetEventsForDateParams {
  final DateTime date;

  const GetEventsForDateParams({required this.date});
}
