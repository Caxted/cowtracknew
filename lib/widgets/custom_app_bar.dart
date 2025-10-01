import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget for agricultural mobile application
/// Provides consistent navigation and branding across the app
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String title;

  /// Whether to show the back button (defaults to true when there's a previous route)
  final bool showBackButton;

  /// Custom leading widget (overrides back button if provided)
  final Widget? leading;

  /// List of action widgets to display on the right side
  final List<Widget>? actions;

  /// Whether to center the title (defaults to false for agricultural professional look)
  final bool centerTitle;

  /// Custom background color (defaults to theme primary color)
  final Color? backgroundColor;

  /// Custom foreground color for text and icons
  final Color? foregroundColor;

  /// Elevation of the app bar
  final double elevation;

  /// Whether to show a bottom border for better definition
  final bool showBottomBorder;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 2.0,
    this.showBottomBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();

    return Container(
      decoration: showBottomBorder
          ? BoxDecoration(
              color: backgroundColor ?? theme.colorScheme.primary,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withAlpha(51),
                  width: 1.0,
                ),
              ),
            )
          : null,
      child: AppBar(
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: foregroundColor ?? theme.colorScheme.onPrimary,
            letterSpacing: 0.15,
          ),
        ),
        centerTitle: centerTitle,
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
        elevation: elevation,
        leading: leading ??
            (canPop && showBackButton ? _buildBackButton(context) : null),
        actions: actions ?? _buildDefaultActions(context),
        iconTheme: IconThemeData(
          color: foregroundColor ?? theme.colorScheme.onPrimary,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: foregroundColor ?? theme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }

  /// Builds the back button with proper touch target size
  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Back',
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(
        minWidth: 48,
        minHeight: 48,
      ),
    );
  }

  /// Builds default actions based on current route
  List<Widget>? _buildDefaultActions(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    switch (currentRoute) {
      case '/dashboard-home':
        return [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/cattle-list'),
            icon: const Icon(Icons.pets),
            tooltip: 'View Cattle',
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
          IconButton(
            onPressed: () => _showNotifications(context),
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
        ];

      case '/cattle-list':
        return [
          IconButton(
            onPressed: () => _showSearchDialog(context),
            icon: const Icon(Icons.search),
            tooltip: 'Search Cattle',
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
          IconButton(
            onPressed: () => _showFilterOptions(context),
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
        ];

      case '/cow-detail-profile':
        return [
          IconButton(
            onPressed: () => _showEditOptions(context),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
          IconButton(
            onPressed: () => _showMoreOptions(context),
            icon: const Icon(Icons.more_vert),
            tooltip: 'More Options',
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
        ];

      case '/milk-production-logging':
        return [
          IconButton(
            onPressed: () => _showCalendar(context),
            icon: const Icon(Icons.calendar_today),
            tooltip: 'View Calendar',
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
          IconButton(
            onPressed: () => _showHistory(context),
            icon: const Icon(Icons.history),
            tooltip: 'View History',
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
        ];

      case '/sales-transaction-entry':
        return [
          IconButton(
            onPressed: () => _showCalculator(context),
            icon: const Icon(Icons.calculate),
            tooltip: 'Calculator',
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
          IconButton(
            onPressed: () => _showSalesHistory(context),
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Sales History',
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
        ];

      default:
        return null;
    }
  }

  // Action handlers
  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications feature coming soon')),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Cattle'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter cattle ID or name...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.cake),
              title: const Text('By Age'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.female),
              title: const Text('By Gender'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.local_hospital),
              title: const Text('By Health Status'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditOptions(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile feature coming soon')),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Profile'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print Details'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete Profile'),
              textColor: Theme.of(context).colorScheme.error,
              iconColor: Theme.of(context).colorScheme.error,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showCalendar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calendar view coming soon')),
    );
  }

  void _showHistory(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('History view coming soon')),
    );
  }

  void _showCalculator(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculator feature coming soon')),
    );
  }

  void _showSalesHistory(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sales history coming soon')),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
