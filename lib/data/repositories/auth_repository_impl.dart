import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._firebaseAuth, this._firestore);

  @override
  Future<Either<Failure, UserEntity>> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      final userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
      if (!userDoc.exists) {
        return Left(ServerFailure("User profile not found."));
      }
      return Right(UserModel.fromJson(userDoc.data()!));
    } catch (e) {
      String message = e.toString();
      if (e is firebase_auth.FirebaseAuthException) {
        message = e.message ?? 'Authentication failed.';
      }
      return Left(ServerFailure(message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp(String fullName, String email, String password, String phoneNumber) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      final userModel = UserModel(
        uid: credential.user!.uid,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      );
      await _firestore.collection('users').doc(userModel.uid).set(userModel.toJson());
      return Right(userModel);
    } catch (e) {
      String message = e.toString();
      if (e is firebase_auth.FirebaseAuthException) {
        message = e.message ?? 'Registration failed.';
      }
      return Left(ServerFailure(message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
