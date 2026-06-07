import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/weather_widget.dart';
import '../bloc/farm_bloc.dart';
import '../bloc/farm_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/harvest_bloc.dart';
import '../../domain/entities/harvest_entry.dart';
import 'auth_screen.dart';

class HarvestHubScreen extends StatefulWidget {
  final String farmId;
  const HarvestHubScreen({super.key, required this.farmId});

  @override
  State<HarvestHubScreen> createState() => _HarvestHubScreenState();
}

class _HarvestHubScreenState extends State<HarvestHubScreen> {
  int _streakCount = 0; // Default starting streak
  int _morningMilkQuantityMl = 0;
  int _afternoonMilkQuantityMl = 0;
  int _eveningMilkQuantityMl = 0;
  int _eggQuantity = 0;

  void _logHarvest() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      return;
    }

    // Save Milk logs
    if (_morningMilkQuantityMl > 0) {
      context.read<HarvestBloc>().add(AddHarvest(HarvestEntry(
        id: '', 
        farmId: widget.farmId, 
        quantity: _morningMilkQuantityMl.toDouble(), 
        type: 'Milk (Morning)', 
        date: DateTime.now()
      )));
    }
    if (_afternoonMilkQuantityMl > 0) {
       context.read<HarvestBloc>().add(AddHarvest(HarvestEntry(
        id: '', 
        farmId: widget.farmId, 
        quantity: _afternoonMilkQuantityMl.toDouble(), 
        type: 'Milk (Afternoon)', 
        date: DateTime.now()
      )));
    }
    if (_eveningMilkQuantityMl > 0) {
       context.read<HarvestBloc>().add(AddHarvest(HarvestEntry(
        id: '', 
        farmId: widget.farmId, 
        quantity: _eveningMilkQuantityMl.toDouble(), 
        type: 'Milk (Evening)', 
        date: DateTime.now()
      )));
    }
    
    // Save Eggs
    if (_eggQuantity > 0) {
       context.read<HarvestBloc>().add(AddHarvest(HarvestEntry(
        id: '', 
        farmId: widget.farmId, 
        quantity: _eggQuantity.toDouble(), 
        type: 'Eggs', 
        date: DateTime.now()
      )));
    }

    setState(() {
      _streakCount++;
      _morningMilkQuantityMl = 0;
      _afternoonMilkQuantityMl = 0;
      _eveningMilkQuantityMl = 0;
      _eggQuantity = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Harvest Logged Successfully! Streak Increased 🔥'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FarmBloc, FarmState>(
      builder: (context, state) {
        String wardName = 'Your Farm';
        if (state is FarmSetupSuccess) {
          wardName = state.farm.ward;
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Daily Harvest Hub'),
            actions: [
              IconButton(
                icon: const Icon(Icons.cloud_done, color: AppTheme.success),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data synced to Cloud.')),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Howdy Farmer!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Real Weather based on Farm Ward
                WeatherWidget(ward: wardName),

                const SizedBox(height: 16),
                _buildStreakWidget(),

                const SizedBox(height: 16),
                _buildAlertsCarousel(),

                const SizedBox(height: 24),
                const Text(
                  'Quick Log',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildQuickLogCard(
                  title: 'Morning Milk (ml)',
                  icon: Icons.water_drop,
                  color: Colors.blue.shade100,
                  quantity: _morningMilkQuantityMl,
                  incrementPillLabel: '+100',
                  onAdd: (val) => setState(() => _morningMilkQuantityMl += val),
                  onRemove: () => setState(
                    () => _morningMilkQuantityMl = _morningMilkQuantityMl > 0
                        ? _morningMilkQuantityMl - 10
                        : 0,
                  ),
                  pillValue: 100,
                ),

                const SizedBox(height: 16),
                _buildQuickLogCard(
                  title: 'Afternoon Milk (ml)',
                  icon: Icons.water_drop,
                  color: const Color.fromARGB(255, 255, 245, 52),
                  quantity: _afternoonMilkQuantityMl,
                  incrementPillLabel: '+100',
                  onAdd: (val) => setState(() => _afternoonMilkQuantityMl += val),
                  onRemove: () => setState(
                    () => _afternoonMilkQuantityMl = _afternoonMilkQuantityMl > 0
                        ? _afternoonMilkQuantityMl - 10
                        : 0,
                  ),
                  pillValue: 100,
                ),

                const SizedBox(height: 16),
                _buildQuickLogCard(
                  title: 'Evening Milk (ml)',
                  icon: Icons.water_drop,
                  color: const Color.fromARGB(255, 255, 111, 0),
                  quantity: _eveningMilkQuantityMl,
                  incrementPillLabel: '+100',
                  onAdd: (val) => setState(() => _eveningMilkQuantityMl += val),
                  onRemove: () => setState(
                    () => _eveningMilkQuantityMl = _eveningMilkQuantityMl > 0
                        ? _eveningMilkQuantityMl - 10
                        : 0,
                  ),
                  pillValue: 100,
                ),

                const SizedBox(height: 16),

                _buildQuickLogCard(
                  title: 'Collected Eggs',
                  icon: Icons.egg,
                  color: const Color.fromARGB(255, 126, 76, 0),
                  quantity: _eggQuantity,
                  incrementPillLabel: '+5',
                  onAdd: (val) => setState(() => _eggQuantity += val),
                  onRemove: () => setState(
                    () => _eggQuantity = _eggQuantity > 0 ? _eggQuantity - 1 : 0,
                  ),
                  pillValue: 5,
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text(
                      'Save Daily Log',
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: (_morningMilkQuantityMl > 0 || _afternoonMilkQuantityMl > 0 || _eveningMilkQuantityMl > 0 || _eggQuantity > 0)
                        ? _logHarvest
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStreakWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: AppTheme.primary,
                size: 36,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_streakCount Day Streak!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const Text(
                    'Keep it up!',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.trending_up, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsCarousel() {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildAlertCard(
            '⚠️ Cow Mary is 3 days away from calving!',
            AppTheme.warningDark,
          ),
          _buildAlertCard(
            '💉 Vaccine due for Batch B Broilers',
            Colors.blue.shade700,
          ),
          _buildAlertCard(
            '💧 Low inventory: Dairy Meal (2 bags left)',
            Colors.red.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(String message, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      width: 280,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildQuickLogCard({
    required String title,
    required IconData icon,
    required Color color,
    required int quantity,
    required Function(int) onAdd,
    required VoidCallback onRemove,
    required String incrementPillLabel,
    required int pillValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: onRemove,
                      color: AppTheme.textSecondary,
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => onAdd(10), // Base increment
                      color: AppTheme.primary,
                    ),
                    const Spacer(),
                    ActionChip(
                      label: Text(incrementPillLabel),
                      onPressed: () => onAdd(pillValue),
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
