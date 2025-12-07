import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation item data structure
class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Custom Bottom Navigation Bar for agricultural mobile application
/// Provides primary navigation between main app sections
class CustomBottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when navigation item is tapped
  final ValueChanged<int>? onTap;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom selected item color
  final Color? selectedItemColor;

  /// Custom unselected item color
  final Color? unselectedItemColor;

  /// Whether to show labels
  final bool showLabels;

  /// Elevation of the bottom bar
  final double elevation;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.showLabels = true,
    this.elevation = 8.0,
  });

  /// Navigation items for the agricultural app
  static const List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard-home',
    ),
    BottomNavItem(
      icon: Icons.pets_outlined,
      activeIcon: Icons.pets,
      label: 'Cattle',
      route: '/cattle-list',
    ),
    BottomNavItem(
      icon: Icons.water_drop_outlined,
      activeIcon: Icons.water_drop,
      label: 'Milk Log',
      route: '/milk-production-logging',
    ),
    BottomNavItem(
      icon: Icons.point_of_sale_outlined,
      activeIcon: Icons.point_of_sale,
      label: 'Sales',
      route: '/sales-transaction-entry',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(26),
            blurRadius: elevation,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80, // Slightly increased height to prevent overflow
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return _buildNavItem(
                context,
                item,
                isSelected,
                index,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Builds individual navigation item
  Widget _buildNavItem(
      BuildContext context,
      BottomNavItem item,
      bool isSelected,
      int index,
      ) {
    final theme = Theme.of(context);
    final selectedColor = selectedItemColor ?? theme.colorScheme.primary;
    final unselectedColor =
        unselectedItemColor ?? theme.colorScheme.onSurface.withAlpha(153);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleTap(context, index, item.route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with selection indicator
              Container(
                padding: const EdgeInsets.all(4),
                decoration: isSelected
                    ? BoxDecoration(
                  color: selectedColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                )
                    : null,
                child: Icon(
                  isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                  size: 24,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
              ),

              const SizedBox(height: 4),

              // Label with Flexible to prevent overflow
              if (showLabels)
                Flexible(
                  child: Text(
                    item.label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? selectedColor : unselectedColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles navigation item tap
  void _handleTap(BuildContext context, int index, String route) {
    onTap?.call(index);

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != route) {
      Navigator.pushNamedAndRemoveUntil(context, route, (r) => r.isFirst);

    }
  }

  /// Helper method to get current index based on route
  static int getCurrentIndex(String? currentRoute) {
    for (int i = 0; i < _navItems.length; i++) {
      if (_navItems[i].route == currentRoute) {
        return i;
      }
    }
    return 0; // Default to dashboard
  }

  /// Helper method to check if a route is a main navigation route
  static bool isMainRoute(String? route) {
    return _navItems.any((item) => item.route == route);
  }
}
