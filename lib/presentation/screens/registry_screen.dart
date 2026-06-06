import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      body: BlocBuilder<bloc.AssetBloc, bloc.AssetState>(
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () {
          _showAddAssetDialog(context);
        },
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
            onTap: () {
              if (isLivestock) {
                _showDossier(context, asset as LivestockEntity);
              }
            },
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

  void _showDossier(BuildContext context, LivestockEntity asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(asset.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  _buildStatusBadge(asset.status),
                ],
              ),
              const Divider(height: 32),
              const Text('Reproductive Progress Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              _buildTimelineWidget(asset.status.toLowerCase().contains('pregnant') ? 0.6 : 0.0), // Mock progress
              const SizedBox(height: 32),
              const Text('Activity Feed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildActivityItem('Vaccination: FMD', '2 days ago', Icons.vaccines),
                    _buildActivityItem('Moved to Pasture B', '1 week ago', Icons.place),
                    _buildActivityItem('Registered in System', '2 weeks ago', Icons.app_registration),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineWidget(double progress) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          color: AppTheme.primary,
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Insemination', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            Text('Calving', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ],
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
