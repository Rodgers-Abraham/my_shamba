import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/supply_entity.dart';
import '../../domain/repositories/supply_repository.dart';
import '../local/models/isar_models.dart';

class SupplyRepositoryImpl implements SupplyRepository {
  final Isar _isar;

  SupplyRepositoryImpl(this._isar);

  @override
  Future<Either<Failure, List<SupplyEntity>>> getSupplies(String farmId) async {
    try {
      final localSupplies = await _isar.supplyItemIsars.filter().farmIdEqualTo(farmId).findAll();
      return Right(localSupplies.map((e) {
        return SupplyEntity(
          id: e.syncId,
          farmId: e.farmId,
          name: e.name,
          category: e.category,
          quantity: e.quantity,
          unit: e.unit,
        );
      }).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSupply(SupplyEntity supply) async {
    try {
      // Find local and update
      final existing = await _isar.supplyItemIsars.filter().syncIdEqualTo(supply.id).findFirst();
      if (existing != null) {
        existing.quantity = supply.quantity;
        existing.isSynced = false;
        await _isar.writeTxn(() async {
          await _isar.supplyItemIsars.put(existing);
        });
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addSupply(SupplyEntity supply) async {
    try {
      final syncId = const Uuid().v4();
      final newSupply = SupplyItemIsar()
        ..syncId = syncId
        ..farmId = supply.farmId
        ..name = supply.name
        ..category = supply.category
        ..quantity = supply.quantity
        ..unit = supply.unit
        ..isSynced = false;

      await _isar.writeTxn(() async {
        await _isar.supplyItemIsars.put(newSupply);
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
