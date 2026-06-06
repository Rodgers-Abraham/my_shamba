import 'package:equatable/equatable.dart';

abstract class FarmEvent extends Equatable {
  const FarmEvent();
  @override
  List<Object?> get props => [];
}

class SetupFarmEvent extends FarmEvent {
  final String ownerId;
  final String county;
  final String subCounty;
  final String constituency;
  final String ward;

  const SetupFarmEvent({
    required this.ownerId,
    required this.county,
    required this.subCounty,
    required this.constituency,
    required this.ward,
  });

  @override
  List<Object?> get props => [ownerId, county, subCounty, constituency, ward];
}
