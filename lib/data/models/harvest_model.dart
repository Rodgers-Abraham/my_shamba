class HarvestModel {
  final String entryId;
  final String farmId;
  final double quantity;
  final String type;
  final DateTime date;

  HarvestModel({
    required this.entryId,
    required this.farmId,
    required this.quantity,
    required this.type,
    required this.date,
  });

  factory HarvestModel.fromJson(Map<String, dynamic> json) {
    return HarvestModel(
      entryId: json['entryId'] as String,
      farmId: json['farmId'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entryId': entryId,
      'farmId': farmId,
      'quantity': quantity,
      'type': type,
      'date': date.toIso8601String(),
    };
  }
}
