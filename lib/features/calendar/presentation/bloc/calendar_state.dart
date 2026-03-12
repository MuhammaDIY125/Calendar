import 'package:equatable/equatable.dart';

import 'package:calendar/features/event/domain/entities/event.dart';

/// Режимы отображения календаря
enum CalendarViewMode { year, month, week, day }

class CalendarState extends Equatable {
  final CalendarViewMode viewMode;

  /// Выбранная пользователем дата (подсвечивается)
  final DateTime selectedDate;

  /// Дата, которая определяет текущую страницу PageView
  final DateTime focusedDate;

  /// Кэш событий: ключ — дата без времени, значение — список событий
  final Map<DateTime, List<Event>> cachedEvents;

  final bool isLoading;

  const CalendarState({
    this.viewMode = CalendarViewMode.month,
    required this.selectedDate,
    required this.focusedDate,
    this.cachedEvents = const {},
    this.isLoading = false,
  });

  CalendarState copyWith({
    CalendarViewMode? viewMode,
    DateTime? selectedDate,
    DateTime? focusedDate,
    Map<DateTime, List<Event>>? cachedEvents,
    bool? isLoading,
  }) {
    return CalendarState(
      viewMode: viewMode ?? this.viewMode,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDate: focusedDate ?? this.focusedDate,
      cachedEvents: cachedEvents ?? this.cachedEvents,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Список событий для конкретной даты из кэша
  List<Event> eventsForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return cachedEvents[key] ?? [];
  }

  @override
  List<Object?> get props => [
        viewMode,
        selectedDate,
        focusedDate,
        cachedEvents,
        isLoading,
      ];
}
