import 'dart:math';

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

/// Ширина области временных меток слева
const _labelsWidth = 52.0;

/// Отступ от правого края
const _rightPad = 8.0;

/// Зазор между параллельными событиями в соседних колонках
const _colGap = 4.0;

/// Минимальная высота блока события — гарантирует видимость названия
const _minEventHeight = 28.0;

// ---------------------------------------------------------------------------
// Раскладка событий по колонкам
// ---------------------------------------------------------------------------

/// Позиция события в таймлайне: в какой колонке и сколько всего колонок в группе.
class _EventLayout {
  final Event event;
  final int column;
  final int totalColumns;

  const _EventLayout({
    required this.event,
    required this.column,
    required this.totalColumns,
  });
}

int _startMin(Event e) => e.startTime.hour * 60 + e.startTime.minute;

int _endMin(Event e) {
  final raw = e.endTime.hour * 60 + e.endTime.minute;
  return _startMin(e) + (raw - _startMin(e)).clamp(15, 24 * 60);
}

/// Жадный алгоритм: распределяем события по колонкам так, чтобы
/// пересекающиеся по времени события стояли рядом, а не друг на друге.
List<_EventLayout> _computeEventLayouts(List<Event> events) {
  if (events.isEmpty) return [];

  final sorted = [...events]
    ..sort((a, b) => _startMin(a).compareTo(_startMin(b)));

  // columnEnds[i] — минута окончания последнего события в колонке i
  final columnEnds = <int>[];
  final assignments = <int>[];

  for (final event in sorted) {
    final start = _startMin(event);
    final end = _endMin(event);

    // Ищем первую свободную колонку
    int col = -1;
    for (int i = 0; i < columnEnds.length; i++) {
      if (columnEnds[i] <= start) {
        col = i;
        break;
      }
    }
    if (col == -1) {
      col = columnEnds.length;
      columnEnds.add(end);
    } else {
      columnEnds[col] = end;
    }
    assignments.add(col);
  }

  // Для каждого события определяем число колонок в его «группе»
  // (максимальная колонка среди всех перекрывающих событий + 1)
  return List.generate(sorted.length, (i) {
    final startA = _startMin(sorted[i]);
    final endA = _endMin(sorted[i]);

    int maxCol = assignments[i];
    for (int j = 0; j < sorted.length; j++) {
      if (i == j) continue;
      final startB = _startMin(sorted[j]);
      final endB = _endMin(sorted[j]);
      if (startB < endA && endB > startA) {
        maxCol = max(maxCol, assignments[j]);
      }
    }

    return _EventLayout(
      event: sorted[i],
      column: assignments[i],
      totalColumns: maxCol + 1,
    );
  });
}

// ---------------------------------------------------------------------------
// DayView — PageView.builder по дням
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// _DayPage
// ---------------------------------------------------------------------------

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
        final layouts = _computeEventLayouts(events);

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
                    onTap: () =>
                        context.push('/event/create', extra: widget.date),
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
                    // LayoutBuilder нужен, чтобы узнать реальную ширину
                    // и правильно разбить параллельные события по колонкам
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final availableWidth =
                            constraints.maxWidth - _labelsWidth - _rightPad;
                        return Stack(
                          children: [
                            // Часовые линии и метки
                            ...List.generate(
                              24,
                              (hour) => _HourLine(hour: hour),
                            ),
                            // Блоки событий с колоночной раскладкой
                            ...layouts.map(
                              (layout) => _EventBlock(
                                event: layout.event,
                                column: layout.column,
                                totalColumns: layout.totalColumns,
                                availableWidth: availableWidth,
                              ),
                            ),
                            // Линия текущего времени
                            if (isToday) _CurrentTimeLine(now: today),
                          ],
                        );
                      },
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

// ---------------------------------------------------------------------------
// Вспомогательные виджеты
// ---------------------------------------------------------------------------

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
            width: _labelsWidth,
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

/// Блок события, позиционированный по времени начала и длительности.
/// При наличии параллельных событий занимает долю ширины (свою колонку).
class _EventBlock extends StatelessWidget {
  final Event event;
  final int column;
  final int totalColumns;
  final double availableWidth;

  const _EventBlock({
    required this.event,
    required this.column,
    required this.totalColumns,
    required this.availableWidth,
  });

  @override
  Widget build(BuildContext context) {
    final startMinutes = _startMin(event);
    final durationMinutes = (_endMin(event) - startMinutes)
        .clamp(15, 24 * 60)
        .toDouble();

    final top = startMinutes / 60 * _hourHeight;
    final rawHeight = durationMinutes / 60 * _hourHeight;
    // Минимум _minEventHeight, максимум — до конца таймлайна
    final height = rawHeight.clamp(_minEventHeight, 24 * _hourHeight - top);

    // Ширина колонки; последняя колонка не имеет правого зазора
    final colWidth = availableWidth / totalColumns;
    final left = _labelsWidth + column * colWidth;
    final width = colWidth - (column < totalColumns - 1 ? _colGap : 0);

    final accent = event.color.accentColor;
    final bg = event.color.backgroundColor;

    return Positioned(
      top: top,
      left: left,
      width: width,
      height: height,
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: accent, width: 3)),
        ),
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        // OverflowBox даёт Column неограниченную высоту — она берёт ровно столько,
        // сколько нужно тексту, без RenderFlex overflow. Визуально обрезает
        // clipBehavior: Clip.hardEdge на Container.
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minHeight: 0,
          maxHeight: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              if (height > 42)
                Text(
                  '${_fmt(event.startTime)} – ${_fmt(event.endTime)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: accent.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
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
          Expanded(child: Container(height: 1.5, color: Colors.red)),
        ],
      ),
    );
  }
}
