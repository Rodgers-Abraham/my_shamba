import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../bloc/asset_bloc.dart' as bloc;
import '../../core/theme/app_theme.dart';
import '../../domain/entities/asset_entity.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'auth_screen.dart';
import '../widgets/add_asset_dialog.dart';

class RegistryScreen extends StatefulWidget {
  final String farmId;
  const RegistryScreen({super.key, required this.farmId});

  @override
  State<RegistryScreen> createState() => _RegistryScreenState();
}

class _RegistryScreenState extends State<RegistryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<bloc.AssetBloc>().add(bloc.LoadAssets(widget.farmId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biological Registry'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: 'Livestock Profiles', icon: Icon(Icons.pets)),
            Tab(text: 'Crop Matrix Blocks', icon: Icon(Icons.grass)),
          ],
        ),
      ),
      body: BlocListener<bloc.AssetBloc, bloc.AssetState>(
        listener: (context, state) {
          if (state is bloc.AssetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<bloc.AssetBloc, bloc.AssetState>(
          builder: (context, state) {
            if (state is bloc.AssetLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is bloc.AssetLoaded) {
              final livestock = state.assets.where((a) => a.type == 'livestock').toList();
              final crops = state.assets.where((a) => a.type == 'crop').toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildListView(livestock, isLivestock: true),
                  _buildListView(crops, isLivestock: false),
                ],
              );
            }
            return const Center(child: Text('No assets registered.'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => _showAddAssetDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddAssetDialog(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddAssetDialog(farmId: widget.farmId),
    );
  }

  Widget _buildListView(List<AssetEntity> assets, {required bool isLivestock}) {
    if (assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isLivestock ? Icons.pets : Icons.eco, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No ${isLivestock ? 'Livestock' : 'Crops'} found.', style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isLivestock ? Colors.blue.shade100 : Colors.green.shade100,
              child: Icon(isLivestock ? Icons.pets : Icons.grass, color: isLivestock ? Colors.blue.shade700 : Colors.green.shade700),
            ),
            title: Text(asset.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (asset is LivestockEntity) ...[
                  _buildStatusBadge(asset.status),
                ] else if (asset is CropEntity) ...[
                  Text('Variety: ${asset.variety}', style: const TextStyle(color: AppTheme.textSecondary)),
                ],
              ],
            ),
            onTap: () => _showDossier(context, asset),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status.toLowerCase().contains('milking')) color = AppTheme.success;
    if (status.toLowerCase().contains('pregnant')) color = AppTheme.warningDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 4),
          Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showDossier(BuildContext context, AssetEntity asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(asset.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                  if (asset is LivestockEntity) _buildStatusBadge(asset.status),
                ],
              ),
              const Divider(height: 32),
              if (asset is CropEntity) ...[
                const Text('Milestones Reached', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMilestoneChip('Planted', asset.isPlanted),
                    _buildMilestoneChip('Weeded', asset.isWeeded),
                    _buildMilestoneChip('Fumigated', asset.isFumigated),
                    _buildMilestoneChip('Top Dressed', asset.isTopDressed),
                    _buildMilestoneChip('Pruned', asset.isPruned),
                    _buildMilestoneChip('Harvested', asset.isHarvested),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              if (asset is LivestockEntity) ...[
                const Text('Reproductive Progress Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                _buildTimelineWidget(asset.status.toLowerCase().contains('pregnant') ? 0.6 : 0.0),
                const SizedBox(height: 32),
              ],
              const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(asset.notes ?? 'No notes added.', style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              const Text('Activity Feed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildActivityItem('Registered in System', asset.createdAt.toString().substring(0, 10), Icons.app_registration),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMilestoneChip(String label, bool isDone) {
    return Chip(
      label: Text(label),
      backgroundColor: isDone ? AppTheme.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
      labelStyle: TextStyle(
        color: isDone ? AppTheme.primary : AppTheme.textSecondary,
        fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(color: isDone ? AppTheme.primary : Colors.grey.shade300),
    );
  }

  Widget _buildTimelineWidget(double progress) {
    int currentStage = 0;
    if (progress > 0.3) currentStage = 1;
    if (progress > 0.6) currentStage = 2;
    if (progress > 0.9) currentStage = 3;

    return Column(
      children: [
        _buildTimelineNode(
          isFirst: true,
          isLast: false,
          isPast: currentStage >= 0,
          title: 'Insemination',
          subtitle: 'Day 0: Registration',
        ),
        _buildTimelineNode(
          isFirst: false,
          isLast: false,
          isPast: currentStage >= 1,
          title: 'Growth / Gestation',
          subtitle: 'Day 30: Feed Transition',
        ),
        _buildTimelineNode(
          isFirst: false,
          isLast: false,
          isPast: currentStage >= 2,
          title: 'Pre-harvest / Dry period',
          subtitle: 'Day 200: Final preparations',
        ),
        _buildTimelineNode(
          isFirst: false,
          isLast: true,
          isPast: currentStage >= 3,
          title: 'Calving',
          subtitle: 'Expected yield / birth',
        ),
      ],
    );
  }

  Widget _buildTimelineNode({
    required bool isFirst,
    required bool isLast,
    required bool isPast,
    required String title,
    required String subtitle,
  }) {
    return SizedBox(
      height: 70,
      child: TimelineTile(
        isFirst: isFirst,
        isLast: isLast,
        beforeLineStyle: LineStyle(
          color: isPast ? AppTheme.primary : Colors.grey.shade300,
          thickness: 3,
        ),
        indicatorStyle: IndicatorStyle(
          width: 30,
          color: isPast ? AppTheme.primary : Colors.grey.shade300,
          iconStyle: IconStyle(
            iconData: isPast ? Icons.check : Icons.circle,
            color: isPast ? Colors.white : Colors.grey.shade400,
          ),
        ),
        endChild: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
          },
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPast ? AppTheme.primary.withValues(alpha: 0.1) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isPast ? AppTheme.primary.withValues(alpha: 0.3) : Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isPast ? AppTheme.primary : AppTheme.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.background, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: AppTheme.textPrimary),
      ),
      title: Text(title),
      subtitle: Text(time),
      contentPadding: EdgeInsets.zero,
    );
  }
}
