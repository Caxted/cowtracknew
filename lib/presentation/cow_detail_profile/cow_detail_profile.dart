import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../models/cattle.dart';
import '../cattle/widgets/metric_charts.dart';
import 'widgets/cow_photo_gallery_widget.dart';
import 'widgets/cow_stats_card_widget.dart';
import 'widgets/health_records_tab_widget.dart';
import 'widgets/profile_tab_widget.dart';
import 'widgets/add_milk_dialog.dart';

class CowDetailProfile extends StatefulWidget {
  final Cattle cattle;

  const CowDetailProfile({super.key, required this.cattle});

  @override
  State<CowDetailProfile> createState() => _CowDetailProfileState();
}

class _CowDetailProfileState extends State<CowDetailProfile>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 1;

  double todayMilk = 0;
  double monthlyMilk = 0;
  bool _loadingMilk = false;
  bool isBarChart = true;

  List<Map<String, dynamic>> milkLogs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMilkStats();
  }

  Future<void> _loadMilkStats() async {
    setState(() => _loadingMilk = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('milk_logs')
        .where('cowId', isEqualTo: widget.cattle.id)
        .orderBy('date', descending: true)
        .get();

    double today = 0;
    double month = 0;
    List<Map<String, dynamic>> logs = [];

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final qty = (data['quantity'] as num).toDouble();

      logs.add({
        'date': date,
        'quantity': qty,
      });

      if (date.isAfter(startOfDay)) today += qty;
      if (date.isAfter(startOfMonth)) month += qty;
    }

    if (!mounted) return;
    setState(() {
      todayMilk = today;
      monthlyMilk = month;
      milkLogs = logs;
      _loadingMilk = false;
    });
  }

  /// 🔥 GUARANTEED ADD MILK HANDLER
  Future<void> _addMilk() async {
    print('ADD MILK BUTTON PRESSED');

    final result = await showDialog(
      context: context,
      builder: (_) => AddMilkDialog(
        cattleId: widget.cattle.id,
        cattleName: widget.cattle.name,
      ),
    );

    if (result == true) {
      await _loadMilkStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cattle = widget.cattle;

    return Scaffold(
      appBar: CustomAppBar(title: cattle.name),
      body: RefreshIndicator(
        onRefresh: _loadMilkStats,
        child: Column(
          children: [
            CowPhotoGalleryWidget(
              photos: cattle.photoUrl != null ? [cattle.photoUrl!] : [],
              cowName: cattle.name,
            ),
            CowStatsCardWidget(
              cowData: {
                "breed": cattle.breed,
                "age": cattle.dob != null
                    ? DateTime.now().year - cattle.dob!.year
                    : '-',
                "weight": "-",
              },
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Profile'),
                  Tab(text: 'Health'),
                  Tab(text: 'Milk Stats'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ProfileTabWidget(
                    cowData: {
                      "name": cattle.name,
                      "tagId": cattle.tagId,
                      "breed": cattle.breed,
                    },
                  ),
                  const HealthRecordsTabWidget(healthRecords: []),

                  /// MILK TAB
                  _loadingMilk
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today: ${todayMilk.toStringAsFixed(1)} L',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This Month: ${monthlyMilk.toStringAsFixed(1)} L',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium,
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          height: 220,
                          child: MetricCharts(
                            isMonthly: false,
                            isBarChart: isBarChart,
                            cattleId: cattle.id,
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Recent Entries',
                          style:
                          TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        milkLogs.isEmpty
                            ? const Text('No data found')
                            : ListView.separated(
                          shrinkWrap: true,
                          physics:
                          const NeverScrollableScrollPhysics(),
                          itemCount: milkLogs.length,
                          separatorBuilder: (_, __) =>
                          const Divider(),
                          itemBuilder: (context, index) {
                            final log = milkLogs[index];
                            return ListTile(
                              leading: const Icon(
                                  Icons.water_drop),
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
                ],
              ),
            ),
          ],
        ),
      ),

      /// 🔥 SIMPLE, GUARANTEED FAB
      floatingActionButton: FloatingActionButton(
        onPressed: _addMilk,
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (i) => setState(() => _currentBottomNavIndex = i),
      ),
    );
  }
}
