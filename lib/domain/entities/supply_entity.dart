import 'package:equatable/equatable.dart';

class SupplyEntity extends Equatable {
  final String id;
  final String farmId;
  final String name;
  final String category; // 'Tool' or 'Consumable'
  final double quantity;
  final String unit; // 'pieces', 'kg', etc.

  const SupplyEntity({
    required this.id,
    required this.farmId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
  });

  @override
  List<Object?> get props => [id, farmId, name, category, quantity, unit];
}
