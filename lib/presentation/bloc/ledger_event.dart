import 'package:equatable/equatable.dart';

abstract class LedgerEvent extends Equatable {
  const LedgerEvent();
  @override
  List<Object?> get props => [];
}

class LoadEntries extends LedgerEvent {
  final String farmId;
  const LoadEntries(this.farmId);
}
