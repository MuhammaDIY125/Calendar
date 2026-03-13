import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:calendar/core/constants/app_colors.dart';
import 'package:calendar/core/theme/theme_cubit.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_event.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_state.dart';
import 'package:calendar/features/calendar/presentation/widgets/day_view.dart';
import 'package:calendar/features/calendar/presentation/widgets/month_view.dart';
import 'package:calendar/features/calendar/presentation/widgets/view_mode_selector.dart';
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
                const SizedBox(height: 8),
                Center(
                  child: ViewModeSelector(
                    current: state.viewMode,
                    onChanged: (mode) =>
                        context.read<CalendarBloc>().add(ChangeViewMode(mode)),
                  ),
                ),
                const SizedBox(height: 8),
                // Year/Week/Day — занимают всё пространство (имеют свои списки)
                if (state.viewMode == CalendarViewMode.year)
                  const Expanded(child: YearView())
                else if (state.viewMode == CalendarViewMode.week)
                  const Expanded(child: WeekView())
                else if (state.viewMode == CalendarViewMode.day)
                  const Expanded(child: DayView())
                else ...[
                  // Month — календарь + секция Schedule снизу
                  const SizedBox(height: 360, child: MonthView()),
                  const SizedBox(height: 4),
                  Expanded(
                    child: _ScheduleSection(
                      events: state.eventsForDate(state.selectedDate),
                      selectedDate: state.selectedDate,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

}

/// Шапка страницы: день недели по центру крупным жирным,
/// дата мелким с chevron, колокольчик справа.
class _Header extends StatelessWidget {
  final DateTime selectedDate;

  const _Header({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayOfWeek = DateFormat('EEEE').format(selectedDate);
    final fullDate = DateFormat('d MMMM yyyy').format(selectedDate);
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.55);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Центральный блок: день + дата
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dayOfWeek,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fullDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondaryColor,
                        fontSize: 13,
                      ),
                    ),
                    // Icon(
                    //   Icons.keyboard_arrow_down_rounded,
                    //   size: 16,
                    //   color: secondaryColor,
                    // ),
                  ],
                ),
              ],
            ),
            // Кнопка смены темы — слева
            Positioned(left: 0, child: _ThemeToggleButton()),
            // Колокольчик — прижат к правому краю
            Positioned(right: 0, child: _BellIcon()),
          ],
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark =
            themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);
        return GestureDetector(
          onTap: () => context.read<ThemeCubit>().toggle(),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 24,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        );
      },
    );
  }
}

class _BellIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          Icons.notifications_rounded,
          size: 28,
          color: theme.colorScheme.onSurface,
        ),
        Positioned(
          top: 1,
          right: 1,
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
    );
  }
}

/// Секция расписания с заголовком и списком событий.
class _ScheduleSection extends StatelessWidget {
  final List events;
  final DateTime selectedDate;

  const _ScheduleSection({required this.events, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Schedule',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              _AddEventButton(selectedDate: selectedDate),
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

class _AddEventButton extends StatelessWidget {
  final DateTime selectedDate;

  const _AddEventButton({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/event/create', extra: selectedDate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '+ Add Event',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
