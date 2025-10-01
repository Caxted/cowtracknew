import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/cow_photo_gallery_widget.dart';
import './widgets/cow_stats_card_widget.dart';
import './widgets/floating_action_menu_widget.dart';
import './widgets/health_records_tab_widget.dart';
import './widgets/milk_statistics_tab_widget.dart';
import './widgets/profile_tab_widget.dart';

class CowDetailProfile extends StatefulWidget {
  const CowDetailProfile({super.key});

  @override
  State<CowDetailProfile> createState() => _CowDetailProfileState();
}

class _CowDetailProfileState extends State<CowDetailProfile>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 1; // Cattle tab
  bool _isRefreshing = false;

  // Mock cow data
  final Map<String, dynamic> _cowData = {
    "id": "COW001",
    "tagId": "TAG-2024-001",
    "name": "Bella",
    "breed": "Holstein Friesian",
    "gender": "Female",
    "age": 4,
    "dateOfBirth": "March 15, 2020",
    "weight": 650,
    "height": 145,
    "color": "Black and White",
    "markings": "White blaze on forehead",
    "healthStatus": "Healthy",
    "farmId": "FARM-001",
    "location": "Barn A, Section 2",
    "barnSection": "A-2",
    "purchaseDate": "April 20, 2020",
    "purchasePrice": "1,500",
    "breedingStatus": "Lactating",
    "lastBreeding": "January 10, 2024",
    "expectedCalving": "October 15, 2024",
    "totalCalves": 3,
    "sire": "Champion Bull #45",
    "dam": "Daisy #23",
    "lactationNumber": 2,
    "daysInMilk": 120,
    "avgDailyMilk": 28,
    "peakMilkProduction": 35,
    "totalLifetimeMilk": 15420,
  };

  final List<String> _cowPhotos = [
    "https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    "https://images.unsplash.com/photo-1516467508483-a7212febe31a?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    "https://images.unsplash.com/photo-1572449043416-55f4685c9bb7?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
  ];

  final List<Map<String, dynamic>> _healthRecords = [
    {
      "id": "HR001",
      "type": "vaccination",
      "title": "Annual Vaccination",
      "description":
          "Administered FMD, BVD, and IBR vaccines. Cow showed no adverse reactions.",
      "date": "December 8, 2024",
      "veterinarian": "Sarah Johnson",
      "cost": "85",
      "nextAppointment": "December 8, 2025",
    },
    {
      "id": "HR002",
      "type": "checkup",
      "title": "Routine Health Checkup",
      "description":
          "General health assessment. All vitals normal. Body condition score: 3.5/5.",
      "date": "November 15, 2024",
      "veterinarian": "Michael Chen",
      "cost": "60",
    },
    {
      "id": "HR003",
      "type": "treatment",
      "title": "Mastitis Treatment",
      "description":
          "Treated mild mastitis in left rear quarter. Prescribed antibiotics for 5 days.",
      "date": "October 22, 2024",
      "veterinarian": "Sarah Johnson",
      "cost": "120",
      "nextAppointment": "November 5, 2024",
    },
    {
      "id": "HR004",
      "type": "breeding",
      "title": "Artificial Insemination",
      "description":
          "AI performed with premium Holstein semen. Heat detection confirmed.",
      "date": "September 10, 2024",
      "veterinarian": "David Rodriguez",
      "cost": "45",
    },
    {
      "id": "HR005",
      "type": "medication",
      "title": "Deworming Treatment",
      "description":
          "Administered broad-spectrum dewormer. Weight: 645kg before treatment.",
      "date": "August 5, 2024",
      "veterinarian": "Michael Chen",
      "cost": "25",
    },
  ];

  final Map<String, dynamic> _milkData = {
    "todayProduction": 28,
    "weeklyProduction": 196,
    "monthlyProduction": 840,
    "averageDaily": 28,
    "peakProduction": 35,
    "averageQuality": 4.2,
    "consistency": 85,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cow data updated successfully')),
      );
    }
  }

  void _handleShare() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Cow Profile',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Share Summary'),
              subtitle: const Text('Share basic cow information'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cow summary shared')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'picture_as_pdf',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Export PDF Report'),
              subtitle: const Text('Generate detailed PDF report'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF report generated')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'More Options',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                _handleEditProfile();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Duplicate Profile'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile duplicated')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'archive',
                color: Colors.orange,
                size: 24,
              ),
              title: const Text('Archive Cow'),
              onTap: () {
                Navigator.pop(context);
                _showArchiveDialog();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete_outline',
                color: Colors.red,
                size: 24,
              ),
              title: const Text('Delete Profile'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleEditProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile feature coming soon')),
    );
  }

  void _handleAddHealthRecord() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add health record feature coming soon')),
    );
  }

  void _handleLogMilkProduction() {
    Navigator.pushNamed(context, '/milk-production-logging');
  }

  void _showArchiveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Cow'),
        content: Text(
            'Are you sure you want to archive ${_cowData["name"]}? This will move the cow to archived records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('${_cowData["name"]} archived successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text(
            'Are you sure you want to permanently delete ${_cowData["name"]}\'s profile? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to cattle list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${_cowData["name"]} profile deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _cowData["name"] ?? "Cow Profile",
        actions: [
          IconButton(
            onPressed: _handleShare,
            icon: CustomIconWidget(
              iconName: 'share',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
            tooltip: 'Share Profile',
          ),
          IconButton(
            onPressed: _handleMoreOptions,
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
            tooltip: 'More Options',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            // Cow photo gallery
            CowPhotoGalleryWidget(
              photos: _cowPhotos,
              cowName: _cowData["name"] ?? "Unknown",
            ),

            // Cow stats card
            CowStatsCardWidget(cowData: _cowData),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.dividerColor,
                  width: 1,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.lightTheme.colorScheme.primary,
                unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                indicatorColor: AppTheme.lightTheme.colorScheme.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Profile'),
                  Tab(text: 'Health'),
                  Tab(text: 'Milk Stats'),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ProfileTabWidget(cowData: _cowData),
                  HealthRecordsTabWidget(healthRecords: _healthRecords),
                  MilkStatisticsTabWidget(milkData: _milkData),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionMenuWidget(
        activeTabIndex: _tabController.index,
        onEditProfile: _handleEditProfile,
        onAddHealthRecord: _handleAddHealthRecord,
        onLogMilkProduction: _handleLogMilkProduction,
      ),
    );
  }
}
