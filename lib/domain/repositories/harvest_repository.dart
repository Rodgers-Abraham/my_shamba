import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/harvest_entry.dart';

abstract class HarvestRepository {
  Future<Either<Failure, List<HarvestEntry>>> getHarvests(String farmId);
  Future<Either<Failure, void>> addHarvest(HarvestEntry entry);
}
