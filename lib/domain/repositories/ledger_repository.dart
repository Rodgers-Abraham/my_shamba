import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/ledger_entry_entity.dart';

abstract class LedgerRepository {
  Future<Either<Failure, List<LedgerEntryEntity>>> getEntries(String farmId);
  Future<Either<Failure, void>> addEntry(LedgerEntryEntity entry);
}
