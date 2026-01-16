import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddMilkDialog extends StatefulWidget {
  final String cattleId;
  final String? cattleName;

  const AddMilkDialog({
    Key? key,
    required this.cattleId,
    this.cattleName,
  }) : super(key: key);

  @override
  State<AddMilkDialog> createState() => _AddMilkDialogState();
}

class _AddMilkDialogState extends State<AddMilkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

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
      await FirebaseFirestore.instance.collection('milk_logs').add({
        'cowId': widget.cattleId,
        'ownerId': user.uid, // ✅ THIS FIXES EVERYTHING
        'quantity': double.parse(_qtyController.text),
        'date': Timestamp.fromDate(_selectedDate),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save milk log')),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.cattleName != null
                    ? 'Milk Entry – ${widget.cattleName}'
                    : 'Add Milk Entry',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: 'Quantity (Litres)'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter quantity';
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) {
                    return 'Enter valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: const Text('Save'),
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
