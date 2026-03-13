import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:calendar/core/constants/app_constants.dart';
import 'package:calendar/features/event/domain/entities/event.dart';

/// Карточка события с цветной полосой сверху.
class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = event.color.accentColor;
    final bg = event.color.backgroundColor;
    // Более тёмный оттенок accent для текста и иконок
    final hsl = HSLColor.fromColor(accent);
    final accentDark = !isDark
        ? hsl
              .withLightness((hsl.lightness - 0.25).clamp(0.0, 1.0))
              .withSaturation((hsl.saturation + 0.1).clamp(0.0, 1.0))
              .toColor()
        : hsl.withLightness((hsl.lightness + 0.25).clamp(0.0, 1.0)).toColor();
    final timeLabel = '${_fmt(event.startTime)} - ${_fmt(event.endTime)}';

    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Цветная полоса сверху
            Container(
              height: AppConstants.cardBorderRadius,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.cardBorderRadius),
                  topRight: Radius.circular(AppConstants.cardBorderRadius),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название события
                  Text(
                    event.name,
                    style: TextStyle(
                      color: accentDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      event.description,
                      style: TextStyle(color: accentDark, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Время и локация
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_filled_rounded,
                        size: 15,
                        color: accentDark,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        timeLabel,
                        style: TextStyle(color: accentDark, fontSize: 12),
                      ),
                      if (event.location.isNotEmpty) ...[
                        const SizedBox(width: 14),
                        Icon(
                          Icons.location_on_rounded,
                          size: 15,
                          color: accentDark,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(color: accentDark, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
