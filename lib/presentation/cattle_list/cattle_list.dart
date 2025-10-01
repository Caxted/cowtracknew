import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/cattle_card_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/search_header_widget.dart';

class CattleList extends StatefulWidget {
  const CattleList({super.key});

  @override
  State<CattleList> createState() => _CattleListState();
}

class _CattleListState extends State<CattleList> with TickerProviderStateMixin {
  String _searchQuery = '';
  bool _isSearchActive = false;
  Map<String, dynamic> _activeFilters = {
    'breed': 'All Breeds',
    'ageRange': 'All Ages',
    'healthStatus': 'All Status',
    'milkLevel': 'All Levels',
  };
  bool _isLoading = false;
  bool _isRefreshing = false;

  // Mock cattle data
  final List<Map<String, dynamic>> _allCattleData = [
    {
      "id": 1,
      "name": "Bella",
      "age": 4,
      "breed": "Holstein",
      "healthStatus": "Healthy",
      "photo":
          "https://images.pexels.com/photos/422218/pexels-photo-422218.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "lastMilkAmount": 22.5,
      "lastMilkDate": "Dec 11",
      "milkLevel": "High (>20L/day)",
      "weight": 650,
      "registrationDate": "2020-03-15"
    },
    {
      "id": 2,
      "name": "Daisy",
      "age": 3,
      "breed": "Jersey",
      "healthStatus": "Pregnant",
      "photo":
          "https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "lastMilkAmount": 18.0,
      "lastMilkDate": "Dec 10",
      "milkLevel": "Medium (10-20L/day)",
      "weight": 480,
      "registrationDate": "2021-05-20"
    },
    {
      "id": 3,
      "name": "Luna",
      "age": 2,
      "breed": "Angus",
      "healthStatus": "Healthy",
      "photo":
          "https://images.pexels.com/photos/1459832/pexels-photo-1459832.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "lastMilkAmount": 15.5,
      "lastMilkDate": "Dec 11",
      "milkLevel": "Medium (10-20L/day)",
      "weight": 520,
      "registrationDate": "2022-08-10"
    },
    {
      "id": 4,
      "name": "Rosie",
      "age": 5,
      "breed": "Holstein",
      "healthStatus": "Treatment",
      "photo":
          "https://images.pexels.com/photos/1300355/pexels-photo-1300355.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "lastMilkAmount": 8.0,
      "lastMilkDate": "Dec 9",
      "milkLevel": "Low (<10L/day)",
      "weight": 680,
      "registrationDate": "2019-01-25"
    },
    {
      "id": 5,
      "name": "Moo",
      "age": 1,
      "breed": "Jersey",
      "healthStatus": "Healthy",
      "photo":
          "https://images.pexels.com/photos/1595104/pexels-photo-1595104.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "lastMilkAmount": 0.0,
      "lastMilkDate": "N/A",
      "milkLevel": "Not Producing",
      "weight": 320,
      "registrationDate": "2023-11-05"
    },
    {
      "id": 6,
      "name": "Buttercup",
      "age": 6,
      "breed": "Hereford",
      "healthStatus": "Sick",
      "photo":
          "https://images.pexels.com/photos/1300355/pexels-photo-1300355.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "lastMilkAmount": 12.0,
      "lastMilkDate": "Dec 8",
      "milkLevel": "Medium (10-20L/day)",
      "weight": 720,
      "registrationDate": "2018-07-12"
    },
  ];

  List<Map<String, dynamic>> _filteredCattleData = [];

  @override
  void initState() {
    super.initState();
    _filteredCattleData = List.from(_allCattleData);
    _loadCattleData();
  }

