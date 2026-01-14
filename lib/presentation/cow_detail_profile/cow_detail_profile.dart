import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../models/cattle.dart';
import '../cattle/widgets/metric_charts.dart';
import 'widgets/cow_photo_gallery_widget.dart';
import 'widgets/cow_stats_card_widget.dart';
import 'widgets/floating_action_menu_widget.dart';
import 'widgets/health_records_tab_widget.dart';
import 'widgets/profile_tab_widget.dart';
import 'widgets/add_milk_dialog.dart';

class CowDetailProfile extends StatefulWidget {
  final Cattle cattle;

  const CowDetailProfile({super.key, required this.cattle});

  @override
  State<CowDetailProfile> createState() => _CowDetailProfileState();
}

class _CowDetailProfileState extends State<CowDetailProfile> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 1;

  double todayMilk = 0;
  double monthlyMilk = 0;
  bool _loadingMilk = false;
  List<Map<String, dynamic>> recentLogs = [];
  bool isBarChart = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMilkStats();
  }

  Future<void> _loadMilkStats() async {
    setState(() => _loadingMilk = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfDay = DateTime(now.year, now.month, now.day);

    final snapshot = await FirebaseFirestore.instance
        .collection('milk_logs')
        .where('ownerId', isEqualTo: user.uid)
        .where('cowId', isEqualTo: widget.cattle.id)
        .orderBy('date', descending: true)
        .get();

    double today = 0;
    double month = 0;
    List<Map<String, dynamic>> logs = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final qty = (data['quantity'] as num).toDouble();

      logs.add({'date': date, 'quantity': qty});

      if (date.isAfter(startOfDay)) {
        today += qty;
      }
      if (date.isAfter(startOfMonth)) {
        month += qty;
      }
    }

    if (mounted) {
      setState(() {
        todayMilk = today;
        monthlyMilk = month;
        recentLogs = logs;
        _loadingMilk = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadMilkStats();
  }

  void _handleLogMilkProduction() async {
    final result = await showDialog(
      context: context,
      builder: (_) => AddMilkDialog(cattleId: widget.cattle.id),
    );
    if (result == true) {
      _loadMilkStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cattle = widget.cattle;

    return Scaffold(
      appBar: CustomAppBar(title: cattle.name),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            CowPhotoGalleryWidget(
              photos: cattle.photoUrl != null ? [cattle.photoUrl!] : [],
              cowName: cattle.name,
            ),
            CowStatsCardWidget(
              cowData: {
                "breed": cattle.breed,
                "age": cattle.dob != null ? DateTime.now().year - cattle.dob!.year : '-',
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
                  /// PROFILE TAB
                  ProfileTabWidget(
                    cowData: {
                      "name": cattle.name,
                      "tagId": cattle.tagId,
                      "breed": cattle.breed,
                    },
                  ),

                  /// HEALTH TAB
                  const HealthRecordsTabWidget(healthRecords: []),

                  /// MILK STATS TAB
                  _loadingMilk
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Today: ${todayMilk.toStringAsFixed(1)} L',
                            style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: 8),
                        Text('This Month: ${monthlyMilk.toStringAsFixed(1)} L',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 20),

                        /// Toggle for Chart View
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Last 7 Days Milk Production',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            ToggleButtons(
                              isSelected: [isBarChart, !isBarChart],
                              onPressed: (index) {
                                setState(() => isBarChart = index == 0);
                              },
                              borderRadius: BorderRadius.circular(8),
                              constraints: BoxConstraints(minWidth: 50, minHeight: 36),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text("Bar"),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text("Line"),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 220,
                          child: MetricCharts(
                            isMonthly: false,
                            isBarChart: isBarChart,
                            cattleId: cattle.id,
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// Recent Entries List
                        const Text('Recent Entries',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentLogs.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final log = recentLogs[index];
                            return ListTile(
                              leading: const Icon(Icons.date_range),
                              title: Text(DateFormat.yMMMd().format(log['date'])),
                              trailing: Text('${log['quantity']} L'),
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
      floatingActionButton: FloatingActionMenuWidget(
        activeTabIndex: _tabController.index,
        onEditProfile: () {},
        onAddHealthRecord: () {},
        onLogMilkProduction: _handleLogMilkProduction,
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (i) => setState(() => _currentBottomNavIndex = i),
      ),
    );
  }
}
