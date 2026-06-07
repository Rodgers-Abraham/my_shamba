import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/inputs_parser.dart';
import '../../domain/entities/asset_entity.dart';
import '../bloc/asset_bloc.dart';
import '../../core/theme/app_theme.dart';

class AddAssetDialog extends StatefulWidget {
  final String farmId;
  const AddAssetDialog({super.key, required this.farmId});

  @override
  State<AddAssetDialog> createState() => _AddAssetDialogState();
}

class _AddAssetDialogState extends State<AddAssetDialog> {
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _selectedType = 'Livestock';
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedItem;
  String? _selectedVariety;
  String? _selectedStatus;

  // Crop milestones
  bool _isPlanted = false;
  bool _isWeeded = false;
  bool _isFumigated = false;
  bool _isTopDressed = false;
  bool _isPruned = false;
  bool _isHarvested = false;

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
        _selectedCategory = 'Livestock';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        content: SizedBox(
            height: 100, child: Center(child: CircularProgressIndicator())),
      );
    }

    final categories = ['Livestock', 'Crops'];
    List<String> subcategories =
        InputsParser.getSubcategories(_parsedData, _selectedCategory ?? '');
    List<String> items = [];
    if (_selectedSubcategory != null) {
      items = InputsParser.getItems(
          _parsedData, _selectedCategory!, _selectedSubcategory!);
    }

    List<String> varieties = [];
    if (_selectedItem != null) {
      varieties = InputsParser.getVarieties(_parsedData, _selectedCategory!,
          _selectedSubcategory!, _selectedItem!);
    }

    return AlertDialog(
      title: const Text('Add Asset'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration:
                  const InputDecoration(labelText: 'Name (e.g. Cow Mary)'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                  _selectedType = val!;
                  _selectedSubcategory = null;
                  _selectedItem = null;
                  _selectedVariety = null;
                  _selectedStatus = null;
                });
              },
              decoration: const InputDecoration(labelText: 'Asset Type'),
            ),
            const SizedBox(height: 16),
            if (subcategories.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedSubcategory,
                items: subcategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSubcategory = val;
                    _selectedItem = null;
                    _selectedVariety = null;
                  });
                },
                decoration: const InputDecoration(labelText: 'Subcategory'),
                isExpanded: true,
              ),
            const SizedBox(height: 16),
            if (items.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedItem,
                items: items
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedItem = val;
                    _selectedVariety = null;
                  });
                },
                decoration: const InputDecoration(labelText: 'Item'),
                isExpanded: true,
              ),
            const SizedBox(height: 16),
            if (varieties.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedVariety,
                items: varieties
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedVariety = val;
                  });
                },
                decoration: InputDecoration(
                    labelText: _selectedType == 'Livestock'
                        ? 'Breed/Type'
                        : 'Variety'),
                isExpanded: true,
              ),
            if (_selectedType == 'Livestock') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: const [
                  DropdownMenuItem(value: 'Healthy', child: Text('Healthy')),
                  DropdownMenuItem(value: 'Pregnant', child: Text('Pregnant')),
                  DropdownMenuItem(value: 'Milking', child: Text('Milking')),
                  DropdownMenuItem(value: 'Sick', child: Text('Sick')),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedStatus = val;
                  });
                },
                decoration:
                    const InputDecoration(labelText: 'Status (Optional)'),
              ),
            ],
            if (_selectedType == 'Crops') ...[
              const SizedBox(height: 16),
              const Text('Crops Milestones:', style: TextStyle(fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: const Text('Planted'),
                value: _isPlanted,
                onChanged: (val) => setState(() => _isPlanted = val!),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('Weeded'),
                value: _isWeeded,
                onChanged: (val) => setState(() => _isWeeded = val!),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('Fumigated'),
                value: _isFumigated,
                onChanged: (val) => setState(() => _isFumigated = val!),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('Top Dressed'),
                value: _isTopDressed,
                onChanged: (val) => setState(() => _isTopDressed = val!),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('Pruned'),
                value: _isPruned,
                onChanged: (val) => setState(() => _isPruned = val!),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('Harvested'),
                value: _isHarvested,
                onChanged: (val) => setState(() => _isHarvested = val!),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes (Optional)'),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_nameCtrl.text.isEmpty) return;

            AssetEntity newAsset;
            if (_selectedType == 'Livestock') {
              newAsset = LivestockEntity(
                id: '', // Generated by repo
                farmId: widget.farmId,
                name: _nameCtrl.text,
                createdAt: DateTime.now(),
                status: _selectedStatus ?? 'Healthy',
                notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
              );
            } else {
              newAsset = CropEntity(
                id: '',
                farmId: widget.farmId,
                name: _nameCtrl.text,
                createdAt: DateTime.now(),
                variety: _selectedVariety ?? 'Unknown',
                notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
                isPlanted: _isPlanted,
                isWeeded: _isWeeded,
                isFumigated: _isFumigated,
                isTopDressed: _isTopDressed,
                isPruned: _isPruned,
                isHarvested: _isHarvested,
              );
            }

            context.read<AssetBloc>().add(AddAsset(newAsset));
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Asset Added! Streak Update 🔥'), backgroundColor: AppTheme.primary));
            Navigator.pop(context);
          },
          child: const Text('Save'),
        )
      ],
    );
  }
}
