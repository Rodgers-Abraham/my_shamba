import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'injection_container.dart' as di;
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/farm_bloc.dart';
import 'presentation/bloc/harvest_bloc.dart';
import 'presentation/bloc/asset_bloc.dart';
import 'presentation/bloc/ledger_bloc.dart';
import 'presentation/bloc/supply_bloc.dart';
import 'presentation/bloc/calendar_bloc.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init();
  runApp(const MyShambaApp());
}

class MyShambaApp extends StatelessWidget {
  const MyShambaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<FarmBloc>()),
        BlocProvider(create: (_) => di.sl<HarvestBloc>()),
        BlocProvider(create: (_) => di.sl<AssetBloc>()),
        BlocProvider(create: (_) => di.sl<LedgerBloc>()),
        BlocProvider(create: (_) => di.sl<SupplyBloc>()),
        BlocProvider(create: (_) => di.sl<CalendarBloc>()),
      ],
      child: MaterialApp(
        title: 'my_shamba',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const OnboardingScreen(),
      ),
    );
  }
}
