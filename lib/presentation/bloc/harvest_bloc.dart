import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/harvest_entry.dart';
import '../../domain/repositories/harvest_repository.dart';

// Events
abstract class HarvestEvent extends Equatable {
  const HarvestEvent();
  @override
  List<Object?> get props => [];
}

class LoadHarvests extends HarvestEvent {
  final String farmId;
  const LoadHarvests(this.farmId);
}

class AddHarvest extends HarvestEvent {
  final HarvestEntry entry;
  const AddHarvest(this.entry);
}

// State
abstract class HarvestState extends Equatable {
  const HarvestState();
  @override
  List<Object?> get props => [];
}

class HarvestInitial extends HarvestState {}
class HarvestLoading extends HarvestState {}
class HarvestLoaded extends HarvestState {
  final List<HarvestEntry> entries;
  const HarvestLoaded(this.entries);
}
class HarvestError extends HarvestState {
  final String message;
  const HarvestError(this.message);
}

// BLoC
class HarvestBloc extends Bloc<HarvestEvent, HarvestState> {
  final HarvestRepository repository;

  HarvestBloc({required this.repository}) : super(HarvestInitial()) {
    on<LoadHarvests>((event, emit) async {
      emit(HarvestLoading());
      final result = await repository.getHarvests(event.farmId);
      emit(result.fold(
        (f) => HarvestError(f.message),
        (e) => HarvestLoaded(e),
      ));
    });

    on<AddHarvest>((event, emit) async {
      await repository.addHarvest(event.entry);
      // Reload would follow
    });
  }
}
