// lib/presentation/cattle/cattle_list_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cowtrack/models/cattle.dart';
import 'package:cowtrack/services/cattle_service.dart';
import 'package:cowtrack/services/storage_service.dart';
import 'package:cowtrack/presentation/cattle/widgets/add_edit_cattle_dialog.dart';

class CattleListPage extends StatefulWidget {
  const CattleListPage({Key? key}) : super(key: key);

  @override
  State<CattleListPage> createState() => _CattleListPageState();
}

class _CattleListPageState extends State<CattleListPage> {
  final CattleService _service = CattleService();
  final StorageService _storage = StorageService();

  late final String _ownerId;

  @override
  void initState() {
    super.initState();
    _ownerId = FirebaseAuth.instance.currentUser!.uid;
    debugPrint("CattleListPage UID: $_ownerId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cattle')),
      body: StreamBuilder<List<Cattle>>(
        stream: _service.streamAllCattleForOwner(_ownerId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final list = snap.data ?? [];

          if (list.isEmpty) {
            return const Center(
              child: Text('No cattle yet. Tap + to add one.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final cow = list[index];

              return Dismissible(
                key: Key(cow.id),
                direction: DismissDirection.startToEnd,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) => _confirmDelete(cow),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundImage: cow.photoUrl != null
                          ? NetworkImage(cow.photoUrl!)
                          : null,
                      child: cow.photoUrl == null
                          ? Text(
                        cow.name.isNotEmpty ? cow.name[0].toUpperCase() : '?',
                      )
                          : null,
                    ),
                    title: Text(cow.name),
                    subtitle: Text('Tag: ${cow.tagId} • Breed: ${cow.breed}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'open') {
                          Navigator.pushNamed(
                            context,
                            '/cattle-detail',
                            arguments: {
                              'cattleId': cow.id,
                              'cattleName': cow.name,
                            },
                          );
                        } else if (v == 'edit') {
                          await _onEditCattle(cow);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'open', child: Text('Open')),
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/cattle-detail',
                        arguments: {
                          'cattleId': cow.id,
                          'cattleName': cow.name,
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddCattle,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool> _confirmDelete(Cattle cow) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Cattle'),
        content: Text('Delete "${cow.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.deleteCattle(cow.id);
    }
    return confirmed ?? false;
  }

  Future<void> _onAddCattle() async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (_) => const AddEditCattleDialog(),
    );

    if (result == null) return;

    final Cattle? cattle = result['cattle'] as Cattle?;
    final File? photo = result['photo'] as File?;

    if (cattle == null) return;

    final payload = Map<String, dynamic>.from(cattle.toMap());
    payload['ownerId'] = _ownerId;

    final docId = await _service.createCattleAndReturnId(payload);

    if (photo != null) {
      final url = await _storage.uploadCattlePhoto(photo, cattleId: docId);
      if (url != null) {
        await _service.updateCattle(docId, {'photoUrl': url});
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cattle added')));
    }
  }

  Future<void> _onEditCattle(Cattle existing) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (_) => AddEditCattleDialog(existing: existing),
    );

    if (result == null) return;

    final Cattle? cattle = result['cattle'] as Cattle?;
    final File? photo = result['photo'] as File?;

    if (cattle == null) return;

    await _service.updateCattle(existing.id, cattle.toMap());

    if (photo != null) {
      final url =
      await _storage.uploadCattlePhoto(photo, cattleId: existing.id);
      if (url != null) {
        await _service.updateCattle(existing.id, {'photoUrl': url});
      }
    }
  }
}
