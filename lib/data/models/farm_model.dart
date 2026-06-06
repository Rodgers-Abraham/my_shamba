import '../../domain/entities/farm_entity.dart';

class FarmModel extends FarmEntity {
  final String farmId;
  final String ownerUid;

  FarmModel({
    required this.farmId,
    required this.ownerUid,
    required super.county,
    required super.subCounty,
    required super.constituency,
    required super.ward,
  }) : super(
          id: farmId,
          ownerId: ownerUid,
        );

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      farmId: json['farmId'] as String,
      ownerUid: json['ownerUid'] as String,
      county: json['county'] as String,
      subCounty: json['subCounty'] as String,
      constituency: json['constituency'] as String? ?? '',
      ward: json['ward'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farmId': farmId,
      'ownerUid': ownerUid,
      'county': county,
      'subCounty': subCounty,
      'constituency': constituency,
      'ward': ward,
    };
  }
}
