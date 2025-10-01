import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FloatingActionMenuWidget extends StatefulWidget {
  final int activeTabIndex;
  final VoidCallback onEditProfile;
  final VoidCallback onAddHealthRecord;
  final VoidCallback onLogMilkProduction;

  const FloatingActionMenuWidget({
    super.key,
    required this.activeTabIndex,
    required this.onEditProfile,
    required this.onAddHealthRecord,
    required this.onLogMilkProduction,
  });

  @override
  State<FloatingActionMenuWidget> createState() =>
      _FloatingActionMenuWidgetState();
}

class _FloatingActionMenuWidgetState extends State<FloatingActionMenuWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.75,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleAction(VoidCallback action) {
    _toggleMenu();
    Future.delayed(const Duration(milliseconds: 150), action);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Backdrop
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),

        // Action buttons
        ..._buildActionButtons(),

        // Main FAB
        FloatingActionButton(
          onPressed: _toggleMenu,
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
          child: AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation.value * 2 * 3.14159,
                child: CustomIconWidget(
                  iconName: _isExpanded ? 'close' : 'add',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 24,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons() {
    final List<Map<String, dynamic>> actions = _getActionsForTab();

    return actions.asMap().entries.map((entry) {
      final index = entry.key;
      final action = entry.value;

      return AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          final double offset = (index + 1) * 70.0 * _expandAnimation.value;

          return Positioned(
            bottom: offset + 16,
            right: 16,
            child: Transform.scale(
              scale: _expandAnimation.value,
              child: Opacity(
                opacity: _expandAnimation.value,
                child: _buildActionButton(
                  icon: action['icon'],
                  label: action['label'],
                  color: action['color'],
                  onPressed: () => _handleAction(action['onPressed']),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  List<Map<String, dynamic>> _getActionsForTab() {
    switch (widget.activeTabIndex) {
      case 0: // Profile tab
        return [
          {
            'icon': 'edit',
            'label': 'Edit Profile',
            'color': Colors.blue,
            'onPressed': widget.onEditProfile,
          },
          {
            'icon': 'photo_camera',
            'label': 'Add Photo',
            'color': Colors.green,
            'onPressed': () => _showAddPhotoDialog(),
          },
        ];
      case 1: // Health Records tab
        return [
          {
            'icon': 'add_circle',
            'label': 'Add Record',
            'color': Colors.orange,
            'onPressed': widget.onAddHealthRecord,
          },
          {
            'icon': 'event',
            'label': 'Schedule Checkup',
            'color': Colors.purple,
            'onPressed': () => _showScheduleDialog(),
          },
        ];
      case 2: // Milk Statistics tab
        return [
          {
            'icon': 'water_drop',
            'label': 'Log Milk',
            'color': Colors.blue,
            'onPressed': widget.onLogMilkProduction,
          },
          {
            'icon': 'analytics',
            'label': 'View Report',
            'color': Colors.teal,
            'onPressed': () => _showReportDialog(),
          },
        ];
      default:
        return [];
    }
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 2.w),
        FloatingActionButton.small(
          onPressed: onPressed,
          backgroundColor: color,
          foregroundColor: Colors.white,
          heroTag: label,
          child: CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }

  void _showAddPhotoDialog() {
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
              'Add Photo',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_camera',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gallery feature coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Checkup'),
        content: const Text('Schedule a veterinary checkup for this cow?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checkup scheduled successfully')),
              );
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Report'),
        content: const Text('Generate a detailed milk production report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report generated successfully')),
              );
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }
}
