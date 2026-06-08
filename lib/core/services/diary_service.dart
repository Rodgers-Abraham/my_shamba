import 'package:uuid/uuid.dart';
import '../../domain/entities/asset_entity.dart';
import '../../domain/entities/calendar_entry_entity.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../utils/baselines_parser.dart';

class DiaryService {
  final CalendarRepository repository;

  DiaryService(this.repository);

  /// Generates a roadmap for livestock based on a birth date or other milestones.
  Future<void> generateLivestockRoadmap({
    required LivestockEntity animal,
    required String mainCategory, // e.g., 'cattle'
    required String subCategory,  // e.g., 'dairy'
    required DateTime birthDate,
  }) async {
    final baselines = await BaselinesParser.loadBaselines();
    final data = BaselinesParser.getLivestockBaselines(baselines, mainCategory, subCategory);
    if (data == null) return;

    await _processSchedule(
      farmId: animal.farmId,
      assetName: animal.name,
      schedule: data['diary_schedule'] as List<dynamic>,
      baseDate: birthDate,
      trigger: 'birth',
    );

    await _processRecurring(
      farmId: animal.farmId,
      assetName: animal.name,
      schedule: data['diary_schedule'] as List<dynamic>,
      baseDate: birthDate,
    );

    // Special milestone: Reproductive Maturity
    final maturityMonths = data['metrics']['breeding_maturity_months'] as int?;
    if (maturityMonths != null) {
      final maturityDate = DateTime(birthDate.year, birthDate.month + maturityMonths, birthDate.day);
      await _addEntry(
        farmId: animal.farmId,
        title: '${animal.name}: Reproductive Maturity',
        description: 'Projected date for reproductive maturity ($maturityMonths months).',
        date: maturityDate,
      );
    }
  }

  /// Generates a roadmap for crops based on a planting date.
  Future<void> generateCropRoadmap({
    required CropEntity crop,
    required String category, // e.g., 'cereals_and_grains'
    required DateTime plantingDate,
  }) async {
    final baselines = await BaselinesParser.loadBaselines();
    final data = BaselinesParser.getCropBaselines(baselines, category);
    if (data == null) return;

    await _processSchedule(
      farmId: crop.farmId,
      assetName: crop.name,
      schedule: data['diary_schedule'] as List<dynamic>,
      baseDate: plantingDate,
      trigger: 'planting',
    );

    await _processRecurring(
      farmId: crop.farmId,
      assetName: crop.name,
      schedule: data['diary_schedule'] as List<dynamic>,
      baseDate: plantingDate,
    );
  }

  /// Generates a roadmap for forestry items.
  Future<void> generateForestryRoadmap({
    required AssetEntity item,
    required String category, // e.g., 'commercial_agroforestry'
    required DateTime plantingDate,
  }) async {
    final baselines = await BaselinesParser.loadBaselines();
    final data = BaselinesParser.getForestryBaselines(baselines, category);
    if (data == null) return;

    await _processSchedule(
      farmId: item.farmId,
      assetName: item.name,
      schedule: data['diary_schedule'] as List<dynamic>,
      baseDate: plantingDate,
      trigger: 'planting',
    );

    await _processRecurring(
      farmId: item.farmId,
      assetName: item.name,
      schedule: data['diary_schedule'] as List<dynamic>,
      baseDate: plantingDate,
    );
  }

  /// Handles specific events like insemination, stocking, egg hatch, etc.
  Future<void> handleSpecificEvent({
    required AssetEntity asset,
    required String mainCategory,
    required String subCategory,
    required String trigger, // e.g., 'insemination', 'stocking', 'nursery_start'
    required DateTime eventDate,
    bool isLivestock = true,
  }) async {
    final baselines = await BaselinesParser.loadBaselines();
    Map<String, dynamic>? data;
    
    if (isLivestock) {
      data = BaselinesParser.getLivestockBaselines(baselines, mainCategory, subCategory);
    } else {
      data = BaselinesParser.getCropBaselines(baselines, subCategory);
      data ??= BaselinesParser.getForestryBaselines(baselines, subCategory);
    }
    
    if (data == null) return;

    await _processSchedule(
      farmId: asset.farmId,
      assetName: asset.name,
      schedule: data['diary_schedule'] as List<dynamic>,
      baseDate: eventDate,
      trigger: trigger,
    );

    // Specific logic for insemination gestation tracking
    if (trigger == 'insemination') {
      final gestationDays = data['metrics']['gestation_days'] as int?;
      if (gestationDays != null) {
        final calvingDate = eventDate.add(Duration(days: gestationDays));
        await _addEntry(
          farmId: asset.farmId,
          title: '${asset.name}: Calving Prep',
          description: 'Prepare for calving/kidding in 7 days.',
          date: calvingDate.subtract(const Duration(days: 7)),
        );
      }
    }
  }

  Future<void> handleHarvestEvent({
    required CropEntity crop,
    required double quantity,
    required String unit,
  }) async {
    await _addEntry(
      farmId: crop.farmId,
      title: '${crop.name}: Post-Harvest Storage Check',
      description: 'Logged harvest: $quantity $unit. Monitor storage conditions.',
      date: DateTime.now().add(const Duration(days: 7)),
    );
  }

  Future<void> scheduleRecurringEvent({
    required String farmId,
    required String assetName,
    required String eventName,
    required int intervalDays,
    required DateTime lastEventDate,
  }) async {
    await _addEntry(
      farmId: farmId,
      title: '$assetName: $eventName',
      description: 'Recurring event scheduled based on a previous entry.',
      date: lastEventDate.add(Duration(days: intervalDays)),
    );
  }

  // Helper Methods

  Future<void> _processSchedule({
    required String farmId,
    required String assetName,
    required List<dynamic> schedule,
    required DateTime baseDate,
    required String trigger,
  }) async {
    for (var event in schedule) {
      if (event['trigger'] == trigger) {
        final offset = event['offset_days'] as int;
        await _addEntry(
          farmId: farmId,
          title: '$assetName: ${event['event']}',
          description: 'Scheduled milestone based on $trigger date.',
          date: baseDate.add(Duration(days: offset)),
        );
      }
    }
  }

  Future<void> _processRecurring({
    required String farmId,
    required String assetName,
    required List<dynamic> schedule,
    required DateTime baseDate,
  }) async {
    for (var event in schedule) {
      if (event['trigger'] == 'recurring') {
        final interval = event['interval_days'] as int;
        // Schedule first few instances (e.g., 4 instances or up to 1 year)
        for (int i = 1; i <= 4; i++) {
          await _addEntry(
            farmId: farmId,
            title: '$assetName: ${event['event']}',
            description: 'Recurring event every $interval days.',
            date: baseDate.add(Duration(days: interval * i)),
          );
        }
      }
    }
  }

  Future<void> _addEntry({
    required String farmId,
    required String title,
    required String description,
    required DateTime date,
  }) async {
    await repository.addEntry(CalendarEntryEntity(
      id: const Uuid().v4(),
      farmId: farmId,
      title: title,
      description: description,
      date: date,
      isDueDate: true,
    ));
  }
}
