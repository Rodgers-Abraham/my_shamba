import 'package:isar/isar.dart';

part 'isar_models.g.dart';

@collection
class UserIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncId;

  late String fullName;
  late String email;
  late String phoneNumber;
  String? address;

  bool isSynced = false;
}

@collection
class FarmIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncId;

  late String ownerId;
  late String county;
  late String subCounty;
  late String constituency;
  late String ward;

  bool isSynced = false;
}

@collection
class AssetIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncId;

  @Index()
  late String farmId;

  late String name;
  late String type; // 'livestock' or 'crop'
  late DateTime createdAt;

  // Optional notes
  String? notes;

  // Livestock specifics
  String? status;

  // Crop specifics
  String? variety;

  bool isSynced = false;
}

@collection
class HarvestLogIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncId;

  @Index()
  late String farmId;

  late double quantity;
  late String type;
  late DateTime date;

  bool isSynced = false;
}

@collection
class LedgerEntryIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncId;

  @Index()
  late String farmId;

  late double amount;
  late String category;
  late String description;
  late DateTime date;
  
  String? associatedParty;

  bool isSynced = false;
}

@collection
class SupplyItemIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncId;

  @Index()
  late String farmId;

  late String name;
  late String category;
  late double quantity;
  late String unit;

  bool isSynced = false;
}
