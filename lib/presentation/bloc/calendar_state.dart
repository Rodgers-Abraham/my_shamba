import 'package:equatable/equatable.dart';
import '../../domain/entities/calendar_entry_entity.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();
  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {}
class CalendarLoading extends CalendarState {}
class CalendarLoaded extends CalendarState {
  final List<CalendarEntryEntity> entries;
  const CalendarLoaded(this.entries);
  @override
  List<Object?> get props => [entries];
}
class CalendarError extends CalendarState {
  final String message;
  const CalendarError(this.message);
  @override
  List<Object?> get props => [message];
}
