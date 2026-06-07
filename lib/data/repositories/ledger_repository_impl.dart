import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/ledger_entry_entity.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../local/models/isar_models.dart';

class LedgerRepositoryImpl implements LedgerRepository {
  final FirebaseFirestore _firestore;
  final Isar _isar;

  LedgerRepositoryImpl(this._firestore, this._isar);

  @override
  Future<Either<Failure, List<LedgerEntryEntity>>> getEntries(String farmId) async {
    try {
      // Offline-first: check Isar
      final localEntries = await _isar.ledgerEntryIsars.filter().farmIdEqualTo(farmId).findAll();
      if (localEntries.isNotEmpty) {
        return Right(localEntries.map((e) => LedgerEntryEntity(
          id: e.syncId,
          farmId: e.farmId,
          amount: e.amount,
          category: e.category,
          description: e.description,
          date: e.date,
          associatedParty: e.associatedParty,
        )).toList());
      }

      // Remote fallback
      final snapshot = await _firestore.collection('farms').doc(farmId).collection('ledger').get();
      final remoteEntries = snapshot.docs.map((doc) {
        final data = doc.data();
        return LedgerEntryEntity(
          id: doc.id,
          farmId: farmId,
          amount: (data['amount'] as num).toDouble(),
          category: data['category'],
          description: data['description'],
          date: (data['date'] as Timestamp).toDate(),
          associatedParty: data['associatedParty'],
        );
      }).toList();

      // Cache locally
      await _isar.writeTxn(() async {
        for (var entry in remoteEntries) {
          final local = LedgerEntryIsar()
            ..syncId = entry.id
            ..farmId = entry.farmId
            ..amount = entry.amount
            ..category = entry.category
            ..description = entry.description
            ..date = entry.date
            ..associatedParty = entry.associatedParty
            ..isSynced = true;
          await _isar.ledgerEntryIsars.put(local);
        }
      });

      return Right(remoteEntries);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addEntry(LedgerEntryEntity entry) async {
    try {
      final syncId = const Uuid().v4();
      
      // Local write
      final local = LedgerEntryIsar()
        ..syncId = syncId
        ..farmId = entry.farmId
        ..amount = entry.amount
        ..category = entry.category
        ..description = entry.description
        ..date = entry.date
        ..associatedParty = entry.associatedParty
        ..isSynced = true;

      await _isar.writeTxn(() async {
        await _isar.ledgerEntryIsars.put(local);
      });

      // Remote write
      await _firestore.collection('farms').doc(entry.farmId).collection('ledger').doc(syncId).set({
        'amount': entry.amount,
        'category': entry.category,
        'description': entry.description,
        'date': entry.date,
        'associatedParty': entry.associatedParty,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
