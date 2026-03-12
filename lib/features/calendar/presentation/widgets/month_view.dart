import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:calendar/core/constants/app_constants.dart';
import 'package:calendar/core/utils/date_utils.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_event.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_state.dart';
import 'package:calendar/features/calendar/presentation/widgets/calendar_grid.dart';
import 'package:calendar/features/calendar/presentation/widgets/month_header.dart';

/// Вид «Месяц» — PageView.builder по всем месяцам диапазона 1950–2950.
class MonthView extends StatefulWidget {
  const MonthView({super.key});

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final state = context.read<CalendarBloc>().state;
    final initialPage = CalendarDateUtils.monthToIndex(
      state.focusedDate.year,
      state.focusedDate.month,
    );
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final (year, month) = CalendarDateUtils.indexToMonth(index);
    final bloc = context.read<CalendarBloc>();

    final start = DateTime(year, month - 1, 1);
    final end = DateTime(year, month + 2, 0);

    bloc
      ..add(SelectDate(DateTime(year, month, 1)))
      ..add(LoadEventsForRange(start: start, end: end));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalendarBloc, CalendarState>(
      // Синхронизация PageView при навигации через кнопки стрелок
      listenWhen: (prev, curr) =>
          prev.focusedDate != curr.focusedDate &&
          curr.viewMode == CalendarViewMode.month,
      listener: (_, state) {
        final targetPage = CalendarDateUtils.monthToIndex(
          state.focusedDate.year,
          state.focusedDate.month,
        );
        if (_pageController.hasClients &&
            _pageController.page?.round() != targetPage) {
          _pageController.animateToPage(
            targetPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: BlocBuilder<CalendarBloc, CalendarState>(
        builder: (context, state) {
          return PageView.builder(
            controller: _pageController,
            itemCount: AppConstants.totalMonths,
            onPageChanged: _onPageChanged,
            itemBuilder: (_, index) {
              final (year, month) = CalendarDateUtils.indexToMonth(index);
              return _MonthPage(
                year: year,
                month: month,
                state: state,
              );
            },
          );
        },
      ),
    );
  }
}

class _MonthPage extends StatelessWidget {
  final int year;
  final int month;
  final CalendarState state;

  const _MonthPage({
    required this.year,
    required this.month,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MonthHeader(
            year: year,
            month: month,
            onPrevious: () =>
                context.read<CalendarBloc>().add(const NavigateToPrevious()),
            onNext: () =>
                context.read<CalendarBloc>().add(const NavigateToNext()),
          ),
          const SizedBox(height: 8),
          CalendarGrid(
            year: year,
            month: month,
            selectedDate: state.selectedDate,
            cachedEvents: state.cachedEvents,
            onDateSelected: (date) =>
                context.read<CalendarBloc>().add(SelectDate(date)),
          ),
        ],
      ),
    );
  }
}
