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

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HarvestHubScreen(farmId: widget.farmId),
      CalendarScreen(farmId: widget.farmId),
      RegistryScreen(farmId: widget.farmId),
      AuthGuard(child: LedgerScreen(farmId: widget.farmId)),
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
    return Scaffold(
      drawer: _buildDrawer(),
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
          BottomNavigationBarItem(icon: Container(key: _ledgerKey, child: const Icon(Icons.account_balance_wallet)), label: 'Finance'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset('assets/logo.png', height: 60, width: 60),
                const SizedBox(height: 12),
                const Text('My Shamba Menu', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.agriculture),
            title: const Text('Farm Products'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductsScreen(farmId: widget.farmId)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Workshop & Tools'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => WorkshopScreen(farmId: widget.farmId)));
            },
          ),
          const Divider(),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: 'My Shamba',
            applicationVersion: '1.0.0',
            aboutBoxChildren: [Text('Empowering farmers with precision data.')],
          ),
        ],
      ),
    );
  }
}
