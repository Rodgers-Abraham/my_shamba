import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/inputs_parser.dart';
import '../../domain/entities/supply_entity.dart';
import '../bloc/supply_bloc.dart';
import '../bloc/supply_event.dart';

class AddSupplyDialog extends StatefulWidget {
  final String farmId;
  const AddSupplyDialog({super.key, required this.farmId});

  @override
  State<AddSupplyDialog> createState() => _AddSupplyDialogState();
}

class _AddSupplyDialogState extends State<AddSupplyDialog> {
  final _qtyCtrl = TextEditingController();

  String _selectedCategory = 'Agricultural Inputs';
  String? _selectedSubcategory;
  String? _selectedItem;
  String? _selectedVariety;

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
        _selectedCategory = 'Agricultural Inputs';
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

    final categories = ['Agricultural Inputs', 'Forestry & Timber'];
    List<String> subcategories =
        InputsParser.getSubcategories(_parsedData, _selectedCategory);
    List<String> items = [];
    if (_selectedSubcategory != null) {
      items = InputsParser.getItems(
          _parsedData, _selectedCategory, _selectedSubcategory!);
    }

    List<String> varieties = [];
    if (_selectedItem != null) {
      varieties = InputsParser.getVarieties(_parsedData, _selectedCategory,
          _selectedSubcategory!, _selectedItem!);
    }

    return AlertDialog(
      title: const Text('Add Supply/Tool'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val!;
                  _selectedSubcategory = null;
                  _selectedItem = null;
                  _selectedVariety = null;
                });
              },
              decoration: const InputDecoration(labelText: 'Main Category'),
            ),
            const SizedBox(height: 16),
            if (subcategories.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: _selectedSubcategory,
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
                initialValue: _selectedItem,
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
                initialValue: _selectedVariety,
                items: varieties
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedVariety = val;
                  });
                },
                decoration: const InputDecoration(labelText: 'Type/Variety'),
                isExpanded: true,
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
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
            if (_selectedItem == null || _qtyCtrl.text.isEmpty) return;

            final qty = double.tryParse(_qtyCtrl.text) ?? 0.0;
            String name = _selectedItem!;
            if (_selectedVariety != null) {
              name += ' ($_selectedVariety)';
            }

            final newSupply = SupplyEntity(
              id: '',
              farmId: widget.farmId,
              name: name,
              category: _selectedSubcategory?.contains('Tool') == true ||
                      _selectedCategory == 'Forestry & Timber'
                  ? 'Tool'
                  : 'Consumable',
              quantity: qty,
              unit: 'Units', // Could be made dynamic
            );

            context.read<SupplyBloc>().add(AddSupply(newSupply));
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Supply Added!')));
            Navigator.pop(context);
          },
          child: const Text('Save'),
        )
      ],
    );
  }
}
