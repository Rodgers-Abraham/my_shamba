import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/farm_entity.dart';
import '../../domain/repositories/farm_repository.dart';
import '../models/farm_model.dart';
import '../local/models/isar_models.dart';

class FarmRepositoryImpl implements FarmRepository {
  final FirebaseFirestore _firestore;
  final Isar _isar;

  FarmRepositoryImpl(this._firestore, this._isar);

  @override
  Future<Either<Failure, FarmEntity>> getFarm(String ownerId) async {
    try {
      // Offline-first: check Isar
      final localFarm = await _isar.farmIsars.filter().ownerIdEqualTo(ownerId).findFirst();
      if (localFarm != null) {
        return Right(FarmModel(
          farmId: localFarm.syncId,
          ownerUid: localFarm.ownerId,
          county: localFarm.county,
          subCounty: localFarm.subCounty,
          constituency: localFarm.constituency,
          ward: localFarm.ward,
        ));
      }

      // If not locally, we'll try firestore as a fallback 
      final snapshot = await _firestore.collection('farms')
          .where('ownerUid', isEqualTo: ownerId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return Left(ServerFailure('Farm not found locally or remotely.'));
      }

      final farmData = snapshot.docs.first.data();
      final farmModel = FarmModel.fromJson(farmData);

      // Cache locally
      final newLocalFarm = FarmIsar()
        ..syncId = farmModel.farmId
        ..ownerId = farmModel.ownerUid
        ..county = farmModel.county
        ..subCounty = farmModel.subCounty
        ..constituency = farmModel.constituency
        ..ward = farmModel.ward
        ..isSynced = true;

      await _isar.writeTxn(() async {
        await _isar.farmIsars.put(newLocalFarm);
      });

      return Right(farmModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FarmEntity>> setupFarm(String ownerId, String county, String subCounty, String constituency, String ward) async {
    try {
      final syncId = const Uuid().v4();
      final farmModel = FarmModel(
        farmId: syncId,
        ownerUid: ownerId,
        county: county,
        subCounty: subCounty,
        constituency: constituency,
        ward: ward,
      );

      final newLocalFarm = FarmIsar()
        ..syncId = syncId
        ..ownerId = ownerId
        ..county = county
        ..subCounty = subCounty
        ..constituency = constituency
        ..ward = ward
        ..isSynced = false;

      // Instant local write
      await _isar.writeTxn(() async {
        await _isar.farmIsars.put(newLocalFarm);
      });

      return Right(farmModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
