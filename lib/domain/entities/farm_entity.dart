class FarmEntity {
  final String id;
  final String ownerId;
  final String county;
  final String subCounty;
  final String constituency;
  final String ward;

  FarmEntity({
    required this.id,
    required this.ownerId,
    required this.county,
    required this.subCounty,
    required this.constituency,
    required this.ward,
  });
}