  Future<void> _loadCattleData() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isLoading = false;
      _applyFilters();
    });
  }

  Future<void> _refreshCattleData() async {
    setState(() => _isRefreshing = true);

    // Simulate refresh with haptic feedback
    HapticFeedback.lightImpact();

    await Future.delayed(const Duration(milliseconds: 1200));

    setState(() {
      _isRefreshing = false;
      _applyFilters();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cattle data refreshed successfully'),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allCattleData);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((cattle) {
        final name = (cattle['name'] as String).toLowerCase();
        final breed = (cattle['breed'] as String).toLowerCase();
        final id = cattle['id'].toString();
        final query = _searchQuery.toLowerCase();

        return name.contains(query) ||
            breed.contains(query) ||
            id.contains(query);
      }).toList();
    }

    // Apply breed filter
    if (_activeFilters['breed'] != 'All Breeds') {
      filtered = filtered
          .where((cattle) => cattle['breed'] == _activeFilters['breed'])
          .toList();
    }

    // Apply age range filter
    if (_activeFilters['ageRange'] != 'All Ages') {
      filtered = filtered.where((cattle) {
        final age = cattle['age'] as int;
        switch (_activeFilters['ageRange']) {
          case '0-1 years':
            return age <= 1;
          case '1-3 years':
            return age > 1 && age <= 3;
          case '3-5 years':
            return age > 3 && age <= 5;
          case '5+ years':
            return age > 5;
          default:
            return true;
        }
      }).toList();
    }

    // Apply health status filter
    if (_activeFilters['healthStatus'] != 'All Status') {
      filtered = filtered
          .where((cattle) =>
              cattle['healthStatus'] == _activeFilters['healthStatus'])
          .toList();
    }

    // Apply milk level filter
    if (_activeFilters['milkLevel'] != 'All Levels') {
      filtered = filtered
          .where((cattle) => cattle['milkLevel'] == _activeFilters['milkLevel'])
          .toList();
    }

    setState(() {
      _filteredCattleData = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearchActive = query.isNotEmpty;
    });
    _applyFilters();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: FilterBottomSheetWidget(
          currentFilters: _activeFilters,
          onFiltersChanged: (filters) {
            setState(() => _activeFilters = filters);
            _applyFilters();
          },
        ),
      ),
    );
  }

  void _navigateToCowProfile(Map<String, dynamic> cattle) {
    Navigator.pushNamed(
      context,
      '/cow-detail-profile',
      arguments: cattle,
    );
  }

  void _navigateToAddCow() {
    // Navigate to add cow screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add new cow feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editCattle(Map<String, dynamic> cattle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${cattle['name']} feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewHealthRecords(Map<String, dynamic> cattle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Health records for ${cattle['name']} coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewMilkLog(Map<String, dynamic> cattle) {
    Navigator.pushNamed(
      context,
      '/milk-production-logging',
      arguments: cattle,
    );
  }

  void _deleteCattle(Map<String, dynamic> cattle) {
    setState(() {
      _allCattleData.removeWhere((item) => item['id'] == cattle['id']);
    });
    _applyFilters();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${cattle['name']} deleted successfully'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _allCattleData.add(cattle);
            });
            _applyFilters();
          },
        ),
      ),
    );
  }

  void _setReminder(Map<String, dynamic> cattle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Set reminder for ${cattle['name']} coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareDetails(Map<String, dynamic> cattle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share ${cattle['name']} details coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Cattle',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _navigateToAddCow,
            icon: CustomIconWidget(
              iconName: 'add',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onPrimary,
            ),
            tooltip: 'Add New Cow',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Header
          SearchHeaderWidget(
            searchQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
            onFilterTap: _showFilterBottomSheet,
            isSearchActive: _isSearchActive,
          ),

          // Main Content
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredCattleData.isEmpty
                    ? _buildEmptyState()
                    : _buildCattleList(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: CustomBottomBar.getCurrentIndex('/cattle-list'),
        onTap: (index) {
          // Navigation handled by CustomBottomBar
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCow,
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onSecondary,
        child: CustomIconWidget(
          iconName: 'add',
          size: 28,
          color: AppTheme.lightTheme.colorScheme.onSecondary,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading cattle data...',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty || _hasActiveFilters()) {
      return EmptyStateWidget(
        title: 'No Cattle Found',
        subtitle:
            'No cattle match your current search or filter criteria. Try adjusting your search terms or clearing filters.',
        buttonText: 'Clear Search',
        isSearchResult: true,
      );
    }

    return EmptyStateWidget(
      title: 'No Cattle Yet',
      subtitle:
          'Start building your herd by adding your first cow. Track their health, milk production, and more.',
      buttonText: 'Add Your First Cow',
      onButtonPressed: _navigateToAddCow,
    );
  }

  Widget _buildCattleList() {
    return RefreshIndicator(
      onRefresh: _refreshCattleData,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filteredCattleData.length,
        itemBuilder: (context, index) {
          final cattle = _filteredCattleData[index];
          return CattleCardWidget(
            cattle: cattle,
            onTap: () => _navigateToCowProfile(cattle),
            onEdit: () => _editCattle(cattle),
            onHealthRecords: () => _viewHealthRecords(cattle),
            onMilkLog: () => _viewMilkLog(cattle),
            onDelete: () => _deleteCattle(cattle),
            onSetReminder: () => _setReminder(cattle),
            onViewProfile: () => _navigateToCowProfile(cattle),
            onShareDetails: () => _shareDetails(cattle),
          );
        },
      ),
    );
  }

  bool _hasActiveFilters() {
    return _activeFilters['breed'] != 'All Breeds' ||
        _activeFilters['ageRange'] != 'All Ages' ||
        _activeFilters['healthStatus'] != 'All Status' ||
        _activeFilters['milkLevel'] != 'All Levels';
  }
}
