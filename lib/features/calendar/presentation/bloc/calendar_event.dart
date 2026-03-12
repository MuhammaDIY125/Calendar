import 'package:calendar/features/calendar/presentation/bloc/calendar_state.dart';

abstract class CalendarEvent {
  const CalendarEvent();
}

/// Переключение режима отображения (год / месяц / неделя / день)
class ChangeViewMode extends CalendarEvent {
  final CalendarViewMode mode;
  const ChangeViewMode(this.mode);
}

/// Выбор конкретной даты
class SelectDate extends CalendarEvent {
  final DateTime date;
  const SelectDate(this.date);
}

/// Навигация вперёд (следующий месяц / неделя / день / год)
class NavigateToNext extends CalendarEvent {
  const NavigateToNext();
}

/// Навигация назад (предыдущий месяц / неделя / день / год)
class NavigateToPrevious extends CalendarEvent {
  const NavigateToPrevious();
}

/// Загрузка событий для указанного диапазона дат
class LoadEventsForRange extends CalendarEvent {
  final DateTime start;
  final DateTime end;
  const LoadEventsForRange({required this.start, required this.end});
}

/// Переход к сегодняшней дате
class GoToToday extends CalendarEvent {
  const GoToToday();
}
