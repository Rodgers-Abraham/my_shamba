import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/calendar_entry_entity.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../local/models/calendar_models.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final FirebaseFirestore _firestore;
  final Isar _isar;

  CalendarRepositoryImpl(this._firestore, this._isar);

  @override
  Future<Either<Failure, List<CalendarEntryEntity>>> getEntries(String farmId) async {
    try {
      final localEntries = await _isar.calendarEntryIsars.filter().farmIdEqualTo(farmId).findAll();
      return Right(localEntries.map((e) => CalendarEntryEntity(
        id: e.syncId,
        farmId: e.farmId,
        title: e.title,
        description: e.description,
        date: e.date,
        isDueDate: e.isDueDate,
        isCompleted: e.isCompleted,
      )).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addEntry(CalendarEntryEntity entry) async {
    try {
      final syncId = const Uuid().v4();
      final local = CalendarEntryIsar()
        ..syncId = syncId
        ..farmId = entry.farmId
        ..title = entry.title
        ..description = entry.description
        ..date = entry.date
        ..isDueDate = entry.isDueDate
        ..isCompleted = entry.isCompleted
        ..isSynced = true;

      await _isar.writeTxn(() async {
        await _isar.calendarEntryIsars.put(local);
      });

      await _firestore.collection('farms').doc(entry.farmId).collection('calendar').doc(syncId).set({
        'title': entry.title,
        'description': entry.description,
        'date': entry.date,
        'isDueDate': entry.isDueDate,
        'isCompleted': entry.isCompleted,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCompletion(String entryId, bool isCompleted) async {
    try {
      final local = await _isar.calendarEntryIsars.filter().syncIdEqualTo(entryId).findFirst();
      if (local != null) {
        local.isCompleted = isCompleted;
        await _isar.writeTxn(() async {
          await _isar.calendarEntryIsars.put(local);
        });
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
