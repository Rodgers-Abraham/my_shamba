import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/ledger_entry_entity.dart';
import '../../domain/repositories/ledger_repository.dart';

// Events
abstract class LedgerEvent extends Equatable {
  const LedgerEvent();
  @override
  List<Object?> get props => [];
}

class LoadEntries extends LedgerEvent {
  final String farmId;
  const LoadEntries(this.farmId);
  @override
  List<Object?> get props => [farmId];
}

class AddEntry extends LedgerEvent {
  final String farmId;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String? associatedParty;

  const AddEntry({
    required this.farmId,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.associatedParty,
  });
  
  @override
  List<Object?> get props => [farmId, amount, category, description, date, associatedParty];
}

// State
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
  @override
  List<Object?> get props => [entries];
}
class LedgerError extends LedgerState {
  final String message;
  const LedgerError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class LedgerBloc extends Bloc<LedgerEvent, LedgerState> {
  final LedgerRepository repository;

  LedgerBloc({required this.repository}) : super(LedgerInitial()) {
    on<LoadEntries>((event, emit) async {
      emit(LedgerLoading());
      final result = await repository.getEntries(event.farmId);
      emit(result.fold(
        (f) => LedgerError(f.message),
        (entries) => LedgerLoaded(entries),
      ));
    });

    on<AddEntry>((event, emit) async {
      final result = await repository.addEntry(LedgerEntryEntity(
        id: '',
        farmId: event.farmId,
        amount: event.amount,
        category: event.category,
        description: event.description,
        date: event.date,
        associatedParty: event.associatedParty,
      ));
      
      result.fold(
        (f) => emit(LedgerError(f.message)),
        (_) => add(LoadEntries(event.farmId)),
      );
    });
  }
}
