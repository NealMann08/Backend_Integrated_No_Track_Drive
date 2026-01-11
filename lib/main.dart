/*
 * DriveGuard - Safe Driving Analytics App
 * Main entry point for the application
 *
 * This app tracks driving behavior and provides safety scores to help
 * drivers improve their habits and potentially lower insurance rates.
 *
 * Built with Flutter for cross-platform support (iOS, Android, Web)
 */

import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'login_page.dart';
import 'admin_home_page.dart';
import 'insurance_home_page.dart';

void main() async {
  // Make sure Flutter is ready before we do anything else
  WidgetsFlutterBinding.ensureInitialized();

  // Set up the settings cache - this stores user preferences locally
  await Settings.init(cacheProvider: SharePreferenceCache());

  // Set up error handling so crashes don't go unnoticed during development
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Error caught: ${details.exception}');
  };

  runApp(const DriveGuardApp());
}

/// Root widget of the application
/// Sets up theming and navigation routes for the entire app
class DriveGuardApp extends StatelessWidget {
  const DriveGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveGuard',
      debugShowCheckedModeBanner: false,

      // App-wide theme configuration
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // Start at the login page
      home: const LoginPageWidget(),

      // Named routes for easy navigation throughout the app
      routes: {
        '/login': (context) => const LoginPageWidget(),
        '/admin': (context) => const AdminHomePage(),
        '/insurance': (context) => const InsuranceHomePage(),
      },
    );
  }
}
