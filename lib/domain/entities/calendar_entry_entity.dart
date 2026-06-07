import 'package:equatable/equatable.dart';

class CalendarEntryEntity extends Equatable {
  final String id;
  final String farmId;
  final String title;
  final String description;
  final DateTime date;
  final bool isDueDate;
  final bool isCompleted;

  const CalendarEntryEntity({
    required this.id,
    required this.farmId,
    required this.title,
    required this.description,
    required this.date,
    required this.isDueDate,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [id, farmId, title, description, date, isDueDate, isCompleted];
}
