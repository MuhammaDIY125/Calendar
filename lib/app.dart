import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:calendar/core/di/injection.dart';
import 'package:calendar/core/theme/app_theme.dart';
import 'package:calendar/core/theme/theme_cubit.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:calendar/features/event/presentation/bloc/event_bloc.dart';
import 'package:calendar/features/calendar/presentation/pages/calendar_page.dart';
import 'package:calendar/features/event/presentation/pages/event_create_page.dart';
import 'package:calendar/features/event/presentation/pages/event_detail_page.dart';
import 'package:calendar/features/event/presentation/pages/event_edit_page.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const CalendarPage(),
    ),
    GoRoute(
      path: '/event/create',
      builder: (_, state) => EventCreatePage(
        selectedDate: state.extra as DateTime?,
      ),
    ),
    GoRoute(
      path: '/event/:id',
      builder: (_, state) => EventDetailPage(
        eventId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/event/:id/edit',
      builder: (_, state) => EventEditPage(
        eventId: int.parse(state.pathParameters['id']!),
      ),
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => sl<ThemeCubit>()..loadTheme(),
        ),
        BlocProvider<CalendarBloc>(
          create: (_) => sl<CalendarBloc>(),
        ),
        BlocProvider<EventBloc>(
          create: (_) => sl<EventBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (_, themeMode) => MaterialApp.router(
          title: 'Calendar',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
