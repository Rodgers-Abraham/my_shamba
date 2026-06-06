import 'package:equatable/equatable.dart';
import '../../domain/entities/supply_entity.dart';

abstract class SupplyState extends Equatable {
  const SupplyState();
  @override
  List<Object?> get props => [];
}

class SupplyInitial extends SupplyState {}
class SupplyLoading extends SupplyState {}
class SupplyLoaded extends SupplyState {
  final List<SupplyEntity> supplies;
  const SupplyLoaded(this.supplies);
  @override
  List<Object?> get props => [supplies];
}
class SupplyError extends SupplyState {
  final String message;
  const SupplyError(this.message);
  @override
  List<Object?> get props => [message];
}
