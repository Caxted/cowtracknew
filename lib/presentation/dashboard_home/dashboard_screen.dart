import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/promotional_banner_widget.dart' as promo;
import './widgets/service_card_widget.dart' as service;

import './widgets/stats_card_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  bool _isLoading = false;

  // Mock data for dashboard
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
    "recent_alerts": [
      {
        "id": 1,
        "type": "vaccination",
        "message": "5 cattle due for vaccination this week",
        "urgent": true,
      },
      {
        "id": 2,
        "type": "health",
        "message": "2 cattle showing mild symptoms",
        "urgent": true,
      },
    ],
    "promotional_banners": [
      {
        "id": 1,
        "title": "New Government Scheme",
        "subtitle":
        "Apply for dairy development subsidy - up to \$5,000 available",
        "button_text": "Learn More",
        "image":
        "https://images.pexels.com/photos/422218/pexels-photo-422218.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      },
      {
        "id": 2,
        "title": "Health Check Campaign",
        "subtitle": "Free veterinary consultation for all registered farmers",
        "button_text": "Book Now",
        "image":
        "https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      },
      {
        "id": 3,
        "title": "AI Disease Detection",
        "subtitle": "Early detection saves lives - try our new AI feature",
        "button_text": "Try Now",
        "image":
        "https://images.pexels.com/photos/5731849/pexels-photo-5731849.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      },
    ],
  };

  late final List<Map<String, dynamic>> _serviceCards = [
    {
      "title": "Disease Detection",
      "icon": "camera_alt",
      "route": "/ai-chatbot-screen",
      "badge": "NEW",
      "badge_color": null,
    },
    {
      "title": "My Cattle",
      "icon": "pets",
      "route": "/cattle-management-screen",
      "badge": null,
      "badge_color": null,
    },
    {
      "title": "Health Records",
      "icon": "medical_services",
      "route": "/cattle-management-screen",
      "badge": null,
      "badge_color": null,
    },
    {
      "title": "Vaccination Schedule",
      "icon": "event",
      "route": "/cattle-management-screen",
      "badge": "5",
      "badge_color": null,
    },
    {
      "title": "Vet Consultation",
      "icon": "local_hospital",
      "route": "/veterinarian-directory-screen",
      "badge": null,
      "badge_color": null,
    },
    {
      "title": "Government Schemes",
      "icon": "description",
      "route": "/dashboard-screen",
      "badge": null,
      "badge_color": null,
    },
    {
      "title": "AI Assistant",
      "icon": "smart_toy",
      "route": "/ai-chatbot-screen",
      "badge": null,
      "badge_color": null,
    },
    {
      "title": "Farm Analytics",
      "icon": "analytics",
      "route": "/dashboard-screen",
      "badge": null,
      "badge_color": null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await _loadDashboardData();
  }

  void _onServiceCardTap(String route) {
    HapticFeedback.lightImpact();
    if (route != '/dashboard-screen') {
      Navigator.pushNamed(context, route);
    }
  }

  void _onNotificationTap() {
    HapticFeedback.lightImpact();
    // Handle notification tap
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${(_farmData["farmer"] as Map<String, dynamic>)["notifications"]} new notifications'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onProfileTap() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/profile-management-screen');
  }

  void _onPromotionalBannerTap(Map<String, dynamic> banner) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${banner["title"] as String}'),
        duration: const Duration(seconds: 2),
      ),
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
          color: theme.primaryColor,
          child: CustomScrollView(
            slivers: [
              // Greeting Header
              SliverToBoxAdapter(
                child: GreetingHeaderWidget(
                  farmerName: farmerData["name"] as String,
                  farmName: farmerData["farm_name"] as String,
                  notificationCount: farmerData["notifications"] as int,
                  onNotificationTap: _onNotificationTap,
                  onProfileTap: _onProfileTap,
                ),
              ),

              // Farm Statistics
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Farm Overview',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Expanded(
                            child: StatsCardWidget(
                              title: 'Total Cattle',
                              value:
                              (statsData["total_cattle"] as int).toString(),
                              iconName: 'pets',
                              valueColor: theme.primaryColor,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: StatsCardWidget(
                              title: 'Milk Production',
                              value: statsData["milk_production"] as String,
                              iconName: 'local_drink',
                              valueColor: AppTheme.getSuccessColor(!isDark),
                              subtitle: 'Today',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.w),
                      Row(
                        children: [
                          Expanded(
                            child: StatsCardWidget(
                              title: 'Upcoming Vaccinations',
                              value: (statsData["upcoming_vaccinations"] as int)
                                  .toString(),
                              iconName: 'event',
                              valueColor: AppTheme.getWarningColor(!isDark),
                              isUrgent:
                              (statsData["upcoming_vaccinations"] as int) >
                                  0,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: StatsCardWidget(
                              title: 'Health Alerts',
                              value: (statsData["health_alerts"] as int)
                                  .toString(),
                              iconName: 'warning',
                              valueColor: AppTheme.getAccentColor(!isDark),
                              isUrgent: (statsData["health_alerts"] as int) > 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 3.h)),

              // Promotional Banners
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'Latest Updates',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    SizedBox(
                      height: 15.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(left: 4.w),
                        itemCount: promotionalBanners.length,
                        itemBuilder: (context, index) {
                          final banner =
                          promotionalBanners[index] as Map<String, dynamic>;
                          return promo.PromotionalBannerWidget(
                            title: banner["title"] as String,
                            subtitle: banner["subtitle"] as String,
                            buttonText: banner["button_text"] as String?,
                            imageUrl: banner["image"] as String?,
                            onTap: () => _onPromotionalBannerTap(banner),
                          );

                        },
                      ),
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 3.h)),

              // Service Cards Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    'Farm Services',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 2.h)),

              // Service Cards Grid
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 3.w,
                    mainAxisSpacing: 3.w,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final serviceItem = _serviceCards[index];
                      return service.ServiceCardWidget(
                        title: serviceItem["title"] as String,
                        iconName: serviceItem["icon"] as String,
                        onTap: () => _onServiceCardTap(serviceItem["route"] as String),
                        showBadge: serviceItem["badge"] != null,
                        badgeText: serviceItem["badge"] as String?,
                        badgeColor: serviceItem["badge_color"] as Color?,
                      );
                    },
                    childCount: _serviceCards.length,
                  ),

                ),
              ),

              // Emergency Contact Card
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.all(4.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color:
                    AppTheme.getAccentColor(!isDark).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.getAccentColor(!isDark),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: AppTheme.getAccentColor(!isDark),
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: 'emergency',
                          color: Colors.white,
                          size: 6.w,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency Vet Contact',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '24/7 emergency veterinary services',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomIconWidget(
                        iconName: 'phone',
                        color: AppTheme.getAccentColor(!isDark),
                        size: 5.w,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom padding for navigation bar
              SliverToBoxAdapter(child: SizedBox(height: 10.h)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddCattleTap,
        icon: CustomIconWidget(
          iconName: 'add',
          color:
          theme.floatingActionButtonTheme.foregroundColor ?? Colors.white,
          size: 5.w,
        ),
        label: Text(
          'Add Cattle',
          style: theme.textTheme.labelLarge?.copyWith(
            color:
            theme.floatingActionButtonTheme.foregroundColor ?? Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.floatingActionButtonTheme.backgroundColor,
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0,
      ),

    );
  }
}
