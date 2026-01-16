import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../models/cattle.dart';
import 'widgets/add_milk_dialog.dart';

class CowDetailProfile extends StatefulWidget {
  final Cattle cattle;

  const CowDetailProfile({super.key, required this.cattle});

  @override
  State<CowDetailProfile> createState() => _CowDetailProfileState();
}

class _CowDetailProfileState extends State<CowDetailProfile> {
  DateTimeRange? selectedRange;
  bool loading = false;
  List<Map<String, dynamic>> milkLogs = [];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedRange = DateTimeRange(
      start: now.subtract(const Duration(days: 6)),
      end: now,
    );

    _loadMilk();
  }

  Future<void> _loadMilk() async {
    setState(() => loading = true);

    final snap = await FirebaseFirestore.instance
        .collection('milk_logs')
        .where('cowId', isEqualTo: widget.cattle.id)
        .orderBy('date', descending: true)
        .limit(50)
        .get();

    List<Map<String, dynamic>> logs = snap.docs.map((d) {
      return {
        'date': (d['date'] as Timestamp).toDate(),
        'quantity': (d['quantity'] as num).toDouble(),
      };
    }).toList();

    if (selectedRange != null) {
      logs = logs.where((m) {
        final date = m['date'] as DateTime;
        return date.isAfter(
            selectedRange!.start.subtract(const Duration(days: 1))) &&
            date.isBefore(
                selectedRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    if (!mounted) return;
    setState(() {
      milkLogs = logs;
      loading = false;
    });
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
      initialDateRange: selectedRange,
    );

    if (picked == null) return;

    if (picked.duration.inDays > 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a maximum of 7 days'),
        ),
      );
      return;
    }

    setState(() => selectedRange = picked);
    _loadMilk();
  }

  Future<void> _addMilk() async {
    final result = await showDialog(
      context: context,
      builder: (_) => AddMilkDialog(
        cattleId: widget.cattle.id,
        cattleName: widget.cattle.name,
      ),
    );

    if (result == true) _loadMilk();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cattle;

    return Scaffold(
      appBar: AppBar(title: Text(c.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMilk,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// PHOTO
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: c.photoUrl == null
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 40),
                    SizedBox(height: 8),
                    Text('No photo available'),
                  ],
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  c.photoUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _info('Name', c.name),
            _info('Tag', c.tagId),
            _info('Breed', c.breed),
            _info(
              'DOB',
              c.dob == null
                  ? '-'
                  : DateFormat.yMMMd().format(c.dob!),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Milk Entries',
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Select range'),
                  onPressed: _pickRange,
                ),
              ],
            ),

            if (selectedRange != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${DateFormat.yMMMd().format(selectedRange!.start)} - '
                      '${DateFormat.yMMMd().format(selectedRange!.end)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

            loading
                ? const Center(child: CircularProgressIndicator())
                : milkLogs.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No milk entries')),
            )
                : ListView.separated(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              itemCount: milkLogs.length,
              separatorBuilder: (_, __) =>
              const Divider(),
              itemBuilder: (_, i) {
                final log = milkLogs[i];
                return ListTile(
                  leading: const Icon(
                    Icons.water_drop,
                    color: Colors.blue,
                  ),
                  title: Text(
                    DateFormat.yMMMd()
                        .format(log['date']),
                  ),
                  trailing: Text(
                    '${log['quantity']} L',
                    style: const TextStyle(
                        fontWeight:
                        FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
