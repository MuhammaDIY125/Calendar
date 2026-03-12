import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:calendar/core/utils/notification_service.dart';
import 'package:calendar/features/event/domain/usecases/create_event.dart';
import 'package:calendar/features/event/domain/usecases/delete_event.dart';
import 'package:calendar/features/event/domain/usecases/get_event_by_id.dart';
import 'package:calendar/features/event/domain/usecases/get_events_for_date.dart';
import 'package:calendar/features/event/domain/usecases/update_event.dart';
import 'package:calendar/features/event/presentation/bloc/event_event.dart';
import 'package:calendar/features/event/presentation/bloc/event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final CreateEvent _createEvent;
  final UpdateEvent _updateEvent;
  final DeleteEvent _deleteEvent;
  final GetEventsForDate _getEventsForDate;
  final GetEventById _getEventById;
  final NotificationService _notifications;

  EventBloc({
    required CreateEvent createEvent,
    required UpdateEvent updateEvent,
    required DeleteEvent deleteEvent,
    required GetEventsForDate getEventsForDate,
    required GetEventById getEventById,
    NotificationService? notificationService,
  })  : _createEvent = createEvent,
        _updateEvent = updateEvent,
        _deleteEvent = deleteEvent,
        _getEventsForDate = getEventsForDate,
        _getEventById = getEventById,
        _notifications = notificationService ?? NotificationService(),
        super(const EventInitial()) {
    on<CreateEventRequested>(_onCreate);
    on<UpdateEventRequested>(_onUpdate);
    on<DeleteEventRequested>(_onDelete);
    on<LoadEventsForDate>(_onLoadForDate);
    on<LoadEventById>(_onLoadById);
  }

  Future<void> _onCreate(
    CreateEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(const EventLoading());
    final result = await _createEvent(CreateEventParams(event: event.event));
    await result.fold(
      (failure) async => emit(EventError(failure.message)),
      (created) async {
        // Планируем уведомление если задано напоминание
        await _notifications.scheduleEventReminder(created);
        emit(EventCreated(created));
      },
    );
  }

  Future<void> _onUpdate(
    UpdateEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(const EventLoading());
    final result = await _updateEvent(UpdateEventParams(event: event.event));
    await result.fold(
      (failure) async => emit(EventError(failure.message)),
      (updated) async {
        // Пересоздаём уведомление: сначала отменяем старое
        if (updated.id != null) {
          await _notifications.cancelEventReminder(updated.id!);
        }
        await _notifications.scheduleEventReminder(updated);
        emit(EventUpdated(updated));
      },
    );
  }

  Future<void> _onDelete(
    DeleteEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(const EventLoading());
    final result = await _deleteEvent(DeleteEventParams(id: event.id));
    await result.fold(
      (failure) async => emit(EventError(failure.message)),
      (_) async {
        // Отменяем уведомление при удалении
        await _notifications.cancelEventReminder(event.id);
        emit(const EventDeleted());
      },
    );
  }

  Future<void> _onLoadForDate(
    LoadEventsForDate event,
    Emitter<EventState> emit,
  ) async {
    emit(const EventLoading());
    final result = await _getEventsForDate(
      GetEventsForDateParams(date: event.date),
    );
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (events) => emit(EventsLoaded(events)),
    );
  }

  Future<void> _onLoadById(
    LoadEventById event,
    Emitter<EventState> emit,
  ) async {
    emit(const EventLoading());
    final result = await _getEventById(GetEventByIdParams(id: event.id));
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (e) => emit(EventLoaded(e)),
    );
  }
}
