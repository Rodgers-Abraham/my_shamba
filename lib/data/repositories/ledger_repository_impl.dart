import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/ledger_entry_entity.dart';
import '../../domain/repositories/ledger_repository.dart';

class LedgerRepositoryImpl implements LedgerRepository {
  final FirebaseFirestore _firestore;

  LedgerRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, List<LedgerEntryEntity>>> getEntries(String farmId) async {
    try {
      final snapshot = await _firestore.collection('farms').doc(farmId).collection('ledger').get();
      return Right(snapshot.docs.map((doc) {
        final data = doc.data();
        return LedgerEntryEntity(
          id: doc.id,
          farmId: farmId,
          amount: (data['amount'] as num).toDouble(),
          category: data['category'],
          description: data['description'],
          date: (data['date'] as Timestamp).toDate(),
        );
      }).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addEntry(LedgerEntryEntity entry) async {
    try {
      await _firestore.collection('farms').doc(entry.farmId).collection('ledger').doc(entry.id).set({
        'amount': entry.amount,
        'category': entry.category,
        'description': entry.description,
        'date': entry.date,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
