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
    ).animate(_expandAnimation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() => _isExpanded = !_isExpanded);

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  /// ✅ FIXED: call action directly
  void _handleAction(VoidCallback action) {
    _toggleMenu();       // close menu
    action();            // EXECUTE IMMEDIATELY
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.3),
            ),
          ),

        ..._buildActionButtons(),

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
    final actions = _getActionsForTab();

    return actions.asMap().entries.map((entry) {
      final index = entry.key;
      final action = entry.value;

      return AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          final offset = (index + 1) * 70.0 * _expandAnimation.value;

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
      case 0:
        return [
          {
            'icon': 'edit',
            'label': 'Edit Profile',
            'color': Colors.blue,
            'onPressed': widget.onEditProfile,
          },
        ];
      case 1:
        return [
          {
            'icon': 'add_circle',
            'label': 'Add Record',
            'color': Colors.orange,
            'onPressed': widget.onAddHealthRecord,
          },
        ];
      case 2:
        return [
          {
            'icon': 'water_drop',
            'label': 'Log Milk',
            'color': Colors.blue,
            'onPressed': widget.onLogMilkProduction,
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
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(label),
        ),
        SizedBox(width: 2.w),
        FloatingActionButton.small(
          heroTag: label, // unique
          onPressed: onPressed,
          backgroundColor: color,
          foregroundColor: Colors.white,
          child: CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }
}
