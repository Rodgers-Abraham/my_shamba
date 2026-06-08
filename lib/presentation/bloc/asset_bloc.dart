import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/asset_entity.dart';
import '../../domain/repositories/asset_repository.dart';

// Events
abstract class AssetEvent extends Equatable {
  const AssetEvent();
  @override
  List<Object?> get props => [];
}

class LoadAssets extends AssetEvent {
  final String farmId;
  const LoadAssets(this.farmId);
}

class AddAsset extends AssetEvent {
  final AssetEntity asset;
  const AddAsset(this.asset);
  @override
  List<Object?> get props => [asset];
}

// State
abstract class AssetState extends Equatable {
  const AssetState();
  @override
  List<Object?> get props => [];
}

class AssetInitial extends AssetState {}
class AssetLoading extends AssetState {}
class AssetLoaded extends AssetState {
  final List<AssetEntity> assets;
  const AssetLoaded(this.assets);
}
class AssetError extends AssetState {
  final String message;
  const AssetError(this.message);
}

// BLoC
class AssetBloc extends Bloc<AssetEvent, AssetState> {
  final AssetRepository repository;

  AssetBloc({required this.repository}) : super(AssetInitial()) {
    on<LoadAssets>((event, emit) async {
      emit(AssetLoading());
      final result = await repository.getAssets(event.farmId);
      emit(result.fold(
        (f) => AssetError(f.message),
        (assets) => AssetLoaded(assets),
      ));
    });
    on<AddAsset>((event, emit) async {
      final result = await repository.addAsset(event.asset);
      result.fold(
        (f) => emit(AssetError(f.message)),
        (_) => add(LoadAssets(event.asset.farmId)),
      );
    });
  }
}
