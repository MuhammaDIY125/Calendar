import 'package:flutter/material.dart';

import 'package:calendar/features/event/domain/entities/event_color.dart';

/// Дропдаун выбора цвета приоритета события.
class EventColorPicker extends StatelessWidget {
  final EventColor value;
  final ValueChanged<EventColor> onChanged;

  const EventColorPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<EventColor>(
      initialValue: value,
      decoration: InputDecoration(
        hintText: 'Priority color',
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value.accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      items: EventColor.values
          .map(
            (color) => DropdownMenuItem(
              value: color,
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color.accentColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(color.displayName),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (c) {
        if (c != null) onChanged(c);
      },
    );
  }
}
