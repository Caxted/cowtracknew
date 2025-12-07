// lib/routes/app_routes.dart
import 'package:flutter/material.dart';

// Use package imports (more stable than relative paths)
import 'package:cowtrack/presentation/cattle/cattle_list_page.dart';
import 'package:cowtrack/presentation/cattle/cattle_page.dart';
import 'package:cowtrack/presentation/dashboard_home/dashboard_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String dashboardHome = '/dashboard-home';
  static const String cattlePage = '/cattle';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const DashboardScreen(),
    dashboardHome: (context) => const DashboardScreen(),

    // cattle list route
    '/cattle-list': (context) {
      return const CattleListPage(ownerId: 'dev-owner');
    },

    // cattle detail route
    '/cattle-detail': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final cattleId = args?['cattleId'] as String? ?? '';
      final cattleName = args?['cattleName'] as String? ?? '';
      return CattlePage(cattleId: cattleId, cattleName: cattleName);
    },

    // keep old route (unchanged behavior)
    cattlePage: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      return CattlePage(
        cattleId: args['cattleId']!,
        cattleName: args['cattleName']!,
      );
    },
  };
}
