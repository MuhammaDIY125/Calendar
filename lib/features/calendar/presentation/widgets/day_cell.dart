import 'package:flutter/material.dart';

import 'package:calendar/core/constants/app_colors.dart';
import 'package:calendar/features/calendar/presentation/widgets/event_dots.dart';
import 'package:calendar/features/event/domain/entities/event.dart';

/// Ячейка одного дня в сетке месяца.
class DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final bool isCurrentMonth;
  final List<Event> events;
  final VoidCallback onTap;

  const DayCell({
    super.key,
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isCurrentMonth,
    required this.events,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Цвет фона кружка и текста зависит от состояния ячейки
    final Color? circleColor = isToday || isSelected ? AppColors.primary : null;
    final Color textColor = switch (true) {
      _ when isToday || isSelected => Colors.white,
      _ when !isCurrentMonth => theme.colorScheme.onSurface.withValues(alpha: 0.3),
      _ => theme.colorScheme.onSurface,
    };

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: circleColor != null
                ? BoxDecoration(color: circleColor, shape: BoxShape.circle)
                : null,
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(height: 2),
          EventDots(events: events),
        ],
      ),
    );
  }
}
