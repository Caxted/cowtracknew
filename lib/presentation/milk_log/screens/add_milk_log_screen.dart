import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddMilkLogScreen extends StatefulWidget {
  final String cowId;
  final String cowName;

  const AddMilkLogScreen({
    Key? key,
    required this.cowId,
    required this.cowName,
  }) : super(key: key);

  @override
  State<AddMilkLogScreen> createState() => _AddMilkLogScreenState();
}

class _AddMilkLogScreenState extends State<AddMilkLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() => _selectedDate = selected);
    }
  }

  Future<void> _saveLog() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('milk_logs').add({
        'cowId': widget.cowId,
        'cowName': widget.cowName, // ✅ helpful for analytics
        'ownerId': user.uid,       // ✅ REQUIRED
        'quantity': double.parse(_qtyCtl.text),
        'date': Timestamp.fromDate(_selectedDate), // ✅ Timestamp
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save log')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _qtyCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Milk Entry for ${widget.cowName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _qtyCtl,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: 'Quantity (L)'),
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
                    child: const Text("Pick Date"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isSaving) const LinearProgressIndicator(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveLog,
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
