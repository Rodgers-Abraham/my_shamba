import 'package:equatable/equatable.dart';

class HarvestEntry extends Equatable {
  final String id;
  final String farmId;
  final double quantity;
  final String type; // e.g., 'milk', 'eggs'
  final DateTime date;

  const HarvestEntry({
    required this.id,
    required this.farmId,
    required this.quantity,
    required this.type,
    required this.date,
  });

  @override
  List<Object?> get props => [id, farmId, quantity, type, date];
}
