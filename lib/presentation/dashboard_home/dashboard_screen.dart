import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/promotional_banner_widget.dart' as promo;
import './widgets/service_card_widget.dart' as service;
import './widgets/stats_card_widget.dart';

import 'package:cowtrack/widgets/chatbot/cow_chatbot.dart';
import 'package:cowtrack/presentation/dashboard_home/vet_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  bool _isLoading = false;

  // 🔥 ORIGINAL DASHBOARD DATA (RESTORED)
  final Map<String, dynamic> _farmData = {
    "farmer": {
      "name": "John Anderson",
      "farm_name": "Green Valley Dairy Farm",
      "total_cattle": 42,
      "notifications": 3,
    },
    "stats": {
      "total_cattle": 42,
      "upcoming_vaccinations": 5,
      "health_alerts": 2,
      "milk_production": "285L",
    },

    // ✅ UPDATED PROMOTIONAL BANNERS (REAL SCHEME LINKS)
    "promotional_banners": [
      {
        "id": 1,
        "title": "Rashtriya Gokul Mission",
        "subtitle":
        "Development & conservation of indigenous cattle breeds",
        "button_text": "Learn More",
        "image":
        "https://images.pexels.com/photos/422218/pexels-photo-422218.jpeg",
        "url":
        "https://dahd.nic.in/schemes/rashtriya-gokul-mission",
      },
      {
        "id": 2,
        "title": "National Livestock Mission",
        "subtitle":
        "Boost productivity & entrepreneurship in livestock sector",
        "button_text": "View Scheme",
        "image":
        "https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg",
        "url":
        "https://dahd.nic.in/schemes/national-livestock-mission",
      },
      {
        "id": 3,
        "title": "Livestock Insurance Scheme",
        "subtitle":
        "Insurance coverage for cattle & buffaloes",
        "button_text": "Check Details",
        "image":
        "https://images.pexels.com/photos/5731849/pexels-photo-5731849.jpeg",
        "url":
        "https://dahd.nic.in/schemes/livestock-insurance-scheme",
      },
    ],
  };

  // 🔥 ORIGINAL SERVICE CARDS (RESTORED)
  late final List<Map<String, dynamic>> _serviceCards = [
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
      "badge": "5",
    },
    {
      "title": "Vet Consultation",
      "icon": "local_hospital",
      "route": "/veterinarian-directory-screen",
    },

    // ✅ FIXED ROUTE
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

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await _loadDashboardData();
  }

  void _onServiceCardTap(String route) {
    HapticFeedback.lightImpact();

    if (route == '/veterinarian-directory-screen') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VetScreen()),
      );
    } else if (route != '/dashboard-screen') {
      Navigator.pushNamed(context, route);
    }
  }

  void _onNotificationTap() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${(_farmData["farmer"] as Map)["notifications"]} new notifications',
        ),
      ),
    );
  }

  void _onProfileTap() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/profile-management-screen');
  }

  // ✅ UPDATED: BANNER → WEBVIEW
  void _onPromotionalBannerTap(Map<String, dynamic> banner) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      AppRoutes.schemeWebView,
      arguments: {
        'title': banner['title'],
        'url': banner['url'],
      },
    );
  }

  void _onAddCattleTap() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/cattle-management-screen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final farmerData = _farmData["farmer"] as Map<String, dynamic>;
    final statsData = _farmData["stats"] as Map<String, dynamic>;
    final promotionalBanners =
    _farmData["promotional_banners"] as List<dynamic>;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            slivers: [
              // Greeting Header
              SliverToBoxAdapter(
                child: GreetingHeaderWidget(
                  farmerName: farmerData["name"],
                  farmName: farmerData["farm_name"],
                  notificationCount: farmerData["notifications"],
                  onNotificationTap: _onNotificationTap,
                  onProfileTap: _onProfileTap,
                ),
              ),

              // Farm Statistics (UNCHANGED)
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
                              value:
                              statsData["total_cattle"].toString(),
                              iconName: 'pets',
                              valueColor: theme.primaryColor,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: StatsCardWidget(
                              title: 'Milk Production',
                              value: statsData["milk_production"],
                              iconName: 'local_drink',
                              valueColor:
                              AppTheme.getSuccessColor(!isDark),
                              subtitle: 'Today',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 3.h)),

              // 🔥 Promotional Banners (UNCHANGED UI)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 15.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(left: 4.w),
                    itemCount: promotionalBanners.length,
                    itemBuilder: (context, index) {
                      final banner =
                      promotionalBanners[index] as Map<String, dynamic>;
                      return promo.PromotionalBannerWidget(
                        title: banner["title"],
                        subtitle: banner["subtitle"],
                        buttonText: banner["button_text"],
                        imageUrl: banner["image"],
                        onTap: () => _onPromotionalBannerTap(banner),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 3.h)),

              // Service Cards Grid (UNCHANGED)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                sliver: SliverGrid(
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 3.w,
                    mainAxisSpacing: 3.w,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final item = _serviceCards[index];
                      return service.ServiceCardWidget(
                        title: item["title"],
                        iconName: item["icon"],
                        showBadge: item["badge"] != null,
                        badgeText: item["badge"],
                        onTap: () =>
                            _onServiceCardTap(item["route"]),
                      );
                    },
                    childCount: _serviceCards.length,
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 10.h)),
            ],
          ),
        ),
      ),

      // FABs (UNCHANGED)
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

      bottomNavigationBar:
      const CustomBottomBar(currentIndex: 0),
    );
  }
}
