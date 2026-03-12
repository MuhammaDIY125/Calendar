import 'package:fpdart/fpdart.dart';

import 'package:calendar/core/error/failures.dart';
import 'package:calendar/core/usecases/usecase.dart';
import 'package:calendar/features/event/domain/entities/event.dart';
import 'package:calendar/features/event/domain/repositories/event_repository.dart';

class GetEventsForRange extends UseCase<List<Event>, GetEventsForRangeParams> {
  final EventRepository _repository;

  GetEventsForRange(this._repository);

  @override
  Future<Either<Failure, List<Event>>> call(GetEventsForRangeParams params) =>
      _repository.getEventsForRange(params.start, params.end);
}

class GetEventsForRangeParams {
  final DateTime start;
  final DateTime end;

  const GetEventsForRangeParams({required this.start, required this.end});
}
