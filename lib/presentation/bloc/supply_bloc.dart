import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/supply_repository.dart';
import 'supply_event.dart';
import 'supply_state.dart';

// BLoC
class SupplyBloc extends Bloc<SupplyEvent, SupplyState> {
  final SupplyRepository repository;

  SupplyBloc({required this.repository}) : super(SupplyInitial()) {
    on<LoadSupplies>((event, emit) async {
      emit(SupplyLoading());
      final result = await repository.getSupplies(event.farmId);
      emit(
        result.fold(
          (f) => SupplyError(f.message),
          (supplies) => SupplyLoaded(supplies),
        ),
      );
    });

    on<AddSupply>((event, emit) async {
      await repository.addSupply(event.supply);
      add(LoadSupplies(event.supply.farmId));
    });
  }
}
