import 'package:isar/isar.dart';

part 'calendar_models.g.dart';

@collection
class CalendarEntryIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncId;

  @Index()
  late String farmId;

  late String title;
  late String description;
  late DateTime date;
  late bool isDueDate; // True if it's a deadline, False if it's a daily log
  
  bool isCompleted = false;
  bool isSynced = false;
}
