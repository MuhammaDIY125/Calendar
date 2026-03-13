import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

import 'package:calendar/core/constants/app_colors.dart';
import 'package:calendar/core/utils/date_utils.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_event.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_state.dart';
import 'package:calendar/features/event/presentation/widgets/event_list.dart';

/// Вид «Неделя» — горизонтальная полоса 7 дней + список событий выбранного дня.
class WeekView extends StatefulWidget {
  const WeekView({super.key});

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final focused = context.read<CalendarBloc>().state.focusedDate;
    _pageController = PageController(
      initialPage: CalendarDateUtils.dateToWeekIndex(focused),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final monday = CalendarDateUtils.weekIndexToMonday(index);
    final bloc = context.read<CalendarBloc>();
    bloc.add(
      LoadEventsForRange(
        start: monday.subtract(const Duration(days: 7)),
        end: monday.add(const Duration(days: 13)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalendarBloc, CalendarState>(
      listenWhen: (prev, curr) =>
          prev.focusedDate != curr.focusedDate &&
          curr.viewMode == CalendarViewMode.week,
      listener: (_, state) {
        final target = CalendarDateUtils.dateToWeekIndex(state.focusedDate);
        if (_pageController.hasClients &&
            _pageController.page?.round() != target) {
          _pageController.animateToPage(
            target,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      // PageView не оборачивается в BlocBuilder — каждая полоса
      // получает стейт через собственный BlocBuilder внутри.
      child: Column(
        children: [
          // Полоса 7 дней
          SizedBox(
            height: 80,
            child: PageView.builder(
              controller: _pageController,
              itemCount: CalendarDateUtils.totalWeeks,
              onPageChanged: _onPageChanged,
              allowImplicitScrolling: true,
              itemBuilder: (_, index) {
                final monday = CalendarDateUtils.weekIndexToMonday(index);
                return _WeekStripPage(monday: monday);
              },
            ),
          ),
          const Divider(height: 1),
          // Schedule заголовок + кнопка добавления
          BlocBuilder<CalendarBloc, CalendarState>(
            buildWhen: (prev, curr) => prev.selectedDate != curr.selectedDate,
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Text(
                      'Schedule',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push(
                        '/event/create',
                        extra: state.selectedDate,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
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
                    ),
                  ],
                ),
              );
            },
          ),
          // Список событий выбранного дня
          Expanded(
            child: BlocBuilder<CalendarBloc, CalendarState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: EventList(
                    events: state.eventsForDate(state.selectedDate),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Одна страница полосы дней недели — имеет собственный BlocBuilder.
class _WeekStripPage extends StatelessWidget {
  final DateTime monday;

  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  const _WeekStripPage({required this.monday});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) => _buildStrip(context, state.selectedDate),
    );
  }

  Widget _buildStrip(BuildContext context, DateTime selectedDate) {
    final today = DateTime.now();

    return Row(
      children: List.generate(7, (i) {
        final date = monday.add(Duration(days: i));
        final isToday = CalendarDateUtils.isSameDay(date, today);
        final isSelected = CalendarDateUtils.isSameDay(date, selectedDate);

        return Expanded(
          child: GestureDetector(
            onTap: () => context.read<CalendarBloc>().add(SelectDate(date)),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _dayLetters[i],
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.primary
                        : isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isToday || isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isToday
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
