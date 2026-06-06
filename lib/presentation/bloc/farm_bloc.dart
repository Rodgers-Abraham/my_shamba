import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/farm_repository.dart';
import 'farm_event.dart';
import 'farm_state.dart';

class FarmBloc extends Bloc<FarmEvent, FarmState> {
  final FarmRepository farmRepository;

  FarmBloc({required this.farmRepository}) : super(FarmInitial()) {
    on<SetupFarmEvent>((event, emit) async {
      emit(FarmLoading());
      final result = await farmRepository.setupFarm(
        event.ownerId,
        event.county,
        event.subCounty,
        event.constituency,
        event.ward,
      );
      emit(result.fold(
        (failure) => FarmError(failure.message),
        (farm) => FarmSetupSuccess(farm),
      ));
    });
  }
}
