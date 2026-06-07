import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../widgets/auth_guard.dart';
import '../screens/harvest_hub_screen.dart';
import '../screens/registry_screen.dart';
import '../screens/ledger_screen.dart';
import '../screens/workshop_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/products_screen.dart';
import '../screens/calendar_screen.dart';
import '../../core/theme/app_theme.dart';

class MainNavigationShell extends StatefulWidget {
  final String farmId;
  const MainNavigationShell({super.key, required this.farmId});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  late TutorialCoachMark tutorialCoachMark;

  final GlobalKey _hubKey = GlobalKey();
  final GlobalKey _registryKey = GlobalKey();
  final GlobalKey _ledgerKey = GlobalKey();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HarvestHubScreen(farmId: widget.farmId),
      CalendarScreen(farmId: widget.farmId),
      RegistryScreen(farmId: widget.farmId),
      ProductsScreen(farmId: widget.farmId),
      AuthGuard(child: LedgerScreen(farmId: widget.farmId)),
      WorkshopScreen(farmId: widget.farmId),
      const ProfileScreen(),
    ];
    _checkFirstTimeTour();
  }

  Future<void> _checkFirstTimeTour() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTour = prefs.getBool('has_seen_tour') ?? false;

    if (!hasSeenTour) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _showTour();
        prefs.setBool('has_seen_tour', true);
      });
    }
  }

  void _showTour() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: AppTheme.primary,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
    )..show(context: context);
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "HubTarget",
        keyTarget: _hubKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Daily Harvest Hub", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 10),
                  Text("Log your daily milk and eggs here, and keep your streak alive!", style: TextStyle(color: Colors.white)),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "RegistryTarget",
        keyTarget: _registryKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Biological Registry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 10),
                  Text("Track your livestock dossiers and crop blocks here.", style: TextStyle(color: Colors.white)),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "LedgerTarget",
        keyTarget: _ledgerKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Cash Ledger", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 10),
                  Text("Track income and expenses. This is protected and requires you to log in!", style: TextStyle(color: Colors.white)),
                ],
              );
            },
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildDesktopLayout();
        }
        return _buildMobileLayout();
      },
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        items: [
          BottomNavigationBarItem(icon: Container(key: _hubKey, child: const Icon(Icons.home)), label: 'Hub'),
          const BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Container(key: _registryKey, child: const Icon(Icons.pets)), label: 'Registry'),
          const BottomNavigationBarItem(icon: Icon(Icons.agriculture), label: 'Products'),
          BottomNavigationBarItem(icon: Container(key: _ledgerKey, child: const Icon(Icons.account_balance_wallet)), label: 'Ledger'),
          const BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Workshop'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: [
              NavigationRailDestination(icon: Container(key: _hubKey, child: const Icon(Icons.home)), label: const Text('Hub')),
              const NavigationRailDestination(icon: Icon(Icons.calendar_month), label: Text('Calendar')),
              NavigationRailDestination(icon: Container(key: _registryKey, child: const Icon(Icons.pets)), label: const Text('Registry')),
              const NavigationRailDestination(icon: Icon(Icons.agriculture), label: Text('Products')),
              NavigationRailDestination(icon: Container(key: _ledgerKey, child: const Icon(Icons.account_balance_wallet)), label: const Text('Ledger')),
              const NavigationRailDestination(icon: Icon(Icons.build), label: Text('Workshop')),
              const NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profile')),
            ],
            extended: true,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: IndexedStack(index: _currentIndex, children: _screens)),
        ],
      ),
    );
  }
}
