import 'package:flutter/material.dart';

import 'package:calendar/core/constants/app_colors.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_state.dart';

/// Переключатель режима отображения календаря.
class ViewModeSelector extends StatelessWidget {
  final CalendarViewMode current;
  final ValueChanged<CalendarViewMode> onChanged;

  const ViewModeSelector({
    super.key,
    required this.current,
    required this.onChanged,
  });

  static const _modes = [
    (CalendarViewMode.year, 'Year'),
    (CalendarViewMode.month, 'Month'),
    (CalendarViewMode.week, 'Week'),
    (CalendarViewMode.day, 'Day'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _modes.map((entry) {
          final (mode, label) = entry;
          final isActive = mode == current;

          return GestureDetector(
            onTap: () => onChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isActive
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
