import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/batch_entry_widget.dart';
import './widgets/cattle_list_widget.dart';
import './widgets/date_selector_widget.dart';
import './widgets/input_mode_toggle_widget.dart';
import './widgets/milk_input_overlay_widget.dart';
import './widgets/production_summary_widget.dart';
import './widgets/time_session_selector_widget.dart';

class MilkProductionLogging extends StatefulWidget {
  const MilkProductionLogging({super.key});

  @override
  State<MilkProductionLogging> createState() => _MilkProductionLoggingState();
}

class _MilkProductionLoggingState extends State<MilkProductionLogging>
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  InputMode _selectedMode = InputMode.individual;
  String _selectedSession = 'Morning';
  TimeOfDay _selectedTime = TimeOfDay.now();
  Map<String, dynamic>? _selectedCow;
  bool _showInputOverlay = false;

  // Mock production data
  double _todayTotal = 142.5;
  double _yesterdayTotal = 138.2;
  int _recordedCows = 3;
  int _totalCows = 5;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      _selectedMode =
          _tabController.index == 0 ? InputMode.individual : InputMode.batch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Milk Production',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showProductionHistory,
            icon: CustomIconWidget(
              iconName: 'history',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
            tooltip: 'Production History',
          ),
          IconButton(
            onPressed: _showProductionChart,
            icon: CustomIconWidget(
              iconName: 'bar_chart',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
            tooltip: 'Production Chart',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              DateSelectorWidget(
                selectedDate: _selectedDate,
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
              ProductionSummaryWidget(
                todayTotal: _todayTotal,
                yesterdayTotal: _yesterdayTotal,
                unit: 'L',
                recordedCows: _recordedCows,
                totalCows: _totalCows,
              ),
              TimeSessionSelectorWidget(
                selectedSession: _selectedSession,
                onSessionChanged: (session) {
                  setState(() {
                    _selectedSession = session;
                  });
                },
                selectedTime: _selectedTime,
                onTimeChanged: (time) {
                  setState(() {
                    _selectedTime = time;
                  });
                },
              ),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildIndividualMode(),
                    _buildBatchMode(),
                  ],
                ),
              ),
            ],
          ),
          if (_showInputOverlay && _selectedCow != null)
            MilkInputOverlayWidget(
              cowData: _selectedCow!,
              onSaved: _handleIndividualSave,
              onCancel: () {
                setState(() {
                  _showInputOverlay = false;
                  _selectedCow = null;
                });
              },
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: _selectedMode == InputMode.individual
          ? FloatingActionButton.extended(
              onPressed: _showQuickEntry,
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              foregroundColor: AppTheme.lightTheme.colorScheme.onSecondary,
              icon: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.colorScheme.onSecondary,
                size: 20,
              ),
              label: Text(
                'Quick Entry',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: AppTheme.lightTheme.colorScheme.onPrimary,
        unselectedLabelColor:
            AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
        labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle:
            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'pets',
                  color: _tabController.index == 0
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                  size: 16,
                ),
                SizedBox(width: 1.w),
                const Text('Individual'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'format_list_bulleted',
                  color: _tabController.index == 1
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                  size: 16,
                ),
                SizedBox(width: 1.w),
                const Text('Batch'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualMode() {
    return CattleListWidget(
      onCowSelected: (cow) {
        setState(() {
          _selectedCow = cow;
          _showInputOverlay = true;
        });
      },
    );
  }

  Widget _buildBatchMode() {
    return BatchEntryWidget(
      onBatchSaved: _handleBatchSave,
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 8.h,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem('Dashboard', 'dashboard', '/dashboard-home'),
              _buildNavItem('Cattle', 'pets', '/cattle-list'),
              _buildNavItem(
                  'Milk Log', 'water_drop', '/milk-production-logging',
                  isSelected: true),
              _buildNavItem(
                  'Sales', 'point_of_sale', '/sales-transaction-entry'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, String iconName, String route,
      {bool isSelected = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                size: 20,
              ),
              SizedBox(height: 0.5.h),
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleIndividualSave(double quantity, String unit) {
    setState(() {
      _showInputOverlay = false;
      _selectedCow = null;
      _todayTotal += quantity;
      _recordedCows = (_recordedCows + 1).clamp(0, _totalCows);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Production recorded: $quantity $unit'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _handleBatchSave(double quantity, String unit) {
    setState(() {
      _todayTotal = quantity;
      _recordedCows = _totalCows;
    });
  }

  void _showQuickEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Quick Entry',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: BatchEntryWidget(
                onBatchSaved: (quantity, unit) {
                  Navigator.pop(context);
                  _handleBatchSave(quantity, unit);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductionHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Production history feature coming soon')),
    );
  }

  void _showProductionChart() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Production chart feature coming soon')),
    );
  }
}
