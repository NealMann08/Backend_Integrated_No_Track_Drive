/*
 * Custom App Bar & Navigation
 *
 * This handles both the top app bar and bottom navigation for the app.
 * It's smart enough to show different navigation options based on whether
 * the user is a regular driver, insurance provider, or admin.
 *
 * One tricky part: we block navigation if there's an active trip recording.
 * This prevents users from accidentally leaving mid-trip and losing their data.
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';
import 'previous_trips_page.dart';
import 'score_page.dart';
import 'settings_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final String role;

  const CustomAppBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(_getAppBarTitle(selectedIndex)),
      centerTitle: true,
      backgroundColor: Colors.blue,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // Returns the right title based on user role and current tab
  String _getAppBarTitle(int index) {
    if (role == 'insurance') {
      switch (index) {
        case 0: return "Dashboard";
        case 1: return "User Trips";
        case 2: return "User Scores";
        case 3: return "Account";
        default: return "Dashboard";
      }
    } else if (role == 'admin') {
      switch (index) {
        case 0: return "Dashboard";
        case 1: return "User Lookup";
        case 2: return "Insurance Lookup";
        case 3: return "Account";
        default: return "Dashboard";
      }
    } else {
      // Regular user
      switch (index) {
        case 0: return "Home";
        case 1: return "Previous Trips";
        case 2: return "Score";
        case 3: return "Account";
        default: return "Home";
      }
    }
  }

  // Navigation items for admin dashboard
  List<BottomNavigationBarItem> _buildAdminNavItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
      BottomNavigationBarItem(icon: Icon(Icons.person_search), label: 'Users'),
      BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Insurance'),
      BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
    ];
  }

  // Navigation items for insurance providers
  List<BottomNavigationBarItem> _buildInsuranceNavItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    ];
  }

  // Navigation items for regular drivers
  List<BottomNavigationBarItem> _buildUserNavItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Previous Trips'),
      BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Score'),
      BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
    ];
  }

  /// Builds the bottom navigation bar with role-appropriate items
  Widget buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      elevation: 10,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        onItemTapped(index);
        _navigateToPage(context, index);
      },
      items: role == 'insurance'
          ? _buildInsuranceNavItems()
          : role == 'admin'
              ? _buildAdminNavItems()
              : _buildUserNavItems(),
    );
  }

  /// Handles navigation between pages
  /// Blocks navigation if there's an active trip to prevent data loss
  Future<void> _navigateToPage(BuildContext context, int index) async {
    final prefs = await SharedPreferences.getInstance();
    final activeTripId = prefs.getString('current_trip_id');
    final tripStartTime = prefs.getString('trip_start_time');

    if (!context.mounted) return;

    // Check if there's an active trip that's not too old (within 4 hours)
    if (activeTripId != null && activeTripId.isNotEmpty && tripStartTime != null) {
      final startTime = DateTime.parse(tripStartTime);
      final timeSinceStart = DateTime.now().difference(startTime);

      if (timeSinceStart.inHours <= 4) {
        // Active trip - don't let them navigate away
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Trip in Progress',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Stop your trip before navigating', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return; // Block navigation
      }
    }

    // Determine which page to navigate to based on role and index
    Widget page;

    if (role == 'insurance') {
      switch (index) {
        case 0:
          page = HomePage(role: role);
          break;
        case 1:
          page = SettingsPage();
          break;
        default:
          return;
      }
    } else if (role == 'admin') {
      switch (index) {
        case 0:
          page = HomePage(role: role);
          break;
        default:
          page = SettingsPage();
      }
    } else {
      // Regular user navigation
      switch (index) {
        case 0:
          page = HomePage(role: role);
          break;
        case 1:
          page = PreviousTripsPage();
          break;
        case 2:
          page = ScorePage();
          break;
        case 3:
          page = SettingsPage();
          break;
        default:
          return;
      }
    }

    if (!context.mounted) return;

    // Replace current page (no back stack buildup)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
