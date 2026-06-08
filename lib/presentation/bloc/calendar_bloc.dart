import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/diary_service.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final CalendarRepository repository;
  final NotificationService notificationService;
  final DiaryService diaryService;

  CalendarBloc({
    required this.repository,
    required this.notificationService,
    required this.diaryService,
  }) : super(CalendarInitial()) {
    on<LoadCalendar>((event, emit) async {
      emit(CalendarLoading());
      final result = await repository.getEntries(event.farmId);
      emit(result.fold(
        (f) => CalendarError(f.message),
        (entries) => CalendarLoaded(entries),
      ));
    });

    on<AddCalendarEntry>((event, emit) async {
      final result = await repository.addEntry(event.entry);
      
      // If it's a due date/milestone, schedule a notification 7 days prior
      if (event.entry.isDueDate) {
        final notifyDate = event.entry.date.subtract(const Duration(days: 7));
        await notificationService.scheduleMilestone(
          'Upcoming: ${event.entry.title}',
          'Scheduled in 7 days: ${event.entry.description}',
          notifyDate,
        );
      }

      result.fold(
        (f) => emit(CalendarError(f.message)),
        (_) => add(LoadCalendar(event.entry.farmId)),
      );
    });

    on<ToggleEntryCompletion>((event, emit) async {
      final result = await repository.updateCompletion(event.entryId, event.isCompleted);
      if (result.isLeft()) {
        emit(CalendarError(result.fold((f) => f.message, (_) => '')));
      }
    });

    on<GenerateLivestockRoadmap>((event, emit) async {
      await diaryService.generateLivestockRoadmap(
        animal: event.animal,
        mainCategory: event.mainCategory,
        subCategory: event.subCategory,
        birthDate: event.birthDate,
      );
      add(LoadCalendar(event.animal.farmId));
    });

    on<GenerateCropRoadmap>((event, emit) async {
      await diaryService.generateCropRoadmap(
        crop: event.crop,
        category: event.category,
        plantingDate: event.plantingDate,
      );
      add(LoadCalendar(event.crop.farmId));
    });

    on<GenerateForestryRoadmap>((event, emit) async {
      await diaryService.generateForestryRoadmap(
        item: event.item,
        category: event.category,
        plantingDate: event.plantingDate,
      );
      add(LoadCalendar(event.item.farmId));
    });

    on<RegisterSpecificEvent>((event, emit) async {
      await diaryService.handleSpecificEvent(
        asset: event.asset,
        mainCategory: event.mainCategory,
        subCategory: event.subCategory,
        trigger: event.trigger,
        eventDate: event.eventDate,
        isLivestock: event.isLivestock,
      );
      add(LoadCalendar(event.asset.farmId));
    });

    on<RegisterInsemination>((event, emit) async {
      await diaryService.handleSpecificEvent(
        asset: event.animal,
        mainCategory: event.mainCategory,
        subCategory: event.subCategory,
        trigger: 'insemination',
        eventDate: event.inseminationDate,
        isLivestock: true,
      );
      add(LoadCalendar(event.animal.farmId));
    });

    on<RegisterHarvest>((event, emit) async {
      await diaryService.handleHarvestEvent(
        crop: event.crop,
        quantity: event.quantity,
        unit: event.unit,
      );
      add(LoadCalendar(event.crop.farmId));
    });

    on<ScheduleRecurringEvent>((event, emit) async {
      await diaryService.scheduleRecurringEvent(
        farmId: event.farmId,
        assetName: event.assetName,
        eventName: event.eventName,
        intervalDays: event.intervalDays,
        lastEventDate: event.lastEventDate,
      );
      add(LoadCalendar(event.farmId));
    });
  }
}
