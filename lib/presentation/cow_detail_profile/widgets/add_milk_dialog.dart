import 'package:flutter/material.dart';
import 'package:cowtrack/services/milk_service.dart';

class AddMilkDialog extends StatefulWidget {
  final String cattleId;
  const AddMilkDialog({super.key, required this.cattleId});

  @override
  State<AddMilkDialog> createState() => _AddMilkDialogState();
}

class _AddMilkDialogState extends State<AddMilkDialog> {
  final _qtyController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final qty = double.tryParse(_qtyController.text);
    if (qty == null || qty <= 0) return;

    setState(() => _saving = true);

    await MilkService().addMilkLog(
      cattleId: widget.cattleId,
      quantity: qty,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Milk'),
      content: TextField(
        controller: _qtyController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Milk (litres)',
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save')),
      ],
    );
  }
}
