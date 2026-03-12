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

class EventEditPage extends StatefulWidget {
  final int eventId;

  const EventEditPage({super.key, required this.eventId});

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(LoadEventById(widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Edit Event'),
      ),
      body: BlocConsumer<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventUpdated) {
            // Инвалидируем кэш CalendarBloc
            final date = state.event.date;
            context.read<CalendarBloc>().add(
                  LoadEventsForRange(
                    start: DateTime(date.year, date.month - 1, 1),
                    end: DateTime(date.year, date.month + 2, 0),
                  ),
                );
            // Возвращаемся на страницу деталей
            context.pop();
          } else if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is EventLoading || state is EventInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EventLoaded) {
            return _EditForm(event: state.event);
          }
          if (state is EventError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _EditForm extends StatelessWidget {
  final Event event;

  const _EditForm({required this.event});

  @override
  Widget build(BuildContext context) {
    return EventForm(
      submitLabel: 'Save',
      initialData: EventFormData(
        name: event.name,
        description: event.description,
        location: event.location,
        color: event.color,
        startTime: event.startTime,
        endTime: event.endTime,
        reminderMinutes: event.reminderMinutes,
      ),
      onSubmit: (data) {
        context.read<EventBloc>().add(
              UpdateEventRequested(
                event.copyWith(
                  name: data.name,
                  description: data.description,
                  location: data.location,
                  color: data.color,
                  startTime: data.startTime,
                  endTime: data.endTime,
                  reminderMinutes: data.reminderMinutes,
                  clearReminder: data.reminderMinutes == null,
                  updatedAt: DateTime.now(),
                ),
              ),
            );
      },
    );
  }
}
