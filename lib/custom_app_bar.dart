import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importing all the necessary pages that this app bar will navigate to
import 'home_page.dart';
import 'previous_trips_page.dart';
import 'score_page.dart';
import 'settings_page.dart';

/// A custom AppBar widget that also implements PreferredSizeWidget to ensure proper sizing.
/// This widget handles both the top app bar and bottom navigation bar functionality.
/// It dynamically changes based on the user's role (admin, insurance, or regular user).
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex; // The currently selected tab index
  final Function(int) onItemTapped; // Callback when a tab is selected
  final String role; // User role ('admin', 'insurance', or default user)

  const CustomAppBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(_getAppBarTitle(selectedIndex)), // Dynamic title based on role and selected index
      centerTitle: true,
      backgroundColor: Colors.blue,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // Standard app bar height

  /// Returns the appropriate app bar title based on the user's role and selected index
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
    } else { // Default case for regular users
      switch (index) {
        case 0: return "Home";
        case 1: return "Previous Trips";
        case 2: return "Score";
        case 3: return "Account";
        default: return "Home";
      }
    }
  }

  /// Builds the navigation items for admin users
  List<BottomNavigationBarItem> _buildAdminNavItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_search),
        label: 'Users',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.business),
        label: 'Insurance',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_circle),
        label: 'Account',
      ),
    ];
  }

  /// Builds and returns the bottom navigation bar widget
  /// Handles tap events and navigation between pages
  Widget buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      elevation: 10,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        onItemTapped(index); // Update the selected index
        _navigateToPage(context, index); // Navigate to the corresponding page
      },
      items: role == 'insurance'
          ? _buildInsuranceNavItems()
          : role == 'admin'
              ? _buildAdminNavItems()
              : _buildUserNavItems(),
    );
  }

  /// Builds the navigation items for insurance users
  /// Insurance providers only have Dashboard and Settings
  List<BottomNavigationBarItem> _buildInsuranceNavItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];
  }

  /// Builds the navigation items for regular users
  List<BottomNavigationBarItem> _buildUserNavItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.directions_car),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.history),
        label: 'Previous Trips',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.star),
        label: 'Score',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_circle),
        label: 'Account',
      ),
    ];
  }

  /// Handles navigation to different pages based on the selected index and user role
  Future<void> _navigateToPage(BuildContext context, int index) async {
    // CRITICAL: Check if there's an active trip before allowing navigation
    // This prevents users from leaving the current trip page while tracking is active
    final prefs = await SharedPreferences.getInstance();
    final activeTripId = prefs.getString('current_trip_id');
    final tripStartTime = prefs.getString('trip_start_time');

    // Cache context check before async operations
    if (!context.mounted) return;

    // If there's an active trip, block navigation and show warning
    if (activeTripId != null && activeTripId.isNotEmpty && tripStartTime != null) {
      // Check if the trip is recent (within last 4 hours - not abandoned)
      final startTime = DateTime.parse(tripStartTime);
      final timeSinceStart = DateTime.now().difference(startTime);

      if (timeSinceStart.inHours <= 4) {
        // Active trip detected - prevent navigation
        if (!context.mounted) return;

        // CRITICAL FIX: Don't provide "Go to Trip" button as it creates a NEW CurrentTripPage
        // This would kill the active trip state and freeze the data
        // User should stop the trip manually instead
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trip in Progress',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Stop your trip before navigating',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return; // Block navigation
      }
    }

    Widget page;

    if (role == 'insurance') {
      // Insurance users only have Dashboard and Settings
      switch (index) {
        case 0:
          page = HomePage(role: role);  // Dashboard (Insurance Home Page)
          break;
        case 1:
          page = SettingsPage();  // Settings
          break;
        default:
          return;
      }
    } else if(role == 'admin'){
      switch (index) {
        case 0:
          page = HomePage(role: role);
          break;
        case 1:
          page = SettingsPage();
          break;
        case 2:
          page = SettingsPage();
          break;
        case 3:
          page = SettingsPage();
          break;
        default:
          return;
      }
    } else { // Default case for regular users
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

    // Check context is still mounted before navigation
    if (!context.mounted) return;

    // Replace the current page with the new one (no back stack)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}