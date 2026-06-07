import 'package:equatable/equatable.dart';
import '../../domain/entities/calendar_entry_entity.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();
  @override
  List<Object?> get props => [];
}

class LoadCalendar extends CalendarEvent {
  final String farmId;
  const LoadCalendar(this.farmId);
  @override
  List<Object?> get props => [farmId];
}

class AddCalendarEntry extends CalendarEvent {
  final CalendarEntryEntity entry;
  const AddCalendarEntry(this.entry);
  @override
  List<Object?> get props => [entry];
}

class ToggleEntryCompletion extends CalendarEvent {
  final String entryId;
  final bool isCompleted;
  const ToggleEntryCompletion(this.entryId, this.isCompleted);
  @override
  List<Object?> get props => [entryId, isCompleted];
}
