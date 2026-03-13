import 'package:calendar/core/constants/app_constants.dart';

class CalendarDateUtils {
  CalendarDateUtils._();

  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  static int firstWeekdayOfMonth(int year, int month) =>
      DateTime(year, month, 1).weekday % 7;

  static bool isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

  static int getWeeksInMonth(int year, int month) {
    final firstWeekday = firstWeekdayOfMonth(year, month);
    final days = daysInMonth(year, month);
    return ((firstWeekday + days) / 7).ceil();
  }

  static int monthToIndex(int year, int month) =>
      (year - AppConstants.minYear) * 12 + (month - 1);

  static (int year, int month) indexToMonth(int index) {
    final year = AppConstants.minYear + index ~/ 12;
    final month = index % 12 + 1;
    return (year, month);
  }

  static int yearToIndex(int year) => year - AppConstants.minYear;

  static int dateToWeekIndex(DateTime date) {
    final epoch = DateTime(AppConstants.minYear, 1, 1);
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return monday.difference(epoch).inDays ~/ 7;
  }

  static DateTime weekIndexToMonday(int index) {
    final epoch = DateTime(AppConstants.minYear, 1, 1);
    return epoch.add(Duration(days: index * 7));
  }

  static int dateToDayIndex(DateTime date) {
    // Используем UTC, чтобы исключить погрешности перехода на летнее время
    final epoch = DateTime.utc(AppConstants.minYear, 1, 1);
    final dateUtc = DateTime.utc(date.year, date.month, date.day);
    return dateUtc.difference(epoch).inDays;
  }

  static DateTime dayIndexToDate(int index) {
    // Используем UTC, чтобы add(Duration(days:)) не давал 23:00 из-за DST
    final epoch = DateTime.utc(AppConstants.minYear, 1, 1);
    final utc = epoch.add(Duration(days: index));
    return DateTime(utc.year, utc.month, utc.day);
  }

  static int get totalWeeks {
    final start = DateTime(AppConstants.minYear, 1, 1);
    final end = DateTime(AppConstants.maxYear, 12, 31);
    return end.difference(start).inDays ~/ 7 + 1;
  }

  static int get totalDays {
    final start = DateTime(AppConstants.minYear, 1, 1);
    final end = DateTime(AppConstants.maxYear, 12, 31);
    return end.difference(start).inDays + 1;
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime stripTime(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
