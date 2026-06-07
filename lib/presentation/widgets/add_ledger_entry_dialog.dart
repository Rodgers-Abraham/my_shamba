import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ledger_bloc.dart';

class AddLedgerEntryDialog extends StatefulWidget {
  final String farmId;
  const AddLedgerEntryDialog({super.key, required this.farmId});

  @override
  State<AddLedgerEntryDialog> createState() => _AddLedgerEntryDialogState();
}

class _AddLedgerEntryDialogState extends State<AddLedgerEntryDialog> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _partyCtrl = TextEditingController();
  String _selectedCategory = 'Income';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Transaction'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              items: const [
                DropdownMenuItem(value: 'Income', child: Text('Income (+)')),
                DropdownMenuItem(value: 'Expense', child: Text('Expense (-)')),
              ],
              onChanged: (val) => setState(() => _selectedCategory = val!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (KES)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                  labelText: 'Description (e.g. Sales, Wages)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _partyCtrl,
              decoration: const InputDecoration(
                  labelText: 'Associated Person (e.g. Worker name, Buyer)'),
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
            final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
            if (amount <= 0 || _descCtrl.text.isEmpty) return;

            context.read<LedgerBloc>().add(AddEntry(
                  farmId: widget.farmId,
                  amount: amount,
                  category: _selectedCategory,
                  description: _descCtrl.text,
                  date: DateTime.now(),
                  associatedParty: _partyCtrl.text,
                ));

            Navigator.pop(context);
          },
          child: const Text('Save'),
        )
      ],
    );
  }
}
