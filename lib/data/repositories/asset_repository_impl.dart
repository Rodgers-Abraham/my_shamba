import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/asset_entity.dart';
import '../../domain/repositories/asset_repository.dart';
import '../local/models/isar_models.dart';

class AssetRepositoryImpl implements AssetRepository {
  final FirebaseFirestore _firestore;
  final Isar _isar;

  AssetRepositoryImpl(this._firestore, this._isar);

  @override
  Future<Either<Failure, List<AssetEntity>>> getAssets(String farmId) async {
    try {
      // Offline-first: check Isar
      final localAssets = await _isar.assetIsars.filter().farmIdEqualTo(farmId).findAll();
      if (localAssets.isNotEmpty) {
        return Right(localAssets.map((e) {
          if (e.type == 'livestock') {
            return LivestockEntity(
              id: e.syncId,
              farmId: e.farmId,
              name: e.name,
              createdAt: e.createdAt,
              status: e.status ?? 'Unknown',
              notes: e.notes,
            );
          } else {
            return CropEntity(
              id: e.syncId,
              farmId: e.farmId,
              name: e.name,
              createdAt: e.createdAt,
              variety: e.variety ?? 'Unknown',
              notes: e.notes,
              isPlanted: e.isPlanted,
              isWeeded: e.isWeeded,
              isFumigated: e.isFumigated,
              isTopDressed: e.isTopDressed,
              isPruned: e.isPruned,
              isHarvested: e.isHarvested,
            );
          }
        }).toList());
      }
      return const Right([]);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addAsset(AssetEntity asset) async {
    try {
      final syncId = const Uuid().v4();
      final newLocalAsset = AssetIsar()
        ..syncId = syncId
        ..farmId = asset.farmId
        ..name = asset.name
        ..type = asset.type
        ..createdAt = asset.createdAt
        ..notes = asset.notes
        ..status = asset is LivestockEntity ? asset.status : null
        ..variety = asset is CropEntity ? asset.variety : null
        ..isPlanted = asset is CropEntity ? asset.isPlanted : false
        ..isWeeded = asset is CropEntity ? asset.isWeeded : false
        ..isFumigated = asset is CropEntity ? asset.isFumigated : false
        ..isTopDressed = asset is CropEntity ? asset.isTopDressed : false
        ..isPruned = asset is CropEntity ? asset.isPruned : false
        ..isHarvested = asset is CropEntity ? asset.isHarvested : false
        ..isSynced = true;

      // Instant local write
      await _isar.writeTxn(() async {
        await _isar.assetIsars.put(newLocalAsset);
      });

      // Remote write
      await _firestore.collection('farms').doc(asset.farmId).collection('assets').doc(syncId).set({
        'name': asset.name,
        'type': asset.type,
        'createdAt': asset.createdAt,
        'notes': asset.notes,
        if (asset is LivestockEntity) 'status': asset.status,
        if (asset is CropEntity) ...{
          'variety': asset.variety,
          'isPlanted': asset.isPlanted,
          'isWeeded': asset.isWeeded,
          'isFumigated': asset.isFumigated,
          'isTopDressed': asset.isTopDressed,
          'isPruned': asset.isPruned,
          'isHarvested': asset.isHarvested,
        }
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
