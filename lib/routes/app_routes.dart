import 'package:flutter/material.dart';
import '../presentation/cattle_list/cattle_list.dart';
import '../presentation/sales_transaction_entry/sales_transaction_entry.dart';
import '../presentation/cow_detail_profile/cow_detail_profile.dart';
import '../presentation/milk_production_logging/milk_production_logging.dart';
import '../presentation/dashboard_home/dashboard_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String cattleList = '/cattle-list';
  static const String salesTransactionEntry = '/sales-transaction-entry';
  static const String cowDetailProfile = '/cow-detail-profile';
  static const String milkProductionLogging = '/milk-production-logging';
  static const String dashboardHome = '/dashboard-home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const CattleList(),
    cattleList: (context) => const CattleList(),
    salesTransactionEntry: (context) => const SalesTransactionEntry(),
    cowDetailProfile: (context) => const CowDetailProfile(),
    milkProductionLogging: (context) => const MilkProductionLogging(),
    dashboardHome: (context) => const DashboardScreen(),
    // TODO: Add your other routes here
  };
}
