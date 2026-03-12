import 'package:fpdart/fpdart.dart';

import 'package:calendar/core/error/failures.dart';
import 'package:calendar/core/usecases/usecase.dart';
import 'package:calendar/features/event/domain/repositories/event_repository.dart';

class DeleteEvent extends UseCase<void, DeleteEventParams> {
  final EventRepository _repository;

  DeleteEvent(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteEventParams params) =>
      _repository.deleteEvent(params.id);
}

class DeleteEventParams {
  final int id;

  const DeleteEventParams({required this.id});
}
