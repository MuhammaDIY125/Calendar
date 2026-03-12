import 'package:fpdart/fpdart.dart';

import 'package:calendar/core/error/failures.dart';
import 'package:calendar/core/usecases/usecase.dart';
import 'package:calendar/features/event/domain/entities/event.dart';
import 'package:calendar/features/event/domain/repositories/event_repository.dart';

class CreateEvent extends UseCase<Event, CreateEventParams> {
  final EventRepository _repository;

  CreateEvent(this._repository);

  @override
  Future<Either<Failure, Event>> call(CreateEventParams params) =>
      _repository.createEvent(params.event);
}

class CreateEventParams {
  final Event event;

  const CreateEventParams({required this.event});
}
