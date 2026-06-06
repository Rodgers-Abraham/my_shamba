import '../entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> getUser(String id);
  Future<Either<Failure, void>> createUser(UserEntity user);
}
