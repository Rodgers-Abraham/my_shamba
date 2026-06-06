import 'package:flutter/material.dart';
import '../widgets/main_navigation_shell.dart';
import '../widgets/uiverse_button.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: [
              _buildPage(
                title: 'Welcome to My Shamba',
                description:
                    'Manage your farm, track harvests, and monitor finances with ease.',
                icon: Icons.grass,
              ),
              _buildPage(
                title: 'Daily Harvest Hub',
                description: 'Log your daily production and monitor streaks.',
                icon: Icons.analytics,
              ),
            ],
          ),
          Positioned(
            bottom: 60, // Adjusted for larger button
            left: 0,
            right: 0,
            child: Center(
              child: UiverseButton(
                text: "Get Started",
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationShell(farmId: 'guest'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 100, color: AppTheme.primary),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }
}
