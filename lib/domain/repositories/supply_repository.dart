import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/supply_entity.dart';

abstract class SupplyRepository {
  Future<Either<Failure, List<SupplyEntity>>> getSupplies(String farmId);
  Future<Either<Failure, void>> updateSupply(SupplyEntity supply);
  Future<Either<Failure, void>> addSupply(SupplyEntity supply);
}
