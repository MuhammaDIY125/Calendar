import 'package:fpdart/fpdart.dart';

import 'package:calendar/core/error/failures.dart';
import 'package:calendar/core/usecases/usecase.dart';
import 'package:calendar/features/event/domain/entities/event.dart';
import 'package:calendar/features/event/domain/repositories/event_repository.dart';

class GetEventById extends UseCase<Event, GetEventByIdParams> {
  final EventRepository _repository;

  GetEventById(this._repository);

  @override
  Future<Either<Failure, Event>> call(GetEventByIdParams params) =>
      _repository.getEventById(params.id);
}

class GetEventByIdParams {
  final int id;

  const GetEventByIdParams({required this.id});
}
