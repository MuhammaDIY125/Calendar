import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:calendar/core/constants/app_colors.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_event.dart';
import 'package:calendar/features/event/domain/entities/event.dart';
import 'package:calendar/features/event/presentation/bloc/event_bloc.dart';
import 'package:calendar/features/event/presentation/bloc/event_event.dart';
import 'package:calendar/features/event/presentation/bloc/event_state.dart';

class EventDetailPage extends StatefulWidget {
  final int eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(LoadEventById(widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventDeleted) {
          // Инвалидируем кэш CalendarBloc после удаления
          final now = DateTime.now();
          context.read<CalendarBloc>().add(
                InvalidateCacheForRange(
                  start: DateTime(now.year, now.month - 1, 1),
                  end: DateTime(now.year, now.month + 2, 0),
                ),
              );
          context.pop();
        } else if (state is EventError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading || state is EventInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is EventLoaded) {
            return _DetailView(event: state.event);
          }
          if (state is EventError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text(state.message)),
            );
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  final Event event;

  const _DetailView({required this.event});

  @override
  Widget build(BuildContext context) {
    final accent = event.color.accentColor;
    final timeLabel =
        '${_fmt(event.startTime)} – ${_fmt(event.endTime)}';

    return Scaffold(
      body: Column(
        children: [
          // Верхняя секция с градиентом
          _Header(event: event, accent: accent, timeLabel: timeLabel),
          // Нижняя секция с деталями
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.reminderMinutes != null) ...[
                    _DetailRow(
                      label: 'Reminder',
                      value: _reminderLabel(event.reminderMinutes!),
                      icon: Icons.notifications_none_rounded,
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (event.description.isNotEmpty) ...[
                    _DetailRow(
                      label: 'Description',
                      value: event.description,
                      icon: Icons.notes_rounded,
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Кнопка Delete
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: _DeleteButton(event: event),
          ),
        ],
      ),
    );
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _reminderLabel(int minutes) => switch (minutes) {
        5 => '5 minutes before',
        15 => '15 minutes before',
        30 => '30 minutes before',
        60 => '1 hour before',
        1440 => '1 day before',
        _ => '$minutes minutes before',
      };
}

class _Header extends StatelessWidget {
  final Event event;
  final Color accent;
  final String timeLabel;

  const _Header({
    required this.event,
    required this.accent,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent,
            Color.fromARGB(
              255,
              (accent.r * 0.75).round(),
              (accent.g * 0.75).round(),
              (accent.b * 0.75).round(),
            ),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Кнопки навигации
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => context.pop(),
                  ),
                  GestureDetector(
                    onTap: () =>
                        context.push('/event/${event.id}/edit'),
                    child: const Row(
                      children: [
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.edit_outlined,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Название
              Text(
                event.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (event.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              // Время
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      color: Colors.white.withValues(alpha: 0.85), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    timeLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (event.location.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: Colors.white.withValues(alpha: 0.85), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      event.location,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final Event event;

  const _DeleteButton({required this.event});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _confirmDelete(context),
        style: TextButton.styleFrom(
          backgroundColor: AppColors.deleteBackground,
          foregroundColor: AppColors.deleteText,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.delete_outline_rounded, size: 20),
        label: const Text(
          'Delete Event',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.deleteText),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<EventBloc>().add(DeleteEventRequested(event.id!));
    }
  }
}
