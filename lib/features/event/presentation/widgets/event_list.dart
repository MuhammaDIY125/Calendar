import 'package:flutter/material.dart';

import 'package:calendar/features/event/domain/entities/event.dart';
import 'package:calendar/features/event/presentation/widgets/event_card.dart';

/// Список карточек событий.
class EventList extends StatelessWidget {
  final List<Event> events;

  const EventList({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No events for this day',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (_, i) => EventCard(event: events[i]),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
    );
  }
}
