import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:calendar/core/constants/app_colors.dart';
import 'package:calendar/core/constants/app_constants.dart';
import 'package:calendar/core/utils/date_utils.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_event.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_state.dart';

/// Вид «Год» — PageView.builder по годам, сетка 4×3 из мини-месяцев.
class YearView extends StatefulWidget {
  const YearView({super.key});

  @override
  State<YearView> createState() => _YearViewState();
}

class _YearViewState extends State<YearView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final year = context.read<CalendarBloc>().state.focusedDate.year;
    _pageController = PageController(
      initialPage: CalendarDateUtils.yearToIndex(year),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalendarBloc, CalendarState>(
      listenWhen: (prev, curr) =>
          prev.focusedDate.year != curr.focusedDate.year &&
          curr.viewMode == CalendarViewMode.year,
      listener: (_, state) {
        final target = CalendarDateUtils.yearToIndex(state.focusedDate.year);
        if (_pageController.hasClients &&
            _pageController.page?.round() != target) {
          _pageController.animateToPage(
            target,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      // PageView не оборачивается в BlocBuilder — каждая страница
      // получает стейт через собственный BlocBuilder внутри.
      child: PageView.builder(
        controller: _pageController,
        itemCount: AppConstants.totalYears,
        allowImplicitScrolling: true,
        onPageChanged: (index) {
          final year = AppConstants.minYear + index;
          context.read<CalendarBloc>().add(
            LoadEventsForRange(
              start: DateTime(year, 1, 1),
              end: DateTime(year, 12, 31),
            ),
          );
        },
        itemBuilder: (_, index) {
          final year = AppConstants.minYear + index;
          return _YearPage(year: year);
        },
      ),
    );
  }
}

/// Страница одного года — имеет собственный BlocBuilder.
class _YearPage extends StatelessWidget {
  final int year;

  const _YearPage({required this.year});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        final theme = Theme.of(context);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              // Заголовок года
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '$year',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Сетка 4×3
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (_, monthIndex) {
                  final month = monthIndex + 1;
                  return _MiniMonth(year: year, month: month, state: state);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniMonth extends StatelessWidget {
  final int year;
  final int month;
  final CalendarState state;

  const _MiniMonth({
    required this.year,
    required this.month,
    required this.state,
  });

  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final isCurrentMonth = year == today.year && month == today.month;

    return GestureDetector(
      onTap: () {
        final bloc = context.read<CalendarBloc>();
        final date = DateTime(year, month, 1);
        bloc
          ..add(ChangeViewMode(CalendarViewMode.month))
          ..add(SelectDate(date));
      },
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentMonth
              ? AppColors.primary.withValues(alpha: 0.07)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: isCurrentMonth
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Название месяца
            Text(
              _monthNames[month - 1],
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isCurrentMonth
                    ? AppColors.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            // Мини-сетка дней
            Expanded(
              child: _MiniGrid(year: year, month: month, state: state),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniGrid extends StatelessWidget {
  final int year;
  final int month;
  final CalendarState state;

  const _MiniGrid({
    required this.year,
    required this.month,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final firstWeekday = CalendarDateUtils.firstWeekdayOfMonth(year, month);
    final daysInMonth = CalendarDateUtils.daysInMonth(year, month);
    final totalCells = firstWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    // Мелкий стиль для чисел
    final cellStyle = TextStyle(
      fontSize: 7,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
    );
    const cellSize = 11.0;

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (col) {
            final cellIndex = row * 7 + col;
            final dayNumber = cellIndex - firstWeekday + 1;

            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return SizedBox(width: cellSize, height: cellSize);
            }

            final date = DateTime(year, month, dayNumber);
            final isToday = CalendarDateUtils.isSameDay(date, today);

            // Проверяем есть ли события в кэше
            final hasEvents =
                (state.cachedEvents[DateTime(
                          date.year,
                          date.month,
                          date.day,
                        )] ??
                        [])
                    .isNotEmpty;

            return SizedBox(
              width: cellSize,
              height: cellSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isToday)
                    Container(
                      width: cellSize,
                      height: cellSize,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    '$dayNumber',
                    style: cellStyle.copyWith(
                      color: isToday
                          ? Colors.white
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Точка события внизу ячейки
                  if (hasEvents && !isToday)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        );
      }),
    );
  }
}
