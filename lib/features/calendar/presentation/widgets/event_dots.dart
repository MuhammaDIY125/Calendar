import 'package:flutter/material.dart';

import 'package:calendar/core/constants/app_constants.dart';
import 'package:calendar/features/event/domain/entities/event.dart';

/// Ряд цветных точек под датой — каждая точка соответствует одному событию.
///
/// Отображает не более [AppConstants.maxEventDotsVisible] точек.
class EventDots extends StatelessWidget {
  final List<Event> events;

  const EventDots({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    final visible = events.take(AppConstants.maxEventDotsVisible).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: visible
          .map(
            (e) => Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: e.color.accentColor,
                shape: BoxShape.circle,
              ),
            ),
          )
          .toList(),
    );
  }
}
