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

import 'data_manager.dart'; // Add this import


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
  late String role;
  late String email;
  late String firstName;
  late String lastName;

  @override
  void initState() {
    super.initState();
    _checkAuthToken();
    _loadProfileImage();
    _preloadUserData(); // Add this
    _clearStaleTripData(); // CRITICAL: Clear stale trip data on app entry
  }

  void _preloadUserData() async {
    // Preload all user data in the background
    DataManager.preloadData();
  }

  /// CRITICAL FIX: Automatically clear stale trip data when entering the app
  /// This prevents the navigation blocking bug where old trip data blocks navigation
  Future<void> _clearStaleTripData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tripId = prefs.getString('current_trip_id');
    String? startTimeStr = prefs.getString('trip_start_time');

    // If there's any trip data, clear it (it's from a previous session)
    if (tripId != null && startTimeStr != null) {
      print('🧹 Auto-clearing stale trip data from previous session');

      // Clear all trip-related data
      await prefs.remove('current_trip_id');
      await prefs.remove('trip_start_time');
      await prefs.setInt('batch_counter', 0);
      await prefs.setDouble('max_speed', 0.0);
      await prefs.setInt('point_counter', 0);
      await prefs.setDouble('current_speed', 0.0);
      await prefs.setDouble('total_distance', 0.0);

      print('✅ Stale trip data cleared - navigation unrestricted');
    }
  }


  // Future<void> _checkAuthToken() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('access_token');

  //   Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

  //   setState(() {
  //     role = decodedToken['role'];
  //     firstName = decodedToken['first_name'];
  //     lastName = decodedToken['last_name'];
  //     email = decodedToken['email'];
  //     isLoading = false;
  //   });

  //   await prefs.setString('role', role);
  //   await prefs.setString('first_name', firstName);
  //   await prefs.setString('last_name', lastName);
  //   await prefs.setString('email', email);
  //   }

  //uncomment above code if below function causes issues

  Future<void> _checkAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    String? userDataJson = prefs.getString('user_data');

    if (token != null && userDataJson != null) {
      try {
        // Try to decode as JWT first (for backward compatibility)
        Map<String, dynamic> decodedToken;
        try {
          decodedToken = JwtDecoder.decode(token);
        } catch (e) {
          // If JWT decode fails, decode our base64 JSON format
          final decodedBytes = base64.decode(token);
          final decodedString = utf8.decode(decodedBytes);
          decodedToken = json.decode(decodedString);
        }

        // Also parse the user_data we stored
        Map<String, dynamic> userData = json.decode(userDataJson);

        setState(() {
          role = decodedToken['role'] ?? widget.role;
          // Parse name from userData (your backend stores full name, not split)
          String fullName = userData['name'] ?? '';
          List<String> nameParts = fullName.split(' ');
          firstName = nameParts.isNotEmpty ? nameParts[0] : '';
          lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
          email = userData['email'] ?? decodedToken['email'] ?? '';
          isLoading = false;
        });

        await prefs.setString('role', role);
        await prefs.setString('first_name', firstName);
        await prefs.setString('last_name', lastName);
        await prefs.setString('email', email);
      } catch (e) {
        debugPrint('Error decoding token: $e');
        // Fall back to using the role passed from login
        setState(() {
          role = widget.role;
          firstName = 'User';
          lastName = '';
          email = '';
          isLoading = false;
        });
      }
    } else {
      debugPrint('No token found in SharedPreferences');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image');
    if (imagePath != null) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
      appBar: isLoading
          ? null
          : CustomAppBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              role: widget.role,
            ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: _buildRoleSpecificHomePage(isWeb),
              ),
            ),
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