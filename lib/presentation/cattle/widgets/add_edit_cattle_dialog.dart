// lib/presentation/cattle/widgets/add_edit_cattle_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cowtrack/models/cattle.dart';

/// Dialog used for both Add and Edit.
/// Returns a Map on pop:
/// {
///   'create': bool,       // true = create, false = edit
///   'cattle': Cattle,     // cattle object (id empty for create)
///   'photo': File?        // optional photo file (not uploaded yet)
/// }
class AddEditCattleDialog extends StatefulWidget {
  final Cattle? existing;
  const AddEditCattleDialog({Key? key, this.existing}) : super(key: key);

  @override
  State<AddEditCattleDialog> createState() => _AddEditCattleDialogState();
}

class _AddEditCattleDialogState extends State<AddEditCattleDialog> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameCtl;
  late final TextEditingController _tagCtl;
  late final TextEditingController _breedCtl;
  DateTime? _dob;
  File? _photoFile;
  String? _photoUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _nameCtl = TextEditingController(text: ex?.name ?? '');
    _tagCtl = TextEditingController(text: ex?.tagId ?? '');
    _breedCtl = TextEditingController(text: ex?.breed ?? '');
    _dob = ex?.dob;
    _photoUrl = ex?.photoUrl;
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _tagCtl.dispose();
    _breedCtl.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final XFile? x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (x == null) return;
    setState(() => _photoFile = File(x.path));
  }

  Future<void> _takePhoto() async {
    final XFile? x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (x == null) return;
    setState(() => _photoFile = File(x.path));
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 2),
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (selected != null) setState(() => _dob = selected);
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final cattle = Cattle(
      id: widget.existing?.id ?? '', // empty for create; service will create doc
      name: _nameCtl.text.trim(),
      tagId: _tagCtl.text.trim(),
      dob: _dob,
      breed: _breedCtl.text.trim(),
      status: widget.existing?.status ?? 'healthy',
      lastMilk: widget.existing?.lastMilk ?? 0,
      photoUrl: widget.existing?.photoUrl,
      ownerId: widget.existing?.ownerId,
    );

    final result = <String, dynamic>{
      'create': widget.existing == null,
      'cattle': cattle,
      'photo': _photoFile
    };

    setState(() => _isSaving = false);
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.existing;
    return AlertDialog(
      title: Text(ex == null ? 'Add Cattle' : 'Edit ${ex.name}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // photo preview
            GestureDetector(
              onTap: _pickFromGallery,
              child: CircleAvatar(
                radius: 44,
                backgroundImage: _photoFile != null
                    ? FileImage(_photoFile!)
                    : (_photoUrl != null ? NetworkImage(_photoUrl!) as ImageProvider : null),
                child: _photoFile == null && _photoUrl == null
                    ? const Icon(Icons.add_a_photo, size: 32)
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextButton.icon(onPressed: _pickFromGallery, icon: const Icon(Icons.photo_library), label: const Text('Gallery')),
              const SizedBox(width: 8),
              TextButton.icon(onPressed: _takePhoto, icon: const Icon(Icons.camera_alt), label: const Text('Camera')),
            ]),

            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtl,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            TextFormField(controller: _tagCtl, decoration: const InputDecoration(labelText: 'Tag ID')),
            TextFormField(controller: _breedCtl, decoration: const InputDecoration(labelText: 'Breed')),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text(_dob == null ? 'DOB not set' : DateFormat.yMMMd().format(_dob!))),
              TextButton(onPressed: _pickDob, child: const Text('Select DOB'))
            ]),
            if (_isSaving) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _onSavePressed, child: const Text('Save')),
      ],
    );
  }
}
