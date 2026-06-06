import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/asset_entity.dart';

abstract class AssetRepository {
  Future<Either<Failure, List<AssetEntity>>> getAssets(String farmId);
  Future<Either<Failure, void>> addAsset(AssetEntity asset);
}
