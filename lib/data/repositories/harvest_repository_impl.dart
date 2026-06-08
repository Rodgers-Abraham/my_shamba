import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/harvest_entry.dart';
import '../../domain/repositories/harvest_repository.dart';
import '../models/harvest_model.dart';
import '../local/models/isar_models.dart';

class HarvestRepositoryImpl implements HarvestRepository {
  final FirebaseFirestore _firestore;
  final Isar _isar;

  HarvestRepositoryImpl(this._firestore, this._isar);

  @override
  Future<Either<Failure, List<HarvestEntry>>> getHarvests(String farmId) async {
    try {
      // Offline-first
      final localHarvests = await _isar.harvestLogIsars.filter().farmIdEqualTo(farmId).findAll();
      if (localHarvests.isNotEmpty) {
        return Right(localHarvests.map((e) => HarvestEntry(
          id: e.syncId,
          farmId: e.farmId,
          assetId: e.assetId,
          assetName: e.assetName,
          quantity: e.quantity,
          type: e.type,
          date: e.date,
        )).toList());
      }

      final snapshot = await _firestore.collection('harvests')
          .where('farmId', isEqualTo: farmId)
          .get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return HarvestEntry(
          id: doc.id,
          farmId: farmId,
          assetId: data['assetId'],
          assetName: data['assetName'],
          quantity: (data['quantity'] as num).toDouble(),
          type: data['type'],
          date: (data['date'] as Timestamp).toDate(),
        );
      }).toList();

      // Cache locally
      await _isar.writeTxn(() async {
        for (var h in list) {
          final local = HarvestLogIsar()
            ..syncId = h.id
            ..farmId = h.farmId
            ..assetId = h.assetId
            ..assetName = h.assetName
            ..quantity = h.quantity
            ..type = h.type
            ..date = h.date
            ..isSynced = true;
          await _isar.harvestLogIsars.put(local);
        }
      });

      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addHarvest(HarvestEntry entry) async {
    try {
      final syncId = const Uuid().v4();
      
      // Local write
      final local = HarvestLogIsar()
        ..syncId = syncId
        ..farmId = entry.farmId
        ..assetId = entry.assetId
        ..assetName = entry.assetName
        ..quantity = entry.quantity
        ..type = entry.type
        ..date = entry.date
        ..isSynced = true;

      await _isar.writeTxn(() async {
        await _isar.harvestLogIsars.put(local);
      });

      // Remote write
      await _firestore.collection('harvests').doc(syncId).set({
        'farmId': entry.farmId,
        'assetId': entry.assetId,
        'assetName': entry.assetName,
        'quantity': entry.quantity,
        'type': entry.type,
        'date': entry.date,
      });
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
