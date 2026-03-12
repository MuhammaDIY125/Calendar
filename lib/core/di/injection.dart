import 'package:get_it/get_it.dart';

import 'package:calendar/core/theme/theme_cubit.dart';
import 'package:calendar/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:calendar/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:calendar/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:calendar/features/event/data/datasources/event_local_datasource.dart';
import 'package:calendar/features/event/data/repositories/event_repository_impl.dart';
import 'package:calendar/features/event/domain/repositories/event_repository.dart';
import 'package:calendar/features/event/domain/usecases/create_event.dart';
import 'package:calendar/features/event/domain/usecases/delete_event.dart';
import 'package:calendar/features/event/domain/usecases/get_event_by_id.dart';
import 'package:calendar/features/event/domain/usecases/get_events_for_date.dart';
import 'package:calendar/features/event/domain/usecases/get_events_for_range.dart';
import 'package:calendar/features/event/domain/usecases/update_event.dart';
import 'package:calendar/features/event/presentation/bloc/event_bloc.dart';

final GetIt sl = GetIt.instance;

/// Регистрация всех зависимостей.
///
/// Порядок: DataSources → Repositories → UseCases → BloCs
Future<void> configureDependencies() async {
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerBlocs();
}

void _registerDataSources() {
  sl.registerLazySingleton<EventLocalDatasource>(
    () => EventLocalDatasourceImpl(),
  );
}

void _registerRepositories() {
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<CalendarRepository>(
    () => CalendarRepositoryImpl(sl()),
  );
}

void _registerUseCases() {
  sl
    ..registerLazySingleton(() => CreateEvent(sl()))
    ..registerLazySingleton(() => UpdateEvent(sl()))
    ..registerLazySingleton(() => DeleteEvent(sl()))
    ..registerLazySingleton(() => GetEventsForDate(sl()))
    ..registerLazySingleton(() => GetEventsForRange(sl()))
    ..registerLazySingleton(() => GetEventById(sl()));
}

void _registerBlocs() {
  // ThemeCubit — синглтон (сохраняет состояние темы)
  sl.registerLazySingleton(() => ThemeCubit());

  // Фабрика — новый экземпляр при каждом запросе
  sl.registerFactory(() => CalendarBloc(sl()));
  sl.registerFactory(
    () => EventBloc(
      createEvent: sl(),
      updateEvent: sl(),
      deleteEvent: sl(),
      getEventsForDate: sl(),
      getEventById: sl(),
    ),
  );
}
