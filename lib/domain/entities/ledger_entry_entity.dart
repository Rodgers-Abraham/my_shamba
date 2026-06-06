import 'package:equatable/equatable.dart';

class LedgerEntryEntity extends Equatable {
  final String id;
  final String farmId;
  final double amount;
  final String category; // 'Income' or 'Expense'
  final String description;
  final DateTime date;
  final String? associatedParty; // Optional: Worker name, buyer, etc.

  const LedgerEntryEntity({
    required this.id,
    required this.farmId,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.associatedParty,
  });

  @override
  List<Object?> get props => [id, farmId, amount, category, description, date, associatedParty];
}
