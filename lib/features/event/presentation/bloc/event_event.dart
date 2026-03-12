import 'package:calendar/features/event/domain/entities/event.dart';

abstract class EventEvent {
  const EventEvent();
}

class CreateEventRequested extends EventEvent {
  final Event event;
  const CreateEventRequested(this.event);
}

class UpdateEventRequested extends EventEvent {
  final Event event;
  const UpdateEventRequested(this.event);
}

class DeleteEventRequested extends EventEvent {
  final int id;
  const DeleteEventRequested(this.id);
}

class LoadEventsForDate extends EventEvent {
  final DateTime date;
  const LoadEventsForDate(this.date);
}

class LoadEventById extends EventEvent {
  final int id;
  const LoadEventById(this.id);
}
