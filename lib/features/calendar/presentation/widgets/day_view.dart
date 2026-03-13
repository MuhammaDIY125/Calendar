import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';

import 'package:calendar/core/constants/app_colors.dart';
import 'package:calendar/core/utils/date_utils.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_event.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_state.dart';
import 'package:calendar/features/event/domain/entities/event.dart';

/// Высота одного часа в таймлайне (dp)
const _hourHeight = 60.0;

/// Вид «День» — PageView.builder по дням с вертикальным таймлайном.
class DayView extends StatefulWidget {
  const DayView({super.key});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final focused = context.read<CalendarBloc>().state.focusedDate;
    _pageController = PageController(
      initialPage: CalendarDateUtils.dateToDayIndex(focused),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final date = CalendarDateUtils.dayIndexToDate(index);
    final bloc = context.read<CalendarBloc>();
    bloc
      ..add(SelectDate(date))
      ..add(
        LoadEventsForRange(
          start: date.subtract(const Duration(days: 1)),
          end: date.add(const Duration(days: 1)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalendarBloc, CalendarState>(
      listenWhen: (prev, curr) =>
          prev.focusedDate != curr.focusedDate &&
          curr.viewMode == CalendarViewMode.day,
      listener: (_, state) {
        final target = CalendarDateUtils.dateToDayIndex(state.focusedDate);
        if (_pageController.hasClients &&
            _pageController.page?.round() != target) {
          _pageController.animateToPage(
            target,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: PageView.builder(
        controller: _pageController,
        itemCount: CalendarDateUtils.totalDays,
        onPageChanged: _onPageChanged,
        allowImplicitScrolling: true,
        itemBuilder: (_, index) {
          final date = CalendarDateUtils.dayIndexToDate(index);
          return _DayPage(date: date);
        },
      ),
    );
  }
}

class _DayPage extends StatefulWidget {
  final DateTime date;

  const _DayPage({required this.date});

  @override
  State<_DayPage> createState() => _DayPageState();
}

class _DayPageState extends State<_DayPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Прокручиваем к текущему часу или 8:00 по умолчанию
    final now = DateTime.now();
    final isToday = CalendarDateUtils.isSameDay(widget.date, now);
    final initialHour = isToday ? (now.hour - 1).clamp(0, 22) : 8;
    _scrollController = ScrollController(
      initialScrollOffset: initialHour * _hourHeight,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final isToday = CalendarDateUtils.isSameDay(widget.date, today);
    final dateLabel = DateFormat('EEEE, d MMMM').format(widget.date);

    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        final events = state.eventsForDate(widget.date);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок дня + кнопка добавления
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Text(
                    dateLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? AppColors.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push(
                      '/event/create',
                      extra: widget.date,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '+ Add Event',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Таймлайн
            Expanded(
              child: RepaintBoundary(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: SizedBox(
                    height: 24 * _hourHeight,
                    child: Stack(
                      children: [
                        // Часовые линии и метки
                        ...List.generate(24, (hour) => _HourLine(hour: hour)),
                        // Блоки событий
                        ...events.map(
                          (e) => _EventBlock(event: e),
                        ),
                        // Линия текущего времени
                        if (isToday) _CurrentTimeLine(now: today),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Горизонтальная линия с меткой часа
class _HourLine extends StatelessWidget {
  final int hour;

  const _HourLine({required this.hour});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = hour * _hourHeight;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                textAlign: TextAlign.right,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              height: 1,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

/// Блок события, позиционированный по времени начала и длительности
class _EventBlock extends StatelessWidget {
  final Event event;

  const _EventBlock({required this.event});

  @override
  Widget build(BuildContext context) {
    final startMinutes =
        event.startTime.hour * 60 + event.startTime.minute;
    final endMinutes = event.endTime.hour * 60 + event.endTime.minute;
    final durationMinutes =
        (endMinutes - startMinutes).clamp(15, 24 * 60).toDouble();

    final top = startMinutes / 60 * _hourHeight;
    final height = durationMinutes / 60 * _hourHeight;

    final accent = event.color.accentColor;
    final bg = event.color.backgroundColor;

    return Positioned(
      top: top,
      left: 52,
      right: 8,
      height: height,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: accent, width: 3),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              event.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (height > 30)
              Text(
                '${_fmt(event.startTime)} – ${_fmt(event.endTime)}',
                style: TextStyle(
                  fontSize: 10,
                  color: accent.withValues(alpha: 0.8),
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

/// Красная горизонтальная линия текущего времени
class _CurrentTimeLine extends StatelessWidget {
  final DateTime now;

  const _CurrentTimeLine({required this.now});

  @override
  Widget build(BuildContext context) {
    final top = (now.hour * 60 + now.minute) / 60 * _hourHeight;

    return Positioned(
      top: top,
      left: 44,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
