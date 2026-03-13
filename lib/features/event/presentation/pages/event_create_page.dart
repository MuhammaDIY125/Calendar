import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:calendar/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_event.dart';
import 'package:calendar/features/event/domain/entities/event.dart';
import 'package:calendar/features/event/presentation/bloc/event_bloc.dart';
import 'package:calendar/features/event/presentation/bloc/event_event.dart';
import 'package:calendar/features/event/presentation/bloc/event_state.dart';
import 'package:calendar/features/event/presentation/widgets/event_form.dart';

class EventCreatePage extends StatelessWidget {
  final DateTime? selectedDate;

  const EventCreatePage({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventCreated) {
            // Инвалидируем кэш CalendarBloc, чтобы точки обновились
            final date = state.event.date;
            context.read<CalendarBloc>().add(
              InvalidateCacheForRange(
                start: DateTime(date.year, date.month - 1, 1),
                end: DateTime(date.year, date.month + 2, 0),
              ),
            );
            context.pop();
          } else if (state is EventError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: EventForm(
          submitLabel: 'Add',
          onSubmit: (data) {
            final now = DateTime.now();
            final date = selectedDate ?? now;

            context.read<EventBloc>().add(
              CreateEventRequested(
                Event(
                  name: data.name,
                  description: data.description,
                  location: data.location,
                  date: DateTime(date.year, date.month, date.day),
                  startTime: data.startTime,
                  endTime: data.endTime,
                  color: data.color,
                  reminderMinutes: data.reminderMinutes,
                  createdAt: now,
                  updatedAt: now,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
