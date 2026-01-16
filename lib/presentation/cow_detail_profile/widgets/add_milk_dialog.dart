import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddMilkDialog extends StatefulWidget {
  final String cattleId;
  final String? cattleName;

  // 👇 NEW (for edit)
  final String? docId;
  final double? initialQty;
  final DateTime? initialDate;

  const AddMilkDialog({
    super.key,
    required this.cattleId,
    this.cattleName,
    this.docId,
    this.initialQty,
    this.initialDate,
  });

  @override
  State<AddMilkDialog> createState() => _AddMilkDialogState();
}

class _AddMilkDialogState extends State<AddMilkDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _qtyController;

  late DateTime _selectedDate;
  bool _saving = false;

  bool get _isEdit => widget.docId != null;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(
      text: widget.initialQty?.toString() ?? '',
    );
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  /// DATE PICKER
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// SAVE / UPDATE MILK LOG
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final payload = {
        'cowId': widget.cattleId,
        'cowName': widget.cattleName,
        'ownerId': user.uid,
        'quantity': double.parse(_qtyController.text),
        'date': Timestamp.fromDate(_selectedDate),
      };

      final ref = FirebaseFirestore.instance.collection('milk_logs');

      if (_isEdit) {
        // ✏️ UPDATE EXISTING
        await ref.doc(widget.docId).update(payload);
      } else {
        // ➕ ADD NEW
        await ref.add({
          ...payload,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save milk entry')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// TITLE
              Text(
                _isEdit
                    ? 'Edit Milk Entry'
                    : widget.cattleName != null
                    ? 'Milk Entry – ${widget.cattleName}'
                    : 'Add Milk Entry',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              /// QUANTITY INPUT
              TextFormField(
                controller: _qtyController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Quantity (Litres)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter quantity';
                  }
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) {
                    return 'Enter a valid quantity';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              /// DATE PICKER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat.yMMMMd().format(_selectedDate)),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Pick date'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (_saving) const LinearProgressIndicator(),

              const SizedBox(height: 12),

              /// ACTION BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                    _saving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_isEdit ? 'Update' : 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
