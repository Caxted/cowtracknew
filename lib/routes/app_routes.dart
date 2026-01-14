import 'package:flutter/material.dart';

// Cattle
import 'package:cowtrack/presentation/cattle/cattle_list_page.dart';
import 'package:cowtrack/presentation/cattle/cattle_page.dart';

// Dashboard
import 'package:cowtrack/presentation/dashboard_home/dashboard_screen.dart';

// Government schemes
import 'package:cowtrack/presentation/government_schemes/government_schemes_screen.dart';
import 'package:cowtrack/presentation/government_schemes/scheme_webview_screen.dart';

// User profile
import 'package:cowtrack/presentation/user_profile/user_profile_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String dashboardHome = '/dashboard-home';
  static const String cattlePage = '/cattle';
  static const String cattleList = '/cattle-list';

  // Government schemes
  static const String governmentSchemesScreen =
      '/government-schemes-screen';
  static const String schemeWebView = '/scheme-webview';

  // User profile
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    // Dashboard
    initial: (context) => const DashboardScreen(),
    dashboardHome: (context) => const DashboardScreen(),

    // ✅ Cattle list (FIXED)
    cattleList: (context) {
      return const CattleListPage();
    },

    // Cattle detail (new style)
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

    // Cattle detail (old style – kept for backward compatibility)
    cattlePage: (context) {
      final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, String>;

      return CattlePage(
        cattleId: args['cattleId']!,
        cattleName: args['cattleName']!,
      );
    },

    // Government schemes list
    governmentSchemesScreen: (context) =>
    const GovernmentSchemesScreen(),

    // Scheme WebView
    schemeWebView: (context) {
      final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, String>;

      return SchemeWebViewScreen(
        title: args['title']!,
        url: args['url']!,
      );
    },

    // User profile
    profile: (context) => const UserProfileScreen(),
  };
}
