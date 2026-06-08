import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/supply_bloc.dart';
import '../bloc/supply_state.dart';
import '../bloc/supply_event.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/supply_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'auth_screen.dart';
import '../widgets/add_supply_dialog.dart';

class WorkshopScreen extends StatefulWidget {
  final String farmId;
  const WorkshopScreen({super.key, required this.farmId});

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<SupplyBloc>().add(LoadSupplies(widget.farmId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Workshop & Supplies'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: 'Durable Tools', icon: Icon(Icons.build)),
            Tab(text: 'Consumables', icon: Icon(Icons.inventory_2)),
          ],
        ),
      ),
      body: BlocListener<SupplyBloc, SupplyState>(
        listener: (context, state) {
          if (state is SupplyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<SupplyBloc, SupplyState>(
          builder: (context, state) {
            if (state is SupplyLoading) return const Center(child: CircularProgressIndicator());
            
            if (state is SupplyLoaded) {
              final durables = state.supplies.where((s) => s.category.toLowerCase() == 'tool' || s.category.toLowerCase() == 'durable').toList();
              final consumables = state.supplies.where((s) => s.category.toLowerCase() == 'consumable').toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildListView(durables, isConsumable: false),
                  _buildListView(consumables, isConsumable: true),
                ],
              );
            }
            return const Center(child: Text('No supplies found.'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => _showAddSupplyDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddSupplyDialog(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddSupplyDialog(farmId: widget.farmId),
    );
  }

  Widget _buildListView(List<SupplyEntity> supplies, {required bool isConsumable}) {
    if (supplies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isConsumable ? Icons.inventory_2 : Icons.build, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No ${isConsumable ? 'Consumables' : 'Tools'} found.', style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: supplies.length,
      itemBuilder: (context, index) {
        final supply = supplies[index];
        final isLowInventory = isConsumable && supply.quantity < 5.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isConsumable ? Colors.purple.shade100 : Colors.teal.shade100,
              child: Icon(isConsumable ? Icons.local_shipping : Icons.handyman, 
                color: isConsumable ? Colors.purple.shade700 : Colors.teal.shade700),
            ),
            title: Text(supply.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${supply.category}'),
                if (isLowInventory)
                  const Text('⚠️ Low Inventory Alert', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isLowInventory ? Colors.red.withOpacity(0.1) : AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${supply.quantity} ${supply.unit}',
                style: TextStyle(
                  color: isLowInventory ? Colors.red : AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
