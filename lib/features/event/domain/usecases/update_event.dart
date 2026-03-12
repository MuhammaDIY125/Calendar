import 'package:fpdart/fpdart.dart';

import 'package:calendar/core/error/failures.dart';
import 'package:calendar/core/usecases/usecase.dart';
import 'package:calendar/features/event/domain/entities/event.dart';
import 'package:calendar/features/event/domain/repositories/event_repository.dart';

class UpdateEvent extends UseCase<Event, UpdateEventParams> {
  final EventRepository _repository;

  UpdateEvent(this._repository);

  @override
  Future<Either<Failure, Event>> call(UpdateEventParams params) =>
      _repository.updateEvent(params.event);
}

class UpdateEventParams {
  final Event event;

  const UpdateEventParams({required this.event});
}
