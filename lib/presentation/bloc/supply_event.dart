import 'package:equatable/equatable.dart';
import '../../domain/entities/supply_entity.dart';

abstract class SupplyEvent extends Equatable {
  const SupplyEvent();
  @override
  List<Object?> get props => [];
}

class LoadSupplies extends SupplyEvent {
  final String farmId;
  const LoadSupplies(this.farmId);
}

class AddSupply extends SupplyEvent {
  final SupplyEntity supply;
  const AddSupply(this.supply);

  @override
  List<Object?> get props => [supply];
}
