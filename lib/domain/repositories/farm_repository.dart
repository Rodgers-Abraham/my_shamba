import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/farm_entity.dart';

abstract class FarmRepository {
  Future<Either<Failure, FarmEntity>> getFarm(String ownerId);
  Future<Either<Failure, FarmEntity>> setupFarm(String ownerId, String county, String subCounty, String constituency, String ward);
}
