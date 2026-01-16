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
  bool loading = false;

  DateTimeRange? selectedRange;
  List<Map<String, dynamic>> milkLogs = [];

  @override
  void initState() {
    super.initState();

    /// Default: last 7 days
    final now = DateTime.now();
    selectedRange = DateTimeRange(
      start: now.subtract(const Duration(days: 6)),
      end: now,
    );

    _loadMilk();
  }

  /// ✅ LOAD MILK SAFELY (NO INDEX REQUIRED)
  Future<void> _loadMilk() async {
    setState(() => loading = true);

    try {
      final snap = await FirebaseFirestore.instance
          .collection('milk_logs')
          .where('cowId', isEqualTo: widget.cattle.id)
          .orderBy('date', descending: true)
          .get();

      List<Map<String, dynamic>> logs = snap.docs.map((d) {
        return {
          'date': (d['date'] as Timestamp).toDate(),
          'quantity': (d['quantity'] as num).toDouble(),
        };
      }).toList();

      /// Filter by selected date range in Dart
      if (selectedRange != null) {
        logs = logs.where((m) {
          final dt = m['date'] as DateTime;
          return !dt.isBefore(selectedRange!.start) &&
              !dt.isAfter(selectedRange!.end);
        }).toList();
      }

      if (!mounted) return;
      setState(() {
        milkLogs = logs;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading milk entries')),
      );
    }
  }

  /// 📅 PICK DATE RANGE (MAX 7 DAYS)
  Future<void> _pickRange() async {
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: selectedRange,
    );

    if (picked == null) return;

    final diff = picked.end.difference(picked.start).inDays;
    if (diff > 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a range within 7 days'),
        ),
      );
      return;
    }

    setState(() => selectedRange = picked);
    _loadMilk();
  }

  /// ➕ ADD MILK
  Future<void> _addMilk() async {
    final result = await showDialog(
      context: context,
      builder: (_) => AddMilkDialog(
        cattleId: widget.cattle.id,
        cattleName: widget.cattle.name,
      ),
    );

    if (result == true) {
      _loadMilk();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cattle;

    /// SAFELY EXTRACT VALUES (THIS FIXES YOUR ISSUE)
    final name = c.name.isNotEmpty ? c.name : '-';
    final tag = (c.tagId != null && c.tagId!.isNotEmpty) ? c.tagId! : '-';
    final breed =
    (c.breed != null && c.breed!.isNotEmpty) ? c.breed! : '-';
    final dob =
    c.dob != null ? DateFormat.yMMMd().format(c.dob!) : '-';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
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

            /// BASIC INFO (ALL FIELDS GUARANTEED)
            _infoRow('Name', name),
            _infoRow('Tag', tag),
            _infoRow('Breed', breed),
            _infoRow('DOB', dob),

            const SizedBox(height: 24),

            /// MILK HEADER + CALENDAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Milk Entries',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickRange,
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Select range'),
                ),
              ],
            ),

            if (selectedRange != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${DateFormat.yMMMd().format(selectedRange!.start)} - '
                      '${DateFormat.yMMMd().format(selectedRange!.end)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

            /// MILK LIST
            loading
                ? const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
                : milkLogs.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No milk entries')),
            )
                : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: milkLogs.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final log = milkLogs[i];
                return ListTile(
                  leading: const Icon(
                    Icons.water_drop,
                    color: Colors.blue,
                  ),
                  title: Text(
                    DateFormat.yMMMd().format(log['date']),
                  ),
                  trailing: Text(
                    '${log['quantity']} L',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// INFO ROW WIDGET
  Widget _infoRow(String label, String value) {
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
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
