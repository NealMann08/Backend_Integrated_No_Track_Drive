/*
 * Home Page Router
 *
 * This is the main hub after login. It figures out what role the user has
 * (regular driver, insurance provider, or admin) and shows them the right
 * dashboard. Also handles loading the user's profile and clearing any
 * leftover trip data from previous sessions.
 */

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

import 'custom_app_bar.dart';
import 'user_home_page.dart';
import 'insurance_home_page.dart';
import 'admin_home_page.dart';
import 'data_manager.dart';

class HomePage extends StatefulWidget {
  final String role;

  const HomePage({super.key, required this.role});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  File? _profileImage;
  bool isLoading = true;

  // User info pulled from the auth token
  late String role;
  late String email;
  late String firstName;
  late String lastName;

  @override
  void initState() {
    super.initState();
    _checkAuthToken();
    _loadProfileImage();
    _preloadUserData();
    _clearStaleTripData();
  }

  // Start loading user data in background so screens load faster
  void _preloadUserData() async {
    DataManager.preloadData();
  }

  /// Clears any trip data left over from a previous app session
  /// This fixes a bug where old trip data would block navigation
  Future<void> _clearStaleTripData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tripId = prefs.getString('current_trip_id');
    String? startTimeStr = prefs.getString('trip_start_time');

    if (tripId != null && startTimeStr != null) {
      debugPrint('Clearing stale trip data from previous session');

      // Wipe all the old trip tracking data
      await prefs.remove('current_trip_id');
      await prefs.remove('trip_start_time');
      await prefs.setInt('batch_counter', 0);
      await prefs.setDouble('max_speed', 0.0);
      await prefs.setInt('point_counter', 0);
      await prefs.setDouble('current_speed', 0.0);
      await prefs.setDouble('total_distance', 0.0);

      debugPrint('Stale trip data cleared');
    }
  }

  /// Decodes the JWT token to get user info like name and role
  Future<void> _checkAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    String? userDataJson = prefs.getString('user_data');

    if (token != null && userDataJson != null) {
      try {
        // Try JWT decode first, fall back to base64 if that fails
        Map<String, dynamic> decodedToken;
        try {
          decodedToken = JwtDecoder.decode(token);
        } catch (e) {
          // Our custom token format uses base64
          final decodedBytes = base64.decode(token);
          final decodedString = utf8.decode(decodedBytes);
          decodedToken = json.decode(decodedString);
        }

        // Parse the stored user data
        Map<String, dynamic> userData = json.decode(userDataJson);

        setState(() {
          role = decodedToken['role'] ?? widget.role;

          // Split the full name into first and last
          String fullName = userData['name'] ?? '';
          List<String> nameParts = fullName.split(' ');
          firstName = nameParts.isNotEmpty ? nameParts[0] : '';
          lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

          email = userData['email'] ?? decodedToken['email'] ?? '';
          isLoading = false;
        });

        // Save to prefs so other screens can access it
        await prefs.setString('role', role);
        await prefs.setString('first_name', firstName);
        await prefs.setString('last_name', lastName);
        await prefs.setString('email', email);

      } catch (e) {
        debugPrint('Error decoding token: $e');
        // Something went wrong, use defaults
        setState(() {
          role = widget.role;
          firstName = 'User';
          lastName = '';
          email = '';
          isLoading = false;
        });
      }
    } else {
      debugPrint('No token found');
      setState(() => isLoading = false);
    }
  }

  // Load saved profile picture from device storage
  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image');
    if (imagePath != null) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  // Handle bottom nav bar taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Returns the appropriate home page based on user role
  Widget _buildRoleSpecificHomePage(bool isWeb) {
    switch (widget.role) {
      case 'user':
        return UserHomePage(
          firstName: firstName,
          lastName: lastName,
          profileImage: _profileImage,
        );
      case 'insurance':
        return const InsuranceHomePage();
      case 'admin':
        return const AdminHomePage();
      default:
        return const Center(child: Text('Unknown role'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final maxWidth = isWeb ? 1200.0 : double.infinity;
    final isAdminOrInsurance = widget.role == 'admin' || widget.role == 'insurance';

    return Scaffold(
      // Show the app bar for non-loading states
      appBar: isLoading
          ? null
          : CustomAppBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              role: widget.role,
            ),

      // Main content area
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: _buildRoleSpecificHomePage(isWeb),
              ),
            ),

      // Only show bottom nav for regular users (not admin/insurance)
      bottomNavigationBar: isLoading || isAdminOrInsurance
          ? null
          : CustomAppBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              role: widget.role,
            ).buildBottomNavBar(context),
    );
  }
}
