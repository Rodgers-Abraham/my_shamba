import 'package:equatable/equatable.dart';
import '../../domain/entities/ledger_entry_entity.dart';

abstract class LedgerState extends Equatable {
  const LedgerState();
  @override
  List<Object?> get props => [];
}

class LedgerInitial extends LedgerState {}
class LedgerLoading extends LedgerState {}
class LedgerLoaded extends LedgerState {
  final List<LedgerEntryEntity> entries;
  const LedgerLoaded(this.entries);
}
class LedgerError extends LedgerState {
  final String message;
  const LedgerError(this.message);
}
