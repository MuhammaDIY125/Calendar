import 'package:calendar/features/event/domain/entities/event.dart';

sealed class EventState {
  const EventState();
}

class EventInitial extends EventState {
  const EventInitial();
}

class EventLoading extends EventState {
  const EventLoading();
}

class EventLoaded extends EventState {
  final Event event;
  const EventLoaded(this.event);
}

class EventsLoaded extends EventState {
  final List<Event> events;
  const EventsLoaded(this.events);
}

class EventCreated extends EventState {
  final Event event;
  const EventCreated(this.event);
}

class EventUpdated extends EventState {
  final Event event;
  const EventUpdated(this.event);
}

class EventDeleted extends EventState {
  const EventDeleted();
}

class EventError extends EventState {
  final String message;
  const EventError(this.message);
}
