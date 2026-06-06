import 'package:equatable/equatable.dart';
import '../../domain/entities/farm_entity.dart';

abstract class FarmState extends Equatable {
  const FarmState();
  @override
  List<Object?> get props => [];
}

class FarmInitial extends FarmState {}
class FarmLoading extends FarmState {}
class FarmSetupSuccess extends FarmState {
  final FarmEntity farm;
  const FarmSetupSuccess(this.farm);
}
class FarmError extends FarmState {
  final String message;
  const FarmError(this.message);
}
