import 'package:flutter/material.dart';

import 'package:calendar/core/constants/app_colors.dart';
import 'package:calendar/features/event/domain/entities/event_color.dart';

/// Компактный выбор цвета приоритета — квадратик текущего цвета + chevron.
/// При нажатии — показывает popup с вариантами.
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

    return GestureDetector(
      onTap: () => _showColorMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: value.accentColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 22,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showColorMenu(BuildContext context) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu<EventColor>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height + 4,
        offset.dx + renderBox.size.width,
        0,
      ),
      items: EventColor.values.map((color) {
        return PopupMenuItem(
          value: color,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color.accentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(color.displayName),
            ],
          ),
        );
      }).toList(),
    ).then((selected) {
      if (selected != null) onChanged(selected);
    });
  }
}
