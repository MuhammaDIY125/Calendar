import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:calendar/features/event/presentation/bloc/event_event.dart';
import 'package:calendar/features/event/presentation/bloc/event_state.dart';

// Заглушка — будет заменена в Шаге 8
class EventBloc extends Bloc<EventEvent, EventState> {
  EventBloc() : super(const EventInitial());
}
