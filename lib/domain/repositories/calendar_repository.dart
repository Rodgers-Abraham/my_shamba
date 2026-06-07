import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/calendar_entry_entity.dart';

abstract class CalendarRepository {
  Future<Either<Failure, List<CalendarEntryEntity>>> getEntries(String farmId);
  Future<Either<Failure, void>> addEntry(CalendarEntryEntity entry);
  Future<Either<Failure, void>> updateCompletion(String entryId, bool isCompleted);
}
