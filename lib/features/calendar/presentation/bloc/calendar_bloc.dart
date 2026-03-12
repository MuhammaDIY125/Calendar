import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:calendar/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_event.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_state.dart';
import 'package:calendar/features/event/domain/entities/event.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final CalendarRepository _repository;

  CalendarBloc(this._repository)
      : super(CalendarState(
          selectedDate: DateTime.now(),
          focusedDate: DateTime.now(),
        )) {
    on<ChangeViewMode>(_onChangeViewMode);
    on<SelectDate>(_onSelectDate);
    on<NavigateToNext>(_onNavigateToNext);
    on<NavigateToPrevious>(_onNavigateToPrevious);
    on<LoadEventsForRange>(_onLoadEventsForRange);
    on<GoToToday>(_onGoToToday);
  }

  void _onChangeViewMode(ChangeViewMode event, Emitter<CalendarState> emit) {
    emit(state.copyWith(viewMode: event.mode));
  }

  void _onSelectDate(SelectDate event, Emitter<CalendarState> emit) {
    emit(state.copyWith(
      selectedDate: event.date,
      focusedDate: event.date,
    ));
  }

  Future<void> _onNavigateToNext(
    NavigateToNext event,
    Emitter<CalendarState> emit,
  ) async {
    final next = _offsetFocused(1);
    emit(state.copyWith(focusedDate: next));
    await _loadVisibleRange(next, emit);
  }

  Future<void> _onNavigateToPrevious(
    NavigateToPrevious event,
    Emitter<CalendarState> emit,
  ) async {
    final prev = _offsetFocused(-1);
    emit(state.copyWith(focusedDate: prev));
    await _loadVisibleRange(prev, emit);
  }

  Future<void> _onLoadEventsForRange(
    LoadEventsForRange event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getEventsGroupedByDate(
      event.start,
      event.end,
    );

    result.fold(
      (_) => emit(state.copyWith(isLoading: false)),
      (grouped) {
        // Мёрджим с кэшем, не затирая уже загруженные данные
        final merged = Map<DateTime, List<Event>>.from(state.cachedEvents)
          ..addAll(grouped);
        emit(state.copyWith(cachedEvents: merged, isLoading: false));
      },
    );
  }

  Future<void> _onGoToToday(
    GoToToday event,
    Emitter<CalendarState> emit,
  ) async {
    final today = DateTime.now();
    emit(state.copyWith(selectedDate: today, focusedDate: today));
    await _loadVisibleRange(today, emit);
  }

  /// Сдвиг focusedDate в зависимости от текущего режима
  DateTime _offsetFocused(int direction) {
    final focused = state.focusedDate;
    return switch (state.viewMode) {
      CalendarViewMode.year => DateTime(
          focused.year + direction,
          focused.month,
          focused.day,
        ),
      CalendarViewMode.month => DateTime(
          focused.year,
          focused.month + direction,
          1,
        ),
      CalendarViewMode.week => focused.add(Duration(days: direction * 7)),
      CalendarViewMode.day => focused.add(Duration(days: direction)),
    };
  }

  /// Загрузка событий для видимого диапазона ± 1 месяц
  Future<void> _loadVisibleRange(
    DateTime center,
    Emitter<CalendarState> emit,
  ) async {
    final start = DateTime(center.year, center.month - 1, 1);
    final end = DateTime(center.year, center.month + 2, 0);
    await _onLoadEventsForRange(
      LoadEventsForRange(start: start, end: end),
      emit,
    );
  }
}
