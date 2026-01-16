import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/promotional_banner_widget.dart' as promo;
import './widgets/service_card_widget.dart' as service;
import './widgets/stats_card_widget.dart';

import 'package:cowtrack/widgets/chatbot/cow_chatbot.dart';
import 'package:cowtrack/presentation/dashboard_home/vet_screen.dart';
import 'package:cowtrack/presentation/farm_analytics/screens/farm_analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  late final String _ownerId;

  int _totalCattle = 0;
  double _todayMilk = 0.0;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _serviceCards = [
    {
      "title": "Disease Detection",
      "icon": "camera_alt",
      "route": "/ai-chatbot-screen",
      "badge": "NEW",
    },
    {
      "title": "My Cattle",
      "icon": "pets",
      "route": "/cattle-management-screen",
    },
    {
      "title": "Health Records",
      "icon": "medical_services",
      "route": "/cattle-management-screen",
    },
    {
      "title": "Vaccination Schedule",
      "icon": "event",
      "route": "/cattle-management-screen",
    },
    {
      "title": "Vet Consultation",
      "icon": "local_hospital",
      "route": "/veterinarian-directory-screen",
    },
    {
      "title": "Government Schemes",
      "icon": "description",
      "route": AppRoutes.governmentSchemesScreen,
    },
    {
      "title": "AI Assistant",
      "icon": "smart_toy",
      "route": "/ai-chatbot-screen",
    },
    {
      "title": "Farm Analytics",
      "icon": "analytics",
      "route": "/dashboard-screen",
    },
  ];

  final List<Map<String, dynamic>> _promotionalBanners = [
    {
      "title": "Rashtriya Gokul Mission",
      "subtitle": "Development & conservation of indigenous cattle breeds",
      "button_text": "Learn More",
      "image":
      "https://images.pexels.com/photos/422218/pexels-photo-422218.jpeg",
      "url": "https://dahd.nic.in/schemes/rashtriya-gokul-mission",
    },
    {
      "title": "National Livestock Mission",
      "subtitle": "Boost productivity & entrepreneurship in livestock sector",
      "button_text": "View Scheme",
      "image":
      "https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg",
      "url": "https://dahd.nic.in/schemes/national-livestock-mission",
    },
  ];

  @override
  void initState() {
    super.initState();
    _ownerId = FirebaseAuth.instance.currentUser!.uid;
    _ensureUserDocument();
    _listenDashboardData();
  }

  Future<void> _ensureUserDocument() async {
    final ref =
    FirebaseFirestore.instance.collection('users').doc(_ownerId);
    if (!(await ref.get()).exists) {
      await ref.set({'createdAt': FieldValue.serverTimestamp()});
    }
  }

  /// 🔥 REALTIME DASHBOARD LOGIC (CORRECT & STABLE)
  void _listenDashboardData() {
    final firestore = FirebaseFirestore.instance;

    /// ✅ TOTAL CATTLE (realtime)
    firestore
        .collection('cattle')
        .where('ownerId', isEqualTo: _ownerId)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      setState(() {
        _totalCattle = snap.docs.length;
      });
    });

    /// ✅ TODAY MILK (realtime, date filtered in Dart)
    firestore
        .collection('milk_logs')
        .where('ownerId', isEqualTo: _ownerId)
        .snapshots()
        .listen((snap) {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      double sum = 0.0;

      for (var doc in snap.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final qty = (data['quantity'] as num).toDouble();

        if (!date.isBefore(startOfDay) && date.isBefore(endOfDay)) {
          sum += qty;
        }
      }

      if (!mounted) return;
      setState(() {
        _todayMilk = sum;
        _isLoading = false;
      });
    });
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    // realtime listeners already keep data fresh
  }

  void _onServiceCardTap(String route) {
    HapticFeedback.lightImpact();

    if (route == '/veterinarian-directory-screen') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VetScreen()),
      );
    } else if (route == '/dashboard-screen') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FarmAnalyticsScreen()),
      );
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  void _onAddCattleTap() {
    Navigator.pushNamed(context, '/cattle-management-screen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _onRefresh,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  /// HEADER
                  SliverToBoxAdapter(
                    child: GreetingHeaderWidget(
                      farmerName: "Farmer",
                      farmName: "My Farm",
                      notificationCount: 0,
                      onNotificationTap: () {},
                      onProfileTap: () {
                        Navigator.pushNamed(context, AppRoutes.profile);
                      },
                    ),
                  ),

                  /// FARM OVERVIEW
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Farm Overview',
                              style: theme.textTheme.titleLarge),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Expanded(
                                child: StatsCardWidget(
                                  title: 'Total Cattle',
                                  value: _totalCattle.toString(),
                                  iconName: 'pets',
                                  valueColor: theme.primaryColor,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: StatsCardWidget(
                                  title: 'Milk Production',
                                  value:
                                  '${_todayMilk.toStringAsFixed(1)} L',
                                  subtitle: 'Today',
                                  iconName: 'local_drink',
                                  valueColor:
                                  AppTheme.getSuccessColor(!isDark),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// PROMOTIONAL BANNERS
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 15.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(left: 4.w),
                        itemCount: _promotionalBanners.length,
                        itemBuilder: (context, index) {
                          final banner = _promotionalBanners[index];
                          return promo.PromotionalBannerWidget(
                            title: banner['title'],
                            subtitle: banner['subtitle'],
                            buttonText: banner['button_text'],
                            imageUrl: banner['image'],
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.schemeWebView,
                                arguments: {
                                  'title': banner['title'],
                                  'url': banner['url'],
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  /// SERVICE GRID (ALL BUTTONS PRESENT)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    sliver: SliverGrid(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final item = _serviceCards[index];
                          return service.ServiceCardWidget(
                            title: item['title'],
                            iconName: item['icon'],
                            showBadge: item['badge'] != null,
                            badgeText: item['badge'],
                            onTap: () =>
                                _onServiceCardTap(item['route']),
                          );
                        },
                        childCount: _serviceCards.length,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                ],
              ),

              if (_isLoading)
                const Positioned.fill(
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CowChatbot(),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: _onAddCattleTap,
            icon: const Icon(Icons.add),
            label: const Text('Add Cattle'),
          ),
        ],
      ),

      bottomNavigationBar: const CustomBottomBar(currentIndex: 0),
    );
  }
}
