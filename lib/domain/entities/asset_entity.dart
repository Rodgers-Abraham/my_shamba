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
  final bool isPlanted;
  final bool isWeeded;
  final bool isFumigated;
  final bool isTopDressed;
  final bool isPruned;
  final bool isHarvested;

  const CropEntity({
    required super.id,
    required super.farmId,
    required super.name,
    required super.createdAt,
    required this.variety,
    this.isPlanted = false,
    this.isWeeded = false,
    this.isFumigated = false,
    this.isTopDressed = false,
    this.isPruned = false,
    this.isHarvested = false,
    super.notes,
  }) : super(type: 'crop');

  @override
  List<Object?> get props => [
        ...super.props,
        variety,
        isPlanted,
        isWeeded,
        isFumigated,
        isTopDressed,
        isPruned,
        isHarvested
      ];
}

