import 'package:drive_guard/about_page.dart';
import 'package:drive_guard/helpSupport_page.dart';
import 'package:drive_guard/privacySecurity_page.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_app_bar.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'notifications_page.dart';
import 'data_manager.dart'; // Import DataManager for cache clearing

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});


  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage>
{
late String role;
bool isLoading = true;

int _selectedIndex = 3;

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index; // Switches pages     
      });
    }

 @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

Future<void> _loadUserInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  role = prefs.getString('role')!;
  //String? firstName = prefs.getString('first_name');
  //String? lastName = prefs.getString('last_name');
  //String? email = prefs.getString('email');
   setState((){
      isLoading = false;
  });


}

@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      // Navigate back to HomePage instead of the last screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(role: role)), // Pass role 
      );
      return false; // Prevent default back navigation
    },
    
    child: Scaffold(
      appBar: isLoading
          ? null
          : CustomAppBar(
        selectedIndex: 3, // Assuming index 3 is the "Settings" page
        onItemTapped: _onItemTapped,
        role: role,
      ),

      body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Makes tiles same color as background
                      Theme(
                        data: Theme.of(context).copyWith(
                          listTileTheme: ListTileThemeData(
                            tileColor: Colors.white,
                          ),
                        ),
                        child: SettingsGroup(
                          title: 'SETTINGS',
                          children: <Widget>[
                            const SizedBox(height: 8),
                            NotificationsPage(),
                            PrivSecPage(),
                            HelpSupportPage(),
                            AboutPage(),
                            buildLogout(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar from CustomAppBar
      bottomNavigationBar: isLoading
          ? null
          : CustomAppBar(
        selectedIndex: 3, // Keep this in sync with settings page index
        onItemTapped: _onItemTapped,
        role:role,
      ).buildBottomNavBar(context),
    )
  );
}


// Widget buildAccountSettings() => SimpleSettingsTile(
//   leading: Icon(
//     Icons.person,
//     color: Colors.blue[100],
//     ),
//   title: 'Account Settings',
//   subtitle: 'Privacy, Security, Language',
//   child: Container(),
//   onTap: () {
//   },
// );

Widget buildLogout(BuildContext context) => SimpleSettingsTile(
  title: 'Logout',
  leading: Icon(
    Icons.logout,
    color: Colors.redAccent,
  ),
  subtitle: '',
  onTap: () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 🔐 CRITICAL FIX: Clear ALL user-specific data to prevent data leakage
    print('🧹 Starting logout - clearing all user data...');

    // 1. Clear authentication tokens (FIXED: was using wrong key 'auth_token')
    await prefs.remove('access_token');
    await prefs.remove('auth_token'); // Legacy key (kept for compatibility)
    print('✅ Cleared authentication tokens');

    // 2. Clear user profile data
    await prefs.remove('user_data');
    await prefs.remove('user_id');
    await prefs.remove('email');
    await prefs.remove('first_name');
    await prefs.remove('last_name');
    await prefs.remove('role');
    await prefs.remove('user_zipcode');
    await prefs.remove('profile_image');
    print('✅ Cleared user profile data');

    // 3. Clear trip data caches
    await prefs.remove('cached_analytics');
    await prefs.remove('analytics_cache_time');
    await prefs.remove('analytics_cache_user_id'); // 🔐 Clear user_id associated with cache
    await prefs.remove('cached_trips');
    await prefs.remove('cache_time');
    print('✅ Cleared trip data caches');

    // 4. Clear active trip data
    await prefs.remove('current_trip_id');
    await prefs.remove('trip_start_time');
    await prefs.setInt('batch_counter', 0);
    await prefs.setDouble('max_speed', 0.0);
    await prefs.setInt('point_counter', 0);
    await prefs.setDouble('current_speed', 0.0);
    await prefs.setDouble('total_distance', 0.0);
    await prefs.setInt('elapsed_time', 0);
    print('✅ Cleared active trip data');

    // 5. Clear DataManager static cache (CRITICAL!)
    DataManager.clearCache();
    print('✅ Cleared DataManager static cache');

    // 6. Get all keys and clear any trip-specific data
    Set<String> allKeys = prefs.getKeys();
    for (String key in allKeys) {
      if (key.startsWith('first_actual_point_') ||
          key.startsWith('previous_point_') ||
          key.startsWith('trip_') ||
          key.startsWith('cached_')) {
        await prefs.remove(key);
        print('✅ Cleared trip-specific key: $key');
      }
    }

    print('🔐 Logout complete - all user data cleared');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPageWidget()),
      (route) => false, // Remove all previous routes
    );
  },
);

Widget buildReportBug(BuildContext context) => SimpleSettingsTile(
  title: 'Report A Bug',
  subtitle: '',
  leading: Icon(
    Icons.bug_report,
    color: Colors.purple[400],
  ),
  onTap:() {
    
  },
);

Widget buildsendFeedback(BuildContext context) => SimpleSettingsTile(
  title: 'Send Feedback',
  subtitle: '',
  leading: Icon(
    Icons.thumbs_up_down,
    color: Colors.orange[700],
  ),
  onTap: () {
    
  },
);

Widget buildReviewDriving(BuildContext context) => SimpleSettingsTile(
  title: 'Review Driving',
  subtitle: 'Score, Trips, Habits',
  leading: Icon(
    Icons.privacy_tip,
    color: Colors.red,
  ),
  onTap: () {
      
  },
);

 // void setState(Null Function() param0) {}


      // backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text('Account Settings'),
      //   backgroundColor: Colors.blue.shade700,
      // ),
      // body: Padding(
      //   padding: const EdgeInsets.all(20),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.stretch,
      //     children: [
      //       Text(
      //         'Account Settings',
      //         style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      //       ),
      //       SizedBox(height: 20),
      //       ElevatedButton(
      //         onPressed: () {
      //           // Implement logout functionality
      //           Navigator.pushAndRemoveUntil(
      //             context,
      //             MaterialPageRoute(builder: (context) => LoginPageWidget()),
      //             (route) => false, // Remove all previous routes
      //           );
      //         },
      //         child: Text('Logout'),
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Color(0xFF7AC143), // Accent color for buttons
      //           padding: EdgeInsets.symmetric(vertical: 15),
      //           textStyle: TextStyle(fontSize: 16),
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(30),
      //           ),
      //           elevation: 5,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
}
