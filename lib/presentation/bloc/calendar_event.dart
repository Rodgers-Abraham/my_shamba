import 'package:equatable/equatable.dart';
import '../../domain/entities/calendar_entry_entity.dart';
import '../../domain/entities/asset_entity.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();
  @override
  List<Object?> get props => [];
}

class LoadCalendar extends CalendarEvent {
  final String farmId;
  const LoadCalendar(this.farmId);
  @override
  List<Object?> get props => [farmId];
}

class AddCalendarEntry extends CalendarEvent {
  final CalendarEntryEntity entry;
  const AddCalendarEntry(this.entry);
  @override
  List<Object?> get props => [entry];
}

class ToggleEntryCompletion extends CalendarEvent {
  final String entryId;
  final bool isCompleted;
  const ToggleEntryCompletion(this.entryId, this.isCompleted);
  @override
  List<Object?> get props => [entryId, isCompleted];
}

class GenerateLivestockRoadmap extends CalendarEvent {
  final LivestockEntity animal;
  final String mainCategory;
  final String subCategory;
  final DateTime birthDate;

  const GenerateLivestockRoadmap({
    required this.animal,
    required this.mainCategory,
    required this.subCategory,
    required this.birthDate,
  });

  @override
  List<Object?> get props => [animal, mainCategory, subCategory, birthDate];
}

class GenerateCropRoadmap extends CalendarEvent {
  final CropEntity crop;
  final String category;
  final DateTime plantingDate;

  const GenerateCropRoadmap({
    required this.crop,
    required this.category,
    required this.plantingDate,
  });

  @override
  List<Object?> get props => [crop, category, plantingDate];
}

class GenerateForestryRoadmap extends CalendarEvent {
  final AssetEntity item;
  final String category;
  final DateTime plantingDate;

  const GenerateForestryRoadmap({
    required this.item,
    required this.category,
    required this.plantingDate,
  });

  @override
  List<Object?> get props => [item, category, plantingDate];
}

class RegisterSpecificEvent extends CalendarEvent {
  final AssetEntity asset;
  final String mainCategory;
  final String subCategory;
  final String trigger;
  final DateTime eventDate;
  final bool isLivestock;

  const RegisterSpecificEvent({
    required this.asset,
    required this.mainCategory,
    required this.subCategory,
    required this.trigger,
    required this.eventDate,
    this.isLivestock = true,
  });

  @override
  List<Object?> get props => [asset, mainCategory, subCategory, trigger, eventDate, isLivestock];
}

class RegisterInsemination extends CalendarEvent {
  final LivestockEntity animal;
  final String mainCategory;
  final String subCategory;
  final DateTime inseminationDate;

  const RegisterInsemination({
    required this.animal,
    required this.mainCategory,
    required this.subCategory,
    required this.inseminationDate,
  });

  @override
  List<Object?> get props => [animal, mainCategory, subCategory, inseminationDate];
}

class RegisterHarvest extends CalendarEvent {
  final CropEntity crop;
  final double quantity;
  final String unit;

  const RegisterHarvest({
    required this.crop,
    required this.quantity,
    required this.unit,
  });

  @override
  List<Object?> get props => [crop, quantity, unit];
}

class ScheduleRecurringEvent extends CalendarEvent {
  final String farmId;
  final String assetName;
  final String eventName;
  final int intervalDays;
  final DateTime lastEventDate;

  const ScheduleRecurringEvent({
    required this.farmId,
    required this.assetName,
    required this.eventName,
    required this.intervalDays,
    required this.lastEventDate,
  });

  @override
  List<Object?> get props => [farmId, assetName, eventName, intervalDays, lastEventDate];
}
