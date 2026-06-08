import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/weather_widget.dart';
import '../bloc/farm_bloc.dart';
import '../bloc/farm_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/harvest_bloc.dart';
import '../bloc/asset_bloc.dart';
import '../../domain/entities/harvest_entry.dart';
import '../../domain/entities/asset_entity.dart';
import 'auth_screen.dart';

class HarvestHubScreen extends StatefulWidget {
  final String farmId;
  const HarvestHubScreen({super.key, required this.farmId});

  @override
  State<HarvestHubScreen> createState() => _HarvestHubScreenState();
}

class _HarvestHubScreenState extends State<HarvestHubScreen> {
  int _streakCount = 0; 
  double _morningMilkQuantityL = 0.0;
  double _afternoonMilkQuantityL = 0.0;
  double _eveningMilkQuantityL = 0.0;
  int _eggQuantity = 0;
  
  String? _selectedCowId;
  String? _selectedCowName;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    context.read<AssetBloc>().add(LoadAssets(widget.farmId));
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _logHarvest() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      return;
    }

    if (_morningMilkQuantityL > 0) {
      context.read<HarvestBloc>().add(AddHarvest(HarvestEntry(
        id: '', 
        farmId: widget.farmId, 
        assetId: _selectedCowId,
        assetName: _selectedCowName,
        quantity: _morningMilkQuantityL, 
        type: 'Milk (Morning)', 
        date: DateTime.now()
      )));
    }
    if (_afternoonMilkQuantityL > 0) {
       context.read<HarvestBloc>().add(AddHarvest(HarvestEntry(
        id: '', 
        farmId: widget.farmId, 
        assetId: _selectedCowId,
        assetName: _selectedCowName,
        quantity: _afternoonMilkQuantityL, 
        type: 'Milk (Afternoon)', 
        date: DateTime.now()
      )));
    }
    if (_eveningMilkQuantityL > 0) {
       context.read<HarvestBloc>().add(AddHarvest(HarvestEntry(
        id: '', 
        farmId: widget.farmId, 
        assetId: _selectedCowId,
        assetName: _selectedCowName,
        quantity: _eveningMilkQuantityL, 
        type: 'Milk (Evening)', 
        date: DateTime.now()
      )));
    }
    
    if (_eggQuantity > 0) {
       context.read<HarvestBloc>().add(AddHarvest(HarvestEntry(
        id: '', 
        farmId: widget.farmId, 
        quantity: _eggQuantity.toDouble(), 
        type: 'Eggs', 
        date: DateTime.now()
      )));
    }

    // Rich Haptic Feedback on successful save
    HapticFeedback.heavyImpact();
    _confettiController.play();

    setState(() {
      _streakCount++;
      _morningMilkQuantityL = 0.0;
      _afternoonMilkQuantityL = 0.0;
      _eveningMilkQuantityL = 0.0;
      _eggQuantity = 0;
      _selectedCowId = null;
      _selectedCowName = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Harvest Logged Successfully! Streak Increased 🔥'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _addQuantity(Function(double) updater, double val) {
    HapticFeedback.lightImpact();
    updater(val);
  }

  void _addEggQuantity(int val) {
    HapticFeedback.lightImpact();
    setState(() => _eggQuantity += val);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HarvestBloc, HarvestState>(
      listener: (context, state) {
        if (state is HarvestError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<FarmBloc, FarmState>(
        builder: (context, state) {
          String wardName = 'Your Farm';
          if (state is FarmSetupSuccess) {
            wardName = state.farm.ward;
          }

          return Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(
              title: const Text('Daily Harvest Hub'),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
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
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Howdy Farmer!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

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
                      const SizedBox(height: 12),
                      
                      _buildCowSelector(),

                      const SizedBox(height: 16),

                      _buildQuickLogCard(
                        title: 'Morning Milk (L)',
                        icon: Icons.water_drop,
                        color: Colors.blue.shade100,
                        quantity: _morningMilkQuantityL,
                        onAdd: (val) => _addQuantity((v) => setState(() => _morningMilkQuantityL += v), val),
                        onRemove: () {
                          HapticFeedback.lightImpact();
                          setState(
                            () => _morningMilkQuantityL = _morningMilkQuantityL > 0
                                ? _morningMilkQuantityL - 0.1
                                : 0,
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      _buildQuickLogCard(
                        title: 'Afternoon Milk (L)',
                        icon: Icons.water_drop,
                        color: Colors.yellow.shade100,
                        quantity: _afternoonMilkQuantityL,
                        onAdd: (val) => _addQuantity((v) => setState(() => _afternoonMilkQuantityL += v), val),
                        onRemove: () {
                          HapticFeedback.lightImpact();
                          setState(
                            () => _afternoonMilkQuantityL = _afternoonMilkQuantityL > 0
                                ? _afternoonMilkQuantityL - 0.1
                                : 0,
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      _buildQuickLogCard(
                        title: 'Evening Milk (L)',
                        icon: Icons.water_drop,
                        color: Colors.orange.shade100,
                        quantity: _eveningMilkQuantityL,
                        onAdd: (val) => _addQuantity((v) => setState(() => _eveningMilkQuantityL += v), val),
                        onRemove: () {
                          HapticFeedback.lightImpact();
                          setState(
                            () => _eveningMilkQuantityL = _eveningMilkQuantityL > 0
                                ? _eveningMilkQuantityL - 0.1
                                : 0,
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildEggLogCard(),

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
                          onPressed: ((_morningMilkQuantityL > 0 || _afternoonMilkQuantityL > 0 || _eveningMilkQuantityL > 0) && _selectedCowId != null) || (_eggQuantity > 0)
                              ? _logHarvest
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCowSelector() {
    return BlocBuilder<AssetBloc, AssetState>(
      builder: (context, state) {
        if (state is AssetLoaded) {
          final cows = state.assets.where((a) => a.type == 'livestock').toList();
          if (cows.isEmpty) return const Text('No cows found. Add one in Registry.', style: TextStyle(color: Colors.red, fontSize: 12));
          
          return DropdownButtonFormField<String>(
            value: _selectedCowId,
            hint: const Text('Select Cow to Log Milk'),
            items: cows.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
            onChanged: (val) {
              final cow = cows.firstWhere((c) => c.id == val);
              setState(() {
                _selectedCowId = val;
                _selectedCowName = cow.name;
              });
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          );
        }
        return const LinearProgressIndicator();
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
              const Icon(Icons.local_fire_department, color: AppTheme.primary, size: 36),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$_streakCount Day Streak!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  const Text('Keep it up!', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
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
          _buildAlertCard('⚠️ Cow Mary is 3 days away from calving!', AppTheme.warningDark),
          _buildAlertCard('💉 Vaccine due for Batch B Broilers', Colors.blue.shade700),
          _buildAlertCard('💧 Low inventory: Dairy Meal (2 bags left)', Colors.red.shade600),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Center(
        child: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _buildQuickLogCard({
    required String title,
    required IconData icon,
    required Color color,
    required double quantity,
    required Function(double) onAdd,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: onRemove, color: AppTheme.textSecondary),
                    Text(quantity.toStringAsFixed(2), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => onAdd(0.1), color: AppTheme.primary),
                    const Spacer(),
                    Wrap(
                      spacing: 4,
                      children: [
                        ActionChip(label: const Text('+1L'), onPressed: () => onAdd(1.0), backgroundColor: Colors.grey.shade100, labelStyle: const TextStyle(fontSize: 12)),
                        ActionChip(label: const Text('+0.5L'), onPressed: () => onAdd(0.5), backgroundColor: Colors.grey.shade100, labelStyle: const TextStyle(fontSize: 12)),
                      ],
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

  Widget _buildEggLogCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.brown.shade100, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.egg, size: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Collected Eggs', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline), 
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => _eggQuantity = _eggQuantity > 0 ? _eggQuantity - 1 : 0);
                      }, 
                      color: AppTheme.textSecondary
                    ),
                    Text('$_eggQuantity', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline), 
                      onPressed: () => _addEggQuantity(1), 
                      color: AppTheme.primary
                    ),
                    const Spacer(),
                    ActionChip(label: const Text('+5'), onPressed: () => _addEggQuantity(5), backgroundColor: Colors.grey.shade100),
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
