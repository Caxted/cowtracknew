// lib/routes/app_routes.dart
import 'package:flutter/material.dart';

// Use package imports (more stable than relative paths)
import 'package:cowtrack/presentation/cattle/cattle_list_page.dart';
import 'package:cowtrack/presentation/cattle/cattle_page.dart';
import 'package:cowtrack/presentation/dashboard_home/dashboard_screen.dart';

// ✅ NEW imports
import 'package:cowtrack/presentation/government_schemes/government_schemes_screen.dart';
import 'package:cowtrack/presentation/government_schemes/scheme_webview_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String dashboardHome = '/dashboard-home';
  static const String cattlePage = '/cattle';

  // ✅ NEW route names
  static const String governmentSchemesScreen =
      '/government-schemes-screen';
  static const String schemeWebView = '/scheme-webview';

  static Map<String, WidgetBuilder> routes = {
    // Dashboard
    initial: (context) => const DashboardScreen(),
    dashboardHome: (context) => const DashboardScreen(),

    // Cattle list route
    '/cattle-list': (context) {
      return const CattleListPage(ownerId: 'dev-owner');
    },

    // Cattle detail route
    '/cattle-detail': (context) {
      final args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final cattleId = args?['cattleId'] as String? ?? '';
      final cattleName = args?['cattleName'] as String? ?? '';
      return CattlePage(
        cattleId: cattleId,
        cattleName: cattleName,
      );
    },

    // Keep old cattle route (unchanged behavior)
    cattlePage: (context) {
      final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      return CattlePage(
        cattleId: args['cattleId']!,
        cattleName: args['cattleName']!,
      );
    },

    // ✅ Government Schemes list screen
    governmentSchemesScreen: (context) =>
    const GovernmentSchemesScreen(),

    // ✅ Common WebView screen for schemes
    schemeWebView: (context) {
      final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, String>;

      return SchemeWebViewScreen(
        title: args['title']!,
        url: args['url']!,
      );
    },
  };
}
