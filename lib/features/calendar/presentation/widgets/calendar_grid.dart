import 'package:flutter/material.dart';

import 'package:calendar/core/utils/date_utils.dart';
import 'package:calendar/features/calendar/presentation/widgets/day_cell.dart';
import 'package:calendar/features/event/domain/entities/event.dart';

/// Сетка дней одного месяца (7 столбцов × N строк).
class CalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final DateTime selectedDate;
  final Map<DateTime, List<Event>> cachedEvents;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarGrid({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDate,
    required this.cachedEvents,
    required this.onDateSelected,
  });

  static const _weekLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final firstWeekday = CalendarDateUtils.firstWeekdayOfMonth(year, month);
    final daysInMonth = CalendarDateUtils.daysInMonth(year, month);
    final totalCells = firstWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        // Заголовок дней недели
        Row(
          children: _weekLabels
              .map(
                (label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 4),
        // Сетка дат
        for (int row = 0; row < rows; row++)
          Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNumber = cellIndex - firstWeekday + 1;

              // Ячейки до первого числа и после последнего — пустые
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 48));
              }

              final date = DateTime(year, month, dayNumber);
              final isToday = CalendarDateUtils.isSameDay(date, today);
              final isSelected =
                  CalendarDateUtils.isSameDay(date, selectedDate);
              final events = cachedEvents[
                      DateTime(date.year, date.month, date.day)] ??
                  [];

              return Expanded(
                child: SizedBox(
                  height: 48,
                  child: DayCell(
                    day: dayNumber,
                    isToday: isToday,
                    isSelected: isSelected && !isToday,
                    isCurrentMonth: true,
                    events: events,
                    onTap: () => onDateSelected(date),
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }
}
