import 'package:equatable/equatable.dart';

abstract class AssetEntity extends Equatable {
  final String id;
  final String farmId;
  final String name;
  final String type; // 'livestock' or 'crop'
  final DateTime createdAt;
  final String? notes; // Optional notes for farmers

  const AssetEntity({
    required this.id,
    required this.farmId,
    required this.name,
    required this.type,
    required this.createdAt,
    this.notes,
  });

  @override
  List<Object?> get props => [id, farmId, name, type, createdAt, notes];
}

class LivestockEntity extends AssetEntity {
  final String status;

  const LivestockEntity({
    required super.id,
    required super.farmId,
    required super.name,
    required super.createdAt,
    required this.status,
    super.notes,
  }) : super(type: 'livestock');

  @override
  List<Object?> get props => [...super.props, status];
}

class CropEntity extends AssetEntity {
  final String variety;

  const CropEntity({
    required super.id,
    required super.farmId,
    required super.name,
    required super.createdAt,
    required this.variety,
    super.notes,
  }) : super(type: 'crop');

  @override
  List<Object?> get props => [...super.props, variety];
}

