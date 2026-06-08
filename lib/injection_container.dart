import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'data/local/models/isar_models.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/farm_repository_impl.dart';
import 'data/repositories/harvest_repository_impl.dart';
import 'data/repositories/asset_repository_impl.dart';
import 'data/repositories/ledger_repository_impl.dart';
import 'data/repositories/supply_repository_impl.dart';
import 'data/repositories/weather_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/farm_repository.dart';
import 'domain/repositories/harvest_repository.dart';
import 'domain/repositories/asset_repository.dart';
import 'domain/repositories/ledger_repository.dart';
import 'domain/repositories/supply_repository.dart';
import 'domain/repositories/weather_repository.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/farm_bloc.dart';
import 'presentation/bloc/harvest_bloc.dart';
import 'presentation/bloc/asset_bloc.dart';
import 'presentation/bloc/ledger_bloc.dart';
import 'presentation/bloc/supply_bloc.dart';

import 'data/local/models/calendar_models.dart';
import 'data/repositories/calendar_repository_impl.dart';
import 'domain/repositories/calendar_repository.dart';
import 'presentation/bloc/calendar_bloc.dart';

import 'core/services/notification_service.dart';
import 'core/services/diary_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  final notificationService = NotificationService();
  await notificationService.init();
  sl.registerLazySingleton(() => notificationService);
  sl.registerLazySingleton(() => DiaryService(sl()));

  // Local Database (Isar)
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      UserIsarSchema,
      FarmIsarSchema,
      AssetIsarSchema,
      HarvestLogIsarSchema,
      LedgerEntryIsarSchema,
      SupplyItemIsarSchema,
      CalendarEntryIsarSchema,
    ],
    directory: dir.path,
  );
  sl.registerLazySingleton<Isar>(() => isar);

  // BLoCs
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => FarmBloc(farmRepository: sl()));
  sl.registerFactory(() => HarvestBloc(repository: sl()));
  sl.registerFactory(() => AssetBloc(repository: sl()));
  sl.registerFactory(() => LedgerBloc(repository: sl()));
  sl.registerFactory(() => SupplyBloc(repository: sl()));
  sl.registerFactory(() => CalendarBloc(
        repository: sl(),
        notificationService: sl(),
        diaryService: sl(),
      ));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<FarmRepository>(
    () => FarmRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<HarvestRepository>(
    () => HarvestRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AssetRepository>(
    () => AssetRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<LedgerRepository>(
    () => LedgerRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<SupplyRepository>(
    () => SupplyRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(client: sl()),
  );
  sl.registerLazySingleton<CalendarRepository>(
    () => CalendarRepositoryImpl(sl(), sl()),
  );

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => http.Client());
}
