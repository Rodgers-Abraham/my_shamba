import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/calendar_repository.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final CalendarRepository repository;

  CalendarBloc({required this.repository}) : super(CalendarInitial()) {
    on<LoadCalendar>((event, emit) async {
      emit(CalendarLoading());
      final result = await repository.getEntries(event.farmId);
      emit(result.fold(
        (f) => CalendarError(f.message),
        (entries) => CalendarLoaded(entries),
      ));
    });

    on<AddCalendarEntry>((event, emit) async {
      await repository.addEntry(event.entry);
      add(LoadCalendar(event.entry.farmId));
    });

    on<ToggleEntryCompletion>((event, emit) async {
      await repository.updateCompletion(event.entryId, event.isCompleted);
      // We don't have farmId here easily, so we might need a refresh logic
    });
  }
}
