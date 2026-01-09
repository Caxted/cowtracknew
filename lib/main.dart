import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

// ⭐ Provider
import 'package:provider/provider.dart';
import 'package:cowtrack/providers/user_provider.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';

// Login pages
import '../widgets/Login/login_page.dart';
import '../widgets/Login/signup.dart';
import '../widgets/Login/forgotpassword.dart';

// Dashboard
import '../presentation/dashboard_home/dashboard_screen.dart';

// Cattle pages
import 'package:cowtrack/presentation/cattle/cattle_page.dart';
import 'package:cowtrack/presentation/cattle/cattle_list_page.dart';

import 'package:cowtrack/presentation/user_profile/user_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool _hasShownError = false;

  // ⭐ FIREBASE INIT (UNCHANGED)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🚨 Custom error widget (UNCHANGED)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!_hasShownError) {
      _hasShownError = true;

      Future.delayed(const Duration(seconds: 5), () {
        _hasShownError = false;
      });

      return CustomErrorWidget(errorDetails: details);
    }
    return const SizedBox.shrink();
  };

  // 🚨 Orientation lock (UNCHANGED)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    // ⭐ PROVIDER WRAPPER (NEW & SAFE)
    ChangeNotifierProvider(
      create: (_) => UserProvider()..loadUserProfile(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'cowtrack',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,

          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },

          debugShowCheckedModeBanner: false,

          // 🔁 ROUTES (UNCHANGED)
          routes: {
            '/login': (context) => const LoginPage(),
            '/register': (context) => const SignupPage(),
            '/forgot': (context) => const ForgotPasswordPage(),
            '/dashboard': (context) => const DashboardScreen(),

            // Cattle navigation
            '/cattle-list': (context) => const CattlePage(
              cattleId: 'test-cow-1',
              cattleName: 'Bella',
            ),

            // App-wide routes
            ...AppRoutes.routes,
          },

          // 🔥 App starts with login
          initialRoute: '/login',
        );
      },
    );
  }
}
