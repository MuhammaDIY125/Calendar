import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:calendar/core/constants/app_colors.dart';
import 'package:calendar/core/theme/theme_cubit.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_event.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_state.dart';
import 'package:calendar/features/calendar/presentation/widgets/month_view.dart';
import 'package:calendar/features/calendar/presentation/widgets/view_mode_selector.dart';
import 'package:calendar/features/calendar/presentation/widgets/day_view.dart';
import 'package:calendar/features/calendar/presentation/widgets/week_view.dart';
import 'package:calendar/features/calendar/presentation/widgets/year_view.dart';
import 'package:calendar/features/event/presentation/widgets/event_list.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    super.initState();
    // Загрузка событий при старте для текущего месяца ± 1
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      context.read<CalendarBloc>().add(
            LoadEventsForRange(
              start: DateTime(now.year, now.month - 1, 1),
              end: DateTime(now.year, now.month + 2, 0),
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(selectedDate: state.selectedDate),
                const SizedBox(height: 12),
                Center(
                  child: ViewModeSelector(
                    current: state.viewMode,
                    onChanged: (mode) => context
                        .read<CalendarBloc>()
                        .add(ChangeViewMode(mode)),
                  ),
                ),
                const SizedBox(height: 16),
                // Календарный вид
                _buildCalendarView(state),
                const SizedBox(height: 16),
                // Секция Schedule
                Expanded(
                  child: _ScheduleSection(
                    events: state.eventsForDate(state.selectedDate),
                    selectedDate: state.selectedDate,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarView(CalendarState state) {
    return switch (state.viewMode) {
      CalendarViewMode.year => const SizedBox(
          height: 400,
          child: YearView(),
        ),
      CalendarViewMode.month => const SizedBox(
          height: 320,
          child: MonthView(),
        ),
      CalendarViewMode.week => const SizedBox(
          height: 400,
          child: WeekView(),
        ),
      CalendarViewMode.day => const SizedBox(
          height: 400,
          child: DayView(),
        ),
    };
  }
}

class _Header extends StatelessWidget {
  final DateTime selectedDate;

  const _Header({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayOfWeek = DateFormat('EEEE').format(selectedDate);
    final fullDate = DateFormat('d MMMM yyyy').format(selectedDate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayOfWeek,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                fullDate,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Кнопка переключения темы
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = themeMode == ThemeMode.dark ||
                  (themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);
              return GestureDetector(
                onTap: () => context.read<ThemeCubit>().toggle(),
                child: Icon(
                  isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  size: 24,
                  color: theme.colorScheme.onSurface,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          // Иконка колокольчика с синей точкой
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 26,
                color: theme.colorScheme.onSurface,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  final List events;
  final DateTime selectedDate;

  const _ScheduleSection({
    required this.events,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Schedule',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push(
                  '/event/create',
                  extra: selectedDate,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Add Event',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: EventList(events: events.cast()),
          ),
        ),
      ],
    );
  }
}
