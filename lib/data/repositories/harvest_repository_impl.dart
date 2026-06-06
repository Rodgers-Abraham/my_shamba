import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/harvest_entry.dart';
import '../../domain/repositories/harvest_repository.dart';
import '../models/harvest_model.dart';

class HarvestRepositoryImpl implements HarvestRepository {
  final FirebaseFirestore _firestore;

  HarvestRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, List<HarvestEntry>>> getHarvests(String farmId) async {
    try {
      final snapshot = await _firestore.collection('harvests')
          .where('farmId', isEqualTo: farmId)
          .get();

      final list = snapshot.docs.map((doc) {
        final model = HarvestModel.fromJson(doc.data());
        return HarvestEntry(
          id: model.entryId,
          farmId: model.farmId,
          quantity: model.quantity,
          type: model.type,
          date: model.date,
        );
      }).toList();

      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addHarvest(HarvestEntry entry) async {
    try {
      final harvestModel = HarvestModel(
        entryId: entry.id,
        farmId: entry.farmId,
        quantity: entry.quantity,
        type: entry.type,
        date: entry.date,
      );
      await _firestore.collection('harvests').doc(entry.id).set(harvestModel.toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
