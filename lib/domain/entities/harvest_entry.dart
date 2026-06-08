import 'package:equatable/equatable.dart';

class HarvestEntry extends Equatable {
  final String id;
  final String farmId;
  final String? assetId; // ID of the cow/crop block
  final String? assetName; // Name of the cow/crop block
  final double quantity;
  final String type;
  final DateTime date;

  const HarvestEntry({
    required this.id,
    required this.farmId,
    required this.quantity,
    required this.type,
    required this.date,
    this.assetId,
    this.assetName,
  });

  @override
  List<Object?> get props => [id, farmId, assetId, assetName, quantity, type, date];
}

