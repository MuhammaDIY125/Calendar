import 'package:equatable/equatable.dart';

/// Вспомогательная сущность для представления даты в календаре.
///
/// Хранит год, месяц и день без привязки к времени и таймзоне.
class CalendarDate extends Equatable {
  final int year;
  final int month;
  final int day;

  const CalendarDate({
    required this.year,
    required this.month,
    required this.day,
  });

  factory CalendarDate.fromDateTime(DateTime date) => CalendarDate(
        year: date.year,
        month: date.month,
        day: date.day,
      );

  factory CalendarDate.today() {
    final now = DateTime.now();
    return CalendarDate(year: now.year, month: now.month, day: now.day);
  }

  DateTime toDateTime() => DateTime(year, month, day);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isSameMonth(CalendarDate other) =>
      year == other.year && month == other.month;

  bool isSameDay(CalendarDate other) =>
      year == other.year && month == other.month && day == other.day;

  @override
  List<Object> get props => [year, month, day];

  @override
  String toString() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
