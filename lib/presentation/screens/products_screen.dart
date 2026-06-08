import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/inputs_parser.dart';
import '../../domain/entities/supply_entity.dart';
import '../bloc/supply_bloc.dart';
import '../bloc/supply_event.dart';
import '../bloc/supply_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'auth_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String farmId;
  const ProductsScreen({super.key, required this.farmId});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SupplyBloc>().add(LoadSupplies(widget.farmId));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Farm Products & Inputs'),
          bottom: const TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            tabs: [
              Tab(text: 'Produce (Inventory)', icon: Icon(Icons.agriculture)),
              Tab(text: 'Farm Inputs', icon: Icon(Icons.science)),
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
              if (state is SupplyLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is SupplyLoaded) {
                final produce = state.supplies.where((s) => s.category == 'Produce').toList();
                final inputs = state.supplies.where((s) => s.category == 'Input').toList();
                return TabBarView(
                  children: [
                    _buildListView(produce, Icons.grass, Colors.amber),
                    _buildListView(inputs, Icons.science, Colors.blue),
                  ],
                );
              }
              return const Center(child: Text('No items found.'));
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.primary,
          onPressed: () => _showAddProductDialog(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildListView(List<SupplyEntity> items, IconData icon, MaterialColor color) {
    if (items.isEmpty) {
      return Center(
        child: Text('No items registered.', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.shade100,
              child: Icon(icon, color: color.shade800),
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text('${item.quantity} ${item.unit}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _AddProductDialog(farmId: widget.farmId),
    );
  }
}

class _AddProductDialog extends StatefulWidget {
  final String farmId;
  const _AddProductDialog({required this.farmId});

  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  final _qtyCtrl = TextEditingController();
  String _selectedTab = 'Produce';
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedItem;
  List<dynamic> _parsedData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await InputsParser.parseInputs();
    if (mounted) {
      setState(() {
        _parsedData = data;
        _isLoading = false;
        _selectedCategory = 'Crops';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const AlertDialog(content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())));

    final categories = _selectedTab == 'Produce' ? ['Crops'] : ['Agricultural Inputs'];
    List<String> subcategories = InputsParser.getSubcategories(_parsedData, _selectedCategory ?? categories.first);
    List<String> items = [];
    if (_selectedSubcategory != null) {
      items = InputsParser.getItems(_parsedData, _selectedCategory ?? categories.first, _selectedSubcategory!);
    }

    return AlertDialog(
      title: const Text('Add Inventory'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedTab,
              items: const [
                DropdownMenuItem(value: 'Produce', child: Text('Produce (Grains/Cereals)')),
                DropdownMenuItem(value: 'Input', child: Text('Farm Input (Fertilizer/Seed)')),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedTab = val!;
                  _selectedCategory = _selectedTab == 'Produce' ? 'Crops' : 'Agricultural Inputs';
                  _selectedSubcategory = null;
                  _selectedItem = null;
                });
              },
              decoration: const InputDecoration(labelText: 'Inventory Type'),
            ),
            const SizedBox(height: 16),
            if (subcategories.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: _selectedSubcategory,
                items: subcategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() { _selectedSubcategory = val; _selectedItem = null; }),
                decoration: const InputDecoration(labelText: 'Subcategory'),
                isExpanded: true,
              ),
            const SizedBox(height: 16),
            if (items.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: _selectedItem,
                items: items.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedItem = val),
                decoration: const InputDecoration(labelText: 'Item'),
                isExpanded: true,
              ),
            const SizedBox(height: 16),
            TextField(controller: _qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_selectedItem == null || _qtyCtrl.text.isEmpty) return;
            final qty = double.tryParse(_qtyCtrl.text) ?? 0.0;
            final newSupply = SupplyEntity(id: '', farmId: widget.farmId, name: _selectedItem!, category: _selectedTab, quantity: qty, unit: 'Units');
            context.read<SupplyBloc>().add(AddSupply(newSupply));
            Navigator.pop(context);
          },
          child: const Text('Save'),
        )
      ],
    );
  }
}
