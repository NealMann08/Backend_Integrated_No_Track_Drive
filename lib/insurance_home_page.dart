import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'trip_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_helper.dart';


class InsuranceHomePage extends StatefulWidget {
  const InsuranceHomePage({super.key});

  @override
  _InsuranceHomePageState createState() => _InsuranceHomePageState();
}

class _InsuranceHomePageState extends State<InsuranceHomePage> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _foundUsers = [];
  Map<String, dynamic>? _selectedUser;
  Map<String, dynamic>? _selectedTrip;  // ADD THIS LINE
  bool _isLoadingUsers = false;
  bool _isLoadingScore = false;
  bool _isLoadingTrips = false;
  String _tripSortOption = 'recent';
  String _searchedUserId = '';
  List<Map<String, dynamic>> _userTrips = [];
  Map<String, dynamic>? _userScore;
  String _searchError = '';

@override
Widget build(BuildContext context) {
  final isWeb = kIsWeb;

  return LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(isWeb ? 32.0 : 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(isWeb: isWeb),
                SizedBox(height: isWeb ? 32 : 24),
                Text('Manage Users', style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: 12),
                isWeb ? _buildWebLayout(constraints) : _buildMobileLayout(isWeb),
              ],
            ),
          ),
        ),
      );
    },
  );
}


// Widget _buildWebLayout(BoxConstraints constraints) {
//   return Row(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Expanded(
//         flex: 2,
//         child: Column(
//           children: [
//             _buildUserSearchCard(isWeb: true, forWebLayout: true, availableHeight: constraints.maxHeight * 0.4),
//             SizedBox(height: 24),
//             _buildUserTripsCard(isWeb: true, forWebLayout: true, availableHeight: constraints.maxHeight * 0.5),
//           ],
//         ),
//       ),
//       SizedBox(width: 24),
//       Expanded(
//         flex: 1,
//         child: _buildUserScoreCard(isWeb: true, forWebLayout: true),
//       ),
//     ],
//   );
// }
// revert to above if below has issues
Widget _buildWebLayout(BoxConstraints constraints) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 2,
        child: Column(
          children: [
            _buildUserSearchCard(isWeb: true, forWebLayout: true, availableHeight: constraints.maxHeight * 0.4),
            SizedBox(height: 24),
            _buildHarshEventsCard(isWeb: true),
            SizedBox(height: 24),
            _buildScoreTrajectoryCard(isWeb: true),
            SizedBox(height: 24),
            _buildUserTripsCard(isWeb: true, forWebLayout: true, availableHeight: constraints.maxHeight * 0.4),
          ],
        ),
      ),
      SizedBox(width: 24),
      Expanded(
        flex: 1,
        child: Column(
          children: [
            _buildUserScoreCard(isWeb: true, forWebLayout: true),
            SizedBox(height: 24),
            _buildDriverDetailsCard(isWeb: true),
          ],
        ),
      ),
    ],
  );
}

// Widget _buildMobileLayout(bool isWeb) {
//   return Column(
//     children: [
//       _buildUserSearchCard(isWeb: isWeb),
//       SizedBox(height: 24),
//       _buildUserScoreCard(isWeb: isWeb),
//       SizedBox(height: 24),
//       _buildUserTripsCard(isWeb: isWeb),
//     ],
//   );
// }
// revert to above if below has issues
Widget _buildMobileLayout(bool isWeb) {
  return Column(
    children: [
      _buildUserSearchCard(isWeb: isWeb),
      SizedBox(height: 24),
      _buildUserScoreCard(isWeb: isWeb),
      SizedBox(height: 24),
      _buildHarshEventsCard(isWeb: isWeb),
      SizedBox(height: 24),
      _buildScoreTrajectoryCard(isWeb: isWeb),
      SizedBox(height: 24),
      _buildDriverDetailsCard(isWeb: isWeb),
      SizedBox(height: 24),
      _buildUserTripsCard(isWeb: isWeb),
    ],
  );
}


  // Widget _buildWelcomeCard({required bool isWeb}) {
  //   return Card(
  //     elevation: isWeb ? 8 : 6,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
  //     ),
  //     child: Container(
  //       padding: EdgeInsets.all(isWeb ? 32 : 24),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //           colors: [Colors.blue.shade700, Colors.blue.shade400],
  //         ),
  //         borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(
  //             Icons.dashboard,
  //             size: isWeb ? 60 : 40,
  //             color: Colors.white,
  //           ),
  //           SizedBox(width: isWeb ? 24 : 16),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'Insurance Dashboard',
  //                   style: TextStyle(
  //                     fontSize: isWeb ? 28 : 24,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //                 SizedBox(height: isWeb ? 8 : 4),
  //                 Text(
  //                   'Manage user data and driving scores',
  //                   style: TextStyle(
  //                     fontSize: isWeb ? 18 : 16,
  //                     color: Colors.white.withAlpha(230),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  // revert to above if below has issues
  Widget _buildWelcomeCard({required bool isWeb}) {
    // Get ISP name from SharedPreferences
    String ispName = 'Insurance Provider'; // Default

    // Add this async call to get the name
    SharedPreferences.getInstance().then((prefs) {
      final userData = prefs.getString('user_data');
      if (userData != null) {
        final data = json.decode(userData);
        setState(() {
          ispName = data['name'] ?? 'Insurance Provider';
        });
      }
    });

    return Card(
      elevation: isWeb ? 8 : 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
      ),
      child: Container(
        padding: EdgeInsets.all(isWeb ? 32 : 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.blue.shade400],
          ),
          borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.dashboard,
              size: isWeb ? 60 : 40,
              color: Colors.white,
            ),
            SizedBox(width: isWeb ? 24 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ispName,  // Show actual ISP name
                    style: TextStyle(
                      fontSize: isWeb ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isWeb ? 8 : 4),
                  Text(
                    'Insurance Analytics Dashboard',
                    style: TextStyle(
                      fontSize: isWeb ? 18 : 16,
                      color: Colors.white.withAlpha(230),
                    ),
                  ),
                ],
              ),
            ),
            // Logout button
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
                size: isWeb ? 28 : 24,
              ),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_data');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

Widget _buildUserSearchCard({
  required bool isWeb,
  bool showCloseButton = false,
  bool forWebLayout = false,
  double? availableHeight,
}) {
  final effectiveHeight = availableHeight ?? (isWeb ? 400.0 : 300.0);

  return Card(
    elevation: isWeb ? 4 : 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(isWeb ? 12 : 8),
    ),
    child: Container(
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      constraints: BoxConstraints(
        minHeight: 200,
        maxHeight: effectiveHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showCloseButton)
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 8),
                Text(
                  'Search Users',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          if (!showCloseButton)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  forWebLayout ? 'User Search' : 'Find User',
                  style: TextStyle(
                    fontSize: isWeb ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                if (forWebLayout)
                  Icon(Icons.search, color: Colors.blue.shade800),
              ],
            ),
           SizedBox(height: isWeb ? 12 : 8),
          // TextField(
          //   decoration: InputDecoration(
          //     labelText: 'Search by name, email or ID',
          //     border: OutlineInputBorder(),
          //     suffixIcon: IconButton(
          //       icon: Icon(Icons.search),
          //       onPressed: _searchForUsers,
          //     ),
          //     contentPadding: EdgeInsets.symmetric(
          //       vertical: isWeb ? 16 : 12,
          //       horizontal: isWeb ? 16 : 12,
          //     ),
          //   ),
          //   onChanged: (value) => _searchQuery = value,
          //   onSubmitted: (_) => _searchForUsers(),
          // ),
          //revert to above if below has issues
          TextField(
            decoration: InputDecoration(
              labelText: 'Enter driver email address',  // Changed label
              hintText: 'example@email.com',  // Added hint
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: _searchForUsers,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: isWeb ? 16 : 12,
                horizontal: isWeb ? 16 : 12,
              ),
            ),
            onChanged: (value) => _searchQuery = value,
            onSubmitted: (_) => _searchForUsers(),
          ),
          SizedBox(height: isWeb ? 12 : 8),
          
          if (_isLoadingUsers)
            Container(
              height: effectiveHeight * 0.5,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          else if (_foundUsers.isNotEmpty)
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 100,
                maxHeight: effectiveHeight - 100, // Account for header space
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: _foundUsers.length,
                itemBuilder: (context, index) {
                  final user = _foundUsers[index];
                  final name = user['name']?.toString() ?? 'Unknown';
                  final email = user['email']?.toString() ?? 'No email';
                  final firstChar = name.isNotEmpty ? name[0] : '?';

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 2),
                    child: ListTile(
            dense: true,
  visualDensity: VisualDensity.compact,
  contentPadding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 4),
                      leading: CircleAvatar(
                        radius: isWeb ? 20 : 16,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          firstChar,
                          style: TextStyle(color: Colors.blue.shade800),
                        ),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontSize: isWeb ? 14 : 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        email,
                        style: TextStyle(fontSize: isWeb ? 12 : 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        if (user['user_id'] != null) {
                          _selectUser(user);
                          if (showCloseButton) Navigator.pop(context);
                        }
                      },
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: effectiveHeight * 0.5,
              alignment: Alignment.center,
              child: Text(
                _searchError.isNotEmpty 
                    ? _searchError
                    : 'No users found',
                style: TextStyle(
                  color: _searchError.isNotEmpty ? Colors.red : Colors.grey,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

// void _selectUser(Map<String, dynamic> user) {
//   setState(() {
//     _selectedUser = user;
//     _searchedUserId = user['user_id'].toString(); // Convert to String
//   });
//   _loadUserScore(_searchedUserId);
//   _loadUserTrips(_searchedUserId);
// }
//revert to above if below has issues
void _selectUser(Map<String, dynamic> user) {
  setState(() {
    _selectedUser = user;
    _searchedUserId = user['user_id'].toString();

    // If we have analytics data, use it directly
    if (user.containsKey('analytics_data')) {
      Map<String, dynamic> analytics = user['analytics_data'];

      // Calculate event totals from trip data
      List<dynamic> trips = analytics['trips'] as List? ?? [];
      int totalSuddenAccelerations = 0;
      int totalSuddenDecelerations = 0;
      int totalHardStops = 0;
      int totalDangerousTurns = 0;
      double totalSmoothness = 0;

      for (var trip in trips) {
        totalSuddenAccelerations += (trip['sudden_accelerations'] ?? 0) as int;
        totalSuddenDecelerations += (trip['sudden_decelerations'] ?? 0) as int;
        totalHardStops += (trip['hard_stops'] ?? 0) as int;
        totalDangerousTurns += (trip['dangerous_turns'] ?? 0) as int;
        totalSmoothness += (trip['smoothness_score'] ?? 85.0) as double;
      }

      double totalDistance = (analytics['total_distance_miles'] ?? 0.0).toDouble();
      int totalTrips = trips.length;

      // Calculate acceleration score based on sudden accelerations per 100 miles
      // Industry standard: 0-2/100mi = Excellent, 2-5 = Good, 5-10 = Fair, 10+ = Poor
      double accelEventsPerHundred = totalDistance > 0
          ? (totalSuddenAccelerations / totalDistance) * 100
          : 0;
      double accelScore;
      if (accelEventsPerHundred <= 1) {
        accelScore = 95 + (1 - accelEventsPerHundred) * 5; // 95-100
      } else if (accelEventsPerHundred <= 3) {
        accelScore = 85 + (3 - accelEventsPerHundred) * 5; // 85-95
      } else if (accelEventsPerHundred <= 6) {
        accelScore = 70 + (6 - accelEventsPerHundred) * 5; // 70-85
      } else if (accelEventsPerHundred <= 10) {
        accelScore = 50 + (10 - accelEventsPerHundred) * 5; // 50-70
      } else {
        accelScore = (50 - (accelEventsPerHundred - 10) * 2).clamp(20, 50); // 20-50
      }

      // Calculate braking score based on sudden decelerations + hard stops per 100 miles
      int totalBrakingEvents = totalSuddenDecelerations + totalHardStops;
      double brakeEventsPerHundred = totalDistance > 0
          ? (totalBrakingEvents / totalDistance) * 100
          : 0;
      double brakeScore;
      if (brakeEventsPerHundred <= 1) {
        brakeScore = 95 + (1 - brakeEventsPerHundred) * 5; // 95-100
      } else if (brakeEventsPerHundred <= 3) {
        brakeScore = 85 + (3 - brakeEventsPerHundred) * 5; // 85-95
      } else if (brakeEventsPerHundred <= 6) {
        brakeScore = 70 + (6 - brakeEventsPerHundred) * 5; // 70-85
      } else if (brakeEventsPerHundred <= 10) {
        brakeScore = 50 + (10 - brakeEventsPerHundred) * 5; // 50-70
      } else {
        brakeScore = (50 - (brakeEventsPerHundred - 10) * 2).clamp(20, 50); // 20-50
      }

      // Average smoothness score from trips (fallback if no trip data)
      double avgSmoothness = totalTrips > 0 ? totalSmoothness / totalTrips : 85.0;

      // Calculate frequency score using same benchmarks as backend
      // This represents 35% of the overall score
      double eventsPerHundred = (analytics['events_per_100_miles'] ?? 0).toDouble();
      double frequencyScore;
      if (eventsPerHundred <= 5.0) {
        frequencyScore = 95;  // Exceptional
      } else if (eventsPerHundred <= 15.0) {
        frequencyScore = 85;  // Excellent
      } else if (eventsPerHundred <= 30.0) {
        frequencyScore = 75;  // Very Good
      } else if (eventsPerHundred <= 50.0) {
        frequencyScore = 65;  // Good
      } else if (eventsPerHundred <= 80.0) {
        frequencyScore = 55;  // Fair
      } else if (eventsPerHundred <= 120.0) {
        frequencyScore = 40;  // Poor
      } else {
        frequencyScore = 25;  // Dangerous
      }

      // Calculate average turn safety score from trips
      double totalTurnSafetyScore = 0;
      int tripsWithTurns = 0;
      for (var trip in trips) {
        double turnScore = (trip['turn_safety_score'] ?? 0).toDouble();
        if (turnScore > 0) {
          totalTurnSafetyScore += turnScore;
          tripsWithTurns++;
        }
      }
      double avgTurnSafetyScore = tripsWithTurns > 0
          ? totalTurnSafetyScore / tripsWithTurns
          : 85.0;  // Default when no turn data

      // Set the score data matching backend's calculation
      // Backend weights: frequency 35%, smoothness 25%, consistency 25%, turn 15%
      _userScore = {
        'score': analytics['overall_behavior_score'] ?? 0,
        'behavior_score': analytics['overall_behavior_score'] ?? 0,
        'frequency_score': frequencyScore / 100, // Store as 0-1
        'smoothness_score': avgSmoothness / 100, // Store as 0-1
        'accel_score': accelScore / 100, // Legacy, for display purposes
        'brake_score': brakeScore / 100, // Legacy, for display purposes
        'trip_score': (analytics['overall_behavior_score'] ?? 0) / 100,
        'speed_consistency': analytics['speed_consistency_score'] ?? 0,
        'turn_quality': analytics['safe_turns_percentage'] ?? 0,
        'safe_turns_percentage': analytics['safe_turns_percentage'] ?? 0,
        'turn_safety_score': avgTurnSafetyScore,
        'risk_level': analytics['risk_level'] ?? 'Unknown',
        'total_trips': analytics['total_trips'] ?? 0,
        'total_distance': analytics['total_distance_miles'] ?? 0,
        'total_driving_time': analytics['total_driving_time_hours'] ?? 0,
        'avg_trip_distance': analytics['avg_trip_distance_miles'] ?? 0,
        'avg_trip_duration': analytics['avg_trip_duration_minutes'] ?? 0,
        'total_harsh_events': analytics['total_harsh_events'] ?? 0,
        'total_dangerous_events': analytics['total_dangerous_events'] ?? 0,
        'events_per_100_miles': analytics['events_per_100_miles'] ?? 0,
        'updated_at': analytics['analysis_timestamp'] ?? DateTime.now().toIso8601String(),
      };

      // Store event totals in analytics for the harsh events card
      analytics['total_sudden_accelerations'] = totalSuddenAccelerations;
      analytics['total_sudden_decelerations'] = totalSuddenDecelerations;
      analytics['total_hard_stops'] = totalHardStops;
      analytics['total_dangerous_turns'] = totalDangerousTurns;
      
      // Set the trips data
      List<dynamic> rawTrips = analytics['trips'] as List? ?? [];
      List<Map<String, dynamic>> mappedTrips = rawTrips.map((trip) => {
        'trip_id': trip['trip_id'],
        'start_time': trip['start_timestamp'],
        'end_time': trip['end_timestamp'],
        'distance': trip['total_distance_miles'] ?? 0,
        'duration': trip['duration_minutes'] ?? 0,
        'avg_speed': trip['avg_speed_mph'] ?? 0,
        'max_speed': trip['max_speed_mph'] ?? 0,
        'behavior_score': trip['behavior_score'] ?? 0,
        'sudden_accelerations': trip['sudden_accelerations'] ?? 0,
        'sudden_decelerations': trip['sudden_decelerations'] ?? 0,
        'hard_stops': trip['hard_stops'] ?? 0,
        'dangerous_turns': trip['dangerous_turns'] ?? 0,
        'safe_turns': trip['safe_turns'] ?? 0,
        'aggressive_turns': trip['aggressive_turns'] ?? 0,
      }).toList();

      // Apply initial sorting based on current sort option
      if (_tripSortOption == 'recent') {
        mappedTrips.sort((a, b) {
          try {
            final aTime = DateTime.parse(a['end_time'] ?? '');
            final bTime = DateTime.parse(b['end_time'] ?? '');
            return bTime.compareTo(aTime); // Newest first
          } catch (e) {
            return 0;
          }
        });
      } else if (_tripSortOption == 'distance') {
        mappedTrips.sort((a, b) {
          final aDistance = (a['distance'] ?? 0).toDouble();
          final bDistance = (b['distance'] ?? 0).toDouble();
          return bDistance.compareTo(aDistance); // Longest first
        });
      }

      _userTrips = mappedTrips;
      
      _isLoadingScore = false;
      _isLoadingTrips = false;
    } else {
      // Fallback to original method if no analytics data
      _loadUserScore(_searchedUserId);
      _loadUserTrips(_searchedUserId);
    }
  });
}

Widget _buildUserScoreCard({
  required bool isWeb,
  bool forWebLayout = false,
  bool showFullDetails = true,
}) {
  // Convert score from 0-1 to 0-100 if needed
  final score = _userScore != null 
      ? (_userScore!['score'] is double && _userScore!['score'] <= 1.0 
          ? (_userScore!['score'] * 100).round() 
          : _userScore!['score'].round())
      : 0;

  return Card(
    elevation: isWeb ? 4 : 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(isWeb ? 12 : 8),
    ),
    child: Padding(
      padding: EdgeInsets.all(isWeb ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            forWebLayout ? 'Driver Safety Score' : 'User Safety Score',
            style: TextStyle(
              fontSize: isWeb ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: isWeb ? 16 : 12),
          
          if (_isLoadingScore)
            Center(child: CircularProgressIndicator())
          else if (_userScore == null)
            Center(child: Text('Select a user to view their score'))
          else
            Column(
              children: [
                // Mobile-friendly score display
                if (!isWeb && !forWebLayout) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: score / 100,
                                  semanticsLabel: 'Safety score',
                                  strokeWidth: 8,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getScoreColor(score.toDouble()),
                                  ),
                                ),
                                Text(
                                  '$score',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _getScoreRating(score.toDouble()),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_userScore!.containsKey('accel_score'))
                              _buildMobileScoreRow(
                                'Acceleration', 
                                (_userScore!['accel_score'] * 100).round(),
                              ),
                            if (_userScore!.containsKey('brake_score'))
                              _buildMobileScoreRow(
                                'Braking', 
                                (_userScore!['brake_score'] * 100).round(),
                              ),
                            if (_userScore!.containsKey('trip_score'))
                              _buildMobileScoreRow(
                                'Overall', 
                                (_userScore!['trip_score'] * 100).round(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Web layout
                  if (forWebLayout) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: score / 100,
                          semanticsLabel: 'Safety score',
                          strokeWidth: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getScoreColor(score.toDouble()),
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$score%',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getScoreRating(score.toDouble()),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    CircularProgressIndicator(
                      value: score / 100,
                      semanticsLabel: 'Safety score',
                    ),
                    SizedBox(height: 16),
                    Text(
                      '$score%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
                // // Additional details for web layout
                // if (showFullDetails && forWebLayout) ...[
                //   Divider(),
                //   SizedBox(height: 16),
                //   if (_userScore!['speed_consistency'] != null)
                //     _buildScoreDetailRow(
                //       'Speed Consistency', 
                //       _userScore!['speed_consistency'].toDouble()
                //     ),
                //   if (_userScore!['total_trips'] != null && _userScore!['total_distance'] != null) ...[
                //     // Calculate events per 100 miles from analytics
                //     if (_selectedUser?['analytics_data'] != null)
                //       _buildScoreDetailRow(
                //         'Events per 100 miles',
                //         100 -
                //           ((_selectedUser!['analytics_data']['events_per_100_miles'] ??
                //               _selectedUser!['analytics_data']['harsh_events_per_100_miles'] ??
                //               0) as num).toDouble().clamp(0, 100)
                //       ),
                //   ],
                  
                //   if (_userScore!.containsKey('trip_score'))
                //     _buildScoreDetailRow(
                //       'Overall Score', 
                //       (_userScore!['trip_score'] * 100).round()
                //     ),
                // ],

                // // ADD THE ENHANCED ANALYTICS DISPLAY HERE:
                // // Enhanced analytics display
                // if (_userScore != null && _userScore!['risk_level'] != null) ...[
                //   SizedBox(height: 16),
                //   Container(
                //     padding: EdgeInsets.all(12),
                //     decoration: BoxDecoration(
                //       // ignore: deprecated_member_use
                //       color: _getRiskLevelColor(_userScore!['risk_level']).withOpacity(0.1),
                //       borderRadius: BorderRadius.circular(8),
                //       border: Border.all(
                //         color: _getRiskLevelColor(_userScore!['risk_level']),
                //         width: 1,
                //       ),
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Row(
                //           children: [
                //             Icon(
                //               Icons.warning_amber_rounded,
                //               color: _getRiskLevelColor(_userScore!['risk_level']),
                //               size: 20,
                //             ),
                //             SizedBox(width: 8),
                //             Text(
                //               'Risk Level: ${_userScore!['risk_level']}',
                //               style: TextStyle(
                //                 fontWeight: FontWeight.bold,
                //                 color: _getRiskLevelColor(_userScore!['risk_level']),
                //               ),
                //             ),
                //           ],
                //         ),
                //         SizedBox(height: 8),
                //         Text('Total Trips: ${_userScore!['total_trips'] ?? 0}'),
                //         Text('Total Distance: ${_userScore!['total_distance']?.toStringAsFixed(1) ?? '0'} miles'),
                //         if (_userScore!['speed_consistency'] != null)
                //           Text('Speed Consistency: ${_userScore!['speed_consistency']?.toInt() ?? 0}%'),
                //         if (_userScore!['safe_turns_percentage'] != null)
                //           Text('Safe Turns: ${_userScore!['safe_turns_percentage']?.toInt() ?? 0}%'),
                //       ],
                //     ),
                //   ),
                // ],
                // revert to avove if below has issues
                // Additional details for web layout
                if (showFullDetails && forWebLayout) ...[
                  Divider(),
                  SizedBox(height: 16),

                  // Score components matching backend calculation
                  // Backend weights: frequency 35%, smoothness 25%, consistency 25%, turn 15%

                  // Event Frequency (35% weight) - from events per 100 miles
                  if (_userScore!['frequency_score'] != null)
                    _buildScoreDetailRow(
                      'Event Frequency (35%)',
                      (_userScore!['frequency_score'] * 100).toDouble()
                    ),

                  // Driving Smoothness (25% weight) - from acceleration/braking smoothness
                  if (_userScore!['smoothness_score'] != null)
                    _buildScoreDetailRow(
                      'Driving Smoothness (25%)',
                      (_userScore!['smoothness_score'] * 100).toDouble()
                    ),

                  // Speed Consistency (25% weight)
                  if (_userScore!['speed_consistency'] != null)
                    _buildScoreDetailRow(
                      'Speed Consistency (25%)',
                      _userScore!['speed_consistency'].toDouble()
                    ),

                  // Turn Safety (15% weight) - using turn_safety_score from backend
                  if (_userScore!['turn_safety_score'] != null)
                    _buildScoreDetailRow(
                      'Turn Safety (15%)',
                      (_userScore!['turn_safety_score']).toDouble()
                    ),

                  SizedBox(height: 16),

                  // Numerical metrics grouped together
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Statistics',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blue[900],
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildNumericStat('Total Trips', '${_userScore!['total_trips'] ?? 0}'),
                            _buildNumericStat('Total Distance', '${_userScore!['total_distance']?.toStringAsFixed(1) ?? '0'} mi'),
                            _buildNumericStat(
                              'Events/100mi', 
                              '${(_selectedUser?['analytics_data']?['events_per_100_miles'] ?? 0).toStringAsFixed(1)}'
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // Enhanced analytics display (Risk Level box)
                if (_userScore != null && _userScore!['risk_level'] != null) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getRiskLevelColor(_userScore!['risk_level']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getRiskLevelColor(_userScore!['risk_level']),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: _getRiskLevelColor(_userScore!['risk_level']),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Risk Level: ${_userScore!['risk_level']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getRiskLevelColor(_userScore!['risk_level']),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Calculation details section
                if (_userScore != null && _userScore!['calculation'] != null)
                  _buildCalculationDetails(context, _userScore!),

              ],
            ),
        ],
      ),
    ),
  );
}

Widget _buildHarshEventsCard({required bool isWeb}) {
  if (_selectedUser == null || !_selectedUser!.containsKey('analytics_data')) {
    return SizedBox.shrink();
  }
  
  var analytics = _selectedUser!['analytics_data'];
  
  return Card(
    elevation: isWeb ? 4 : 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(isWeb ? 12 : 8),
    ),
    child: Padding(
      padding: EdgeInsets.all(isWeb ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Harsh Events Summary',
            style: TextStyle(
              fontSize: isWeb ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEventCounter(
                'Sudden\nAccelerations',
                analytics['total_sudden_accelerations'] ?? 0,
                Colors.orange,
                Icons.speed,
              ),
              _buildEventCounter(
                'Sudden\nDecelerations',
                analytics['total_sudden_decelerations'] ?? 0,
                Colors.red,
                Icons.trending_down,
              ),
              _buildEventCounter(
                'Hard\nStops',
                analytics['total_hard_stops'] ?? 0,
                Colors.purple,
                Icons.stop_circle,
              ),
              _buildEventCounter(
                'Dangerous\nTurns',
                analytics['total_dangerous_turns'] ?? 0,
                Colors.deepOrange,
                Icons.rotate_right,
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Events per 100 miles: ${analytics['events_per_100_miles']?.toStringAsFixed(1) ?? '0'}',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildEventCounter(String label, int count, Color color, IconData icon) {
  return Column(
    children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 4),
      Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11),
      ),
    ],
  );
}

Widget _buildNumericStat(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[600],
        ),
      ),
      SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue[900],
        ),
      ),
    ],
  );
}

Widget _buildTripEventStat(String label, int count, Color color) {
  return Column(
    children: [
      Text(
        count.toString(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[700],
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget _buildCalculationDetails(BuildContext context, Map<String, dynamic> scoreData) {
final calculation = scoreData['calculation'] as Map<String, dynamic>? ?? {};
final allTrips = scoreData['all_trips'] as List<dynamic>? ?? [];
final hasTrips = allTrips.isNotEmpty;

return ExpansionTile(
title: Text(
'Score Calculation Details',
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
),
initiallyExpanded: false,
childrenPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
children: [
if (calculation['formula'] != null)
Padding(
padding: EdgeInsets.only(bottom: 12),
child: Text(
calculation['formula'],
style: TextStyle(fontStyle: FontStyle.italic),
),
),
if (calculation['weights'] != null) ...[
Text('Weight Distribution:', style: TextStyle(fontWeight: FontWeight.w500)),
SizedBox(height: 8),
...(calculation['weights'] as Map<String, dynamic>).entries.map((e) =>
Padding(
padding: EdgeInsets.symmetric(vertical: 4),
child: Row(
children: [
Expanded(flex: 2, child: Text(e.key.replaceAll('_', ' ').toUpperCase())),
Expanded(
flex: 3,
child: LinearProgressIndicator(
value: e.value.toDouble(),
backgroundColor: Colors.grey[200],
valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
),
),
SizedBox(width: 8),
Text('${(e.value.toDouble() * 100).round()}%'),
],
),
),
),
],
SizedBox(height: 12),
if (hasTrips) ...[
Text('Trip Data Summary (${allTrips.length} trips):', style: TextStyle(fontWeight: FontWeight.w500)),
SizedBox(height: 8),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
_buildTripStat('Total Distance',
'${allTrips.fold(0.0, (sum, trip) => sum + (trip['distance'] ?? 0.0)).toStringAsFixed(1)} miles'),
_buildTripStat('Avg. Score',
(allTrips.fold(0.0, (sum, trip) => sum + (trip['trip_score'] ?? 0.0)) / allTrips.length).toStringAsFixed(1)),
],
),
SizedBox(height: 8),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
_buildTripStat('Avg. Braking',
(allTrips.fold(0.0, (sum, trip) => sum + (trip['brake_score'] ?? 0.0)) / allTrips.length).toStringAsFixed(1)),
_buildTripStat('Avg. Acceleration',
(allTrips.fold(0.0, (sum, trip) => sum + (trip['accel_score'] ?? 0.0)) / allTrips.length).toStringAsFixed(1)),
],
),
SizedBox(height: 16),
Text('User Trips:', style: TextStyle(fontWeight: FontWeight.w500)),
SizedBox(height: 8),
...allTrips.take(3).map((trip) => _buildTripMetricCard(trip)),
if (allTrips.length > 3)
Text('+ ${allTrips.length - 3} more trips...', style: TextStyle(color: Colors.grey)),
] else
Text('No trip data available for this user', style: TextStyle(color: Colors.grey)),
],
);
}

Widget _buildTripStat(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}

Widget _buildTripMetricCard(Map<String, dynamic> trip) {
  return ExpansionTile(
    title: Text('Trip ID ${trip['trip_id']}'),
    subtitle: Text(TripService.formatTimestamp(trip['start_time'])),
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildTripMetricItem('Distance', '${trip['distance']?.toStringAsFixed(1) ?? 'N/A'} miles')),
                Expanded(child: _buildTripMetricItem('Duration', '${trip['duration']?.toStringAsFixed(1) ?? 'N/A'} min')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: _buildTripMetricItem('Avg Speed', '${trip['avg_speed']?.toStringAsFixed(1) ?? 'N/A'} mph')),
                Expanded(child: _buildTripMetricItem('Max Speed', '${trip['max_speed']?.toStringAsFixed(1) ?? 'N/A'} mph')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: _buildTripMetricItem('Score', '${trip['trip_score']?.toStringAsFixed(1) ?? 'N/A'}')),
                Expanded(child: _buildTripMetricItem('Date', TripService.formatTimestamp(trip['start_time'], dateOnly: true))),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}


Widget _buildTripMetricItem(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      Text(value, style: TextStyle(fontSize: 14)),
    ],
  );
}

Widget _buildMobileScoreRow(String label, int score) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 5, // wider bar for progress
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(score.toDouble()),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '$score%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(score.toDouble()),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget _buildScoreDetailRow(String label, double value) {
  final int roundedValue = value.round();
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(value)),
          ),
        ),
        SizedBox(width: 8),
        Text(
          '$roundedValue%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getScoreColor(value),
          ),
        ),
      ],
    ),
  );
}

Color _getScoreColor(double score) {
  if (score >= 85) return Colors.green;
  if (score >= 70) return Colors.blue[700]!;
  if (score >= 50) return Colors.orange;
  return Colors.red;
}

Color _getRiskLevelColor(String riskLevel) {
  switch (riskLevel?.toLowerCase()) {
    case 'very low risk':
    case 'low risk':
      return Colors.green;
    case 'medium risk':
      return Colors.orange;
    case 'high risk':
    case 'very high risk':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String _getScoreRating(double score) {
  if (score >= 85) return 'Excellent';
  if (score >= 70) return 'Good';
  if (score >= 50) return 'Fair';
  return 'Needs Improvement';
}

Widget _buildUserTripsCard({
  required bool isWeb,
  bool forWebLayout = false,
  bool showSortControls = true,
  double? availableHeight,
}) {
  final effectiveHeight = availableHeight ?? (isWeb ? 400.0 : 300.0);

  return Card(
    elevation: isWeb ? 4 : 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(isWeb ? 12 : 8),
    ),
    child: ExpansionTile(
      title: Text(
        'User Trips',
        style: TextStyle(
          fontSize: isWeb ? 20 : 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
        ),
      ),
      initiallyExpanded: true,
      childrenPadding: EdgeInsets.all(isWeb ? 16 : 12),
      children: [
        if (showSortControls && (isWeb || forWebLayout))
          Align(
            alignment: Alignment.centerRight,
            child: DropdownButton<String>(
              value: _tripSortOption,
              items: [
                DropdownMenuItem(value: 'recent', child: Text('Most Recent')),
                DropdownMenuItem(value: 'distance', child: Text('Longest Distance')),
              ],
              onChanged: (value) => _setTripSort(value!),
            ),
          ),
        SizedBox(height: 12),
        SizedBox(
          height: effectiveHeight - 80,
          child: _isLoadingTrips
              ? Center(child: CircularProgressIndicator())
              : _userTrips.isEmpty
                  ? Center(
                      child: Text(
                        _selectedUser == null
                            ? 'Select a user to view trips'
                            : 'No trips found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      physics: const ClampingScrollPhysics(),
                      itemCount: _userTrips.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: isWeb ? 72 : 60,
                      ),
                      itemBuilder: (context, index) {
                        final trip = _userTrips[index];
                        final startTime = trip['start_time'] != null
                            ? TripService.formatTimestamp(trip['start_time'])
                            : 'Unknown time';
                        final distance = (trip['distance'] ?? 0).toDouble();
                        final duration = (trip['duration'] ?? 0).toDouble();

                        return Column(
                          children: [
                            ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: isWeb ? 8 : 4,
                              ),
                              leading: Icon(
                                Icons.directions_car,
                                size: isWeb ? 24 : 20,
                                color: Colors.blue.shade800,
                              ),
                              title: Text(
                                startTime,
                                style: TextStyle(
                                  fontSize: isWeb ? 14 : 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start: ${_formatTimeOnly(trip['start_time'])} • End: ${_formatTimeOnly(trip['end_time'])}',
                                    style: TextStyle(
                                      fontSize: isWeb ? 11 : 10,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    '${distance.toStringAsFixed(1)} miles • ${duration.toStringAsFixed(1)} min',
                                    style: TextStyle(fontSize: isWeb ? 12 : 11),
                                  ),
                                  if (trip['behavior_score'] != null)
                                    Text(
                                      'Score: ${trip['behavior_score']?.toInt() ?? 0} | Events: ${(trip['sudden_accelerations'] ?? 0) + (trip['sudden_decelerations'] ?? 0) + (trip['hard_stops'] ?? 0) + (trip['dangerous_turns'] ?? 0)}',
                                      style: TextStyle(
                                        fontSize: isWeb ? 11 : 10,
                                        color: (trip['behavior_score'] ?? 0) >= 80
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.info_outline,
                                  size: isWeb ? 20 : 18,
                                ),
                                onPressed: () {
                                  if (trip['trip_id'] != null) {
                                    TripService.showTripDetails(context, trip);
                                  }
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  if (_selectedTrip != null && _selectedTrip!['trip_id'] == trip['trip_id']) {
                                    _selectedTrip = null;
                                  } else {
                                    _selectedTrip = trip;
                                  }
                                });
                              },
                            ),
                            
                            // EXPANDED SECTION - Shows when trip is selected
                            if (_selectedTrip != null && _selectedTrip!['trip_id'] == trip['trip_id']) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isWeb ? 16 : 8,
                                  vertical: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Harsh Events Section for this specific trip
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.orange.shade200,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Harsh Events for This Trip',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade900,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              _buildTripEventStat(
                                                'Sudden\nAccel',
                                                trip['sudden_accelerations'] ?? 0,
                                                Colors.orange,
                                              ),
                                              _buildTripEventStat(
                                                'Sudden\nDecel',
                                                trip['sudden_decelerations'] ?? 0,
                                                Colors.red,
                                              ),
                                              _buildTripEventStat(
                                                'Hard\nStops',
                                                trip['hard_stops'] ?? 0,
                                                Colors.purple,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              _buildTripEventStat(
                                                'Dangerous\nTurns',
                                                trip['dangerous_turns'] ?? 0,
                                                Colors.deepOrange,
                                              ),
                                              _buildTripEventStat(
                                                'Safe\nTurns',
                                                trip['safe_turns'] ?? 0,
                                                Colors.green,
                                              ),
                                              SizedBox(width: 60), // Spacer
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
        ),
      ],
    ),
  );
}

void _setTripSort(String sortOption) {
  setState(() {
    _tripSortOption = sortOption;
  });
  if (_searchedUserId.isNotEmpty) {
    _loadUserTrips(_searchedUserId);
  }
}

  List<dynamic> recentTrips = [];
  String errorMessage = '';
  bool isLoading = false;

// Future<void> _searchForUsers() async {
//   if (_searchQuery.isEmpty) return;
  
//   setState(() {
//     _isLoadingUsers = true;
//     _foundUsers = [];
//     _selectedUser = null;
//     _searchError = '';
//   });

//   try {
//     final results = await TripService.searchUsers(_searchQuery);
    
//     setState(() {
//       _foundUsers = results.map((user) {
//         // Create a display string that shows all available info
//         String displayInfo = '';
//         if (user['user_id'] != null) displayInfo += 'ID: ${user['user_id']} ';
//         if (user['first_name'] != null && user['last_name'] != null) {
//           displayInfo += '${user['first_name']} ${user['last_name']} ';
//         }
//         if (user['email'] != null) displayInfo += '(${user['email']})';
        
//         return {
//           'user_id': user['user_id'],
//           'name': displayInfo.trim(), // Show combined info
//           'email': user['email'] ?? 'No email',
//           'role': user['role'] ?? 'user',
//           'first_name': user['first_name'],
//           'last_name': user['last_name'],
//         };
//       }).toList();
//       _isLoadingUsers = false;
//     });
//   } catch (e) {
//     print('Search error: $e');
//     setState(() {
//       _isLoadingUsers = false;
//       _searchError = 'Search failed: ${e.toString()}';
//     });
//   }
// }
//revert to above if below has issues
Future<void> _searchForUsers() async {
  if (_searchQuery.isEmpty) return;
  
  setState(() {
    _isLoadingUsers = true;
    _foundUsers = [];
    _selectedUser = null;
    _searchError = '';
    _userScore = null;
    _userTrips = [];
  });

  try {
    // Use your analyze-driver endpoint
    final response = await http.get(
      Uri.parse('https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/analyze-driver?email=${Uri.encodeComponent(_searchQuery.trim())}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      setState(() {
        // Create user object from your backend response
        _foundUsers = [{
          'user_id': data['user_id'] ?? 'unknown',
          'name': data['user_name'] ?? data['user_email']?.split('@').first ?? 'Driver',
          'email': data['user_email'] ?? _searchQuery,
          'first_name': data['user_name']?.split(' ').first ?? '',
          'last_name': data['user_name']?.split(' ').skip(1).join(' ') ?? '',
          'role': 'driver',
          // Store the full analytics data
          'analytics_data': data
        }];
        _isLoadingUsers = false;
      });
    } else if (response.statusCode == 404) {
      setState(() {
        _searchError = 'Driver not found with email: $_searchQuery';
        _isLoadingUsers = false;
      });
    } else {
      throw Exception('Search failed');
    }
  } catch (e) {
    print('Search error: $e');
    String errorMessage = 'Search failed: ';

    // Provide specific error messages based on the error type
    if (e.toString().contains('Failed host lookup') || e.toString().contains('SocketException')) {
      errorMessage += 'Network error. Please check your internet connection.';
    } else if (e.toString().contains('TimeoutException')) {
      errorMessage += 'Request timed out. Please try again.';
    } else if (e.toString().contains('404') || e.toString().contains('Not Found')) {
      errorMessage += 'No driver found with email: $_searchQuery';
    } else if (_searchQuery.isEmpty || !_searchQuery.contains('@')) {
      errorMessage += 'Please enter a valid email address';
    } else {
      errorMessage += 'Unable to search. Please try again or contact support.';
    }

    setState(() {
      _isLoadingUsers = false;
      _searchError = errorMessage;
    });
  }
}
String _formatTimeOnly(dynamic timestamp) {
  if (timestamp == null) return 'N/A';
  try {
    final dt = DateTime.parse(timestamp.toString()).toLocal();
    return DateFormat('h:mm a').format(dt);
  } catch (e) {
    return 'N/A';
  }
}
// Update the API call methods to validate the userId parameter
Future<void> _loadUserScore(String userId) async {
  if (userId.isEmpty) {
    setState(() {
      _searchError = 'Invalid user ID';
    });
    return;
  }

  setState(() {
    _isLoadingScore = true;
    _userScore = null;
  });

  try {
    final scoreData = await TripService.getUserScore(userId);
    setState(() {
      _userScore = scoreData;
      _isLoadingScore = false;
    });
  } catch (e) {
    setState(() {
      _isLoadingScore = false;
      _searchError = 'Failed to load score: $e';
    });
  }
}

Future<void> _loadUserTrips(String userId) async {
  if (userId.isEmpty) {
    setState(() {
      _searchError = 'Invalid user ID';
    });
    return;
  }

  setState(() {
    _isLoadingTrips = true;
    _userTrips = [];
  });

  try {
    // Get trips from the already-loaded analytics data (from _searchForUsers)
    List<Map<String, dynamic>> trips = [];

    if (_foundUsers.isNotEmpty && _foundUsers[0]['analytics_data'] != null) {
      final analyticsData = _foundUsers[0]['analytics_data'];
      List<dynamic> rawTrips = analyticsData['trips'] ?? [];

      // Map trips to expected format
      trips = rawTrips.map((trip) => {
        'trip_id': trip['trip_id'],
        'start_time': trip['start_timestamp'],
        'end_time': trip['end_timestamp'],
        'distance': trip['total_distance_miles'] ?? 0,
        'duration': trip['duration_minutes'] ?? 0,
        'avg_speed': trip['avg_speed_mph'] ?? 0,
        'max_speed': trip['max_speed_mph'] ?? 0,
        'behavior_score': trip['behavior_score'] ?? 0,
        'sudden_accelerations': trip['sudden_accelerations'] ?? 0,
        'sudden_decelerations': trip['sudden_decelerations'] ?? 0,
        'hard_stops': trip['hard_stops'] ?? 0,
        'dangerous_turns': trip['dangerous_turns'] ?? 0,
        'safe_turns': trip['safe_turns'] ?? 0,
        'aggressive_turns': trip['aggressive_turns'] ?? 0,
      } as Map<String, dynamic>).toList();

      // Sort trips client-side based on _tripSortOption
      if (_tripSortOption == 'recent') {
        // Sort by end_time (most recent first)
        trips.sort((a, b) {
          try {
            final aTime = DateTime.parse(a['end_time'] ?? '');
            final bTime = DateTime.parse(b['end_time'] ?? '');
            return bTime.compareTo(aTime); // Descending (newest first)
          } catch (e) {
            return 0;
          }
        });
      } else if (_tripSortOption == 'distance') {
        // Sort by distance (longest first)
        trips.sort((a, b) {
          final aDistance = (a['distance'] ?? 0).toDouble();
          final bDistance = (b['distance'] ?? 0).toDouble();
          return bDistance.compareTo(aDistance); // Descending (longest first)
        });
      }
    } else {
      // If no analytics data, fall back to API call (shouldn't happen but safe fallback)
      trips = await TripService.getUserTrips(userId, sortBy: _tripSortOption);
    }

    setState(() {
      _userTrips = trips;
      _isLoadingTrips = false;
    });
  } catch (e) {
    setState(() {
      _isLoadingTrips = false;
      _searchError = 'Failed to load trips: $e';
    });
  }
}

// Build score trajectory chart
Widget _buildScoreTrajectoryCard({required bool isWeb}) {
  if (_selectedUser == null || _userTrips.isEmpty) {
    return SizedBox.shrink();
  }

  // Get scores from trips (most recent 10, reversed for chronological order)
  List<double> tripScores = _userTrips
      .take(10)
      .map<double>((trip) => (trip['behavior_score'] ?? 0).toDouble())
      .toList()
      .reversed
      .toList();

  if (tripScores.isEmpty) return SizedBox.shrink();

  return Card(
    elevation: isWeb ? 4 : 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(isWeb ? 12 : 8),
    ),
    child: Padding(
      padding: EdgeInsets.all(isWeb ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score Trajectory',
                style: TextStyle(
                  fontSize: isWeb ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              Text(
                'Last ${tripScores.length} trips',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 25,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= tripScores.length) return Text('');
                        return Text(
                          'T${value.toInt() + 1}',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: tripScores.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: Colors.blue.shade600,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.blue.shade800,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.shade200.withOpacity(0.5),
                          Colors.blue.shade50.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => Colors.blue.shade800,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          'Trip ${spot.x.toInt() + 1}\nScore: ${spot.y.toStringAsFixed(0)}',
                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          // Trend indicator
          _buildTrendIndicator(tripScores),
        ],
      ),
    ),
  );
}

Widget _buildTrendIndicator(List<double> scores) {
  if (scores.length < 2) return SizedBox.shrink();

  double firstHalf = scores.take(scores.length ~/ 2).fold(0.0, (a, b) => a + b) / (scores.length ~/ 2);
  double secondHalf = scores.skip(scores.length ~/ 2).fold(0.0, (a, b) => a + b) / (scores.length - scores.length ~/ 2);
  double trend = secondHalf - firstHalf;

  IconData icon;
  Color color;
  String text;

  if (trend > 3) {
    icon = Icons.trending_up;
    color = Colors.green;
    text = 'Improving (+${trend.toStringAsFixed(1)})';
  } else if (trend < -3) {
    icon = Icons.trending_down;
    color = Colors.red;
    text = 'Declining (${trend.toStringAsFixed(1)})';
  } else {
    icon = Icons.trending_flat;
    color = Colors.orange;
    text = 'Stable';
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: color, size: 20),
      SizedBox(width: 8),
      Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
    ],
  );
}

// Build comprehensive driver details card
Widget _buildDriverDetailsCard({required bool isWeb}) {
  if (_selectedUser == null || _userScore == null) {
    return SizedBox.shrink();
  }

  final analytics = _selectedUser!['analytics_data'];
  if (analytics == null) return SizedBox.shrink();

  return Card(
    elevation: isWeb ? 4 : 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(isWeb ? 12 : 8),
    ),
    child: Padding(
      padding: EdgeInsets.all(isWeb ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Driver Report',
                style: TextStyle(
                  fontSize: isWeb ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _generateDriverPDF(),
                icon: Icon(Icons.picture_as_pdf, size: 18),
                label: Text('Download PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Driver info header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade700,
                  child: Text(
                    (analytics['user_name'] ?? 'U')[0].toUpperCase(),
                    style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        analytics['user_name'] ?? 'Unknown Driver',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        analytics['user_email'] ?? '',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'User ID: ${analytics['user_id'] ?? _searchedUserId}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Statistics grid
          Text(
            'Driving Statistics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatChip(Icons.route, 'Total Distance', '${(_userScore!['total_distance'] ?? 0).toStringAsFixed(1)} mi'),
              _buildStatChip(Icons.timer, 'Driving Time', '${(_userScore!['total_driving_time'] ?? 0).toStringAsFixed(1)} hrs'),
              _buildStatChip(Icons.directions_car, 'Total Trips', '${_userScore!['total_trips'] ?? 0}'),
              _buildStatChip(Icons.straighten, 'Avg Trip Distance', '${(_userScore!['avg_trip_distance'] ?? 0).toStringAsFixed(1)} mi'),
              _buildStatChip(Icons.access_time, 'Avg Trip Duration', '${(_userScore!['avg_trip_duration'] ?? 0).toStringAsFixed(0)} min'),
              _buildStatChip(Icons.warning_amber, 'Events/100mi', '${(_userScore!['events_per_100_miles'] ?? 0).toStringAsFixed(1)}'),
            ],
          ),
          SizedBox(height: 16),

          // Last updated
          Text(
            'Report generated: ${DateFormat('MMM d, yyyy h:mm a').format(DateTime.now())}',
            style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
          ),
        ],
      ),
    ),
  );
}

Widget _buildStatChip(IconData icon, String label, String value) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.blue[700]),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ),
  );
}

Widget _buildScoreBreakdownRow(String label, double score) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: TextStyle(fontSize: 14)),
        ),
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (score / 100).clamp(0.0, 1.0),
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getScoreColor(score),
                        _getScoreColor(score).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        SizedBox(
          width: 45,
          child: Text(
            '${score.toStringAsFixed(0)}%',
            style: TextStyle(fontWeight: FontWeight.bold, color: _getScoreColor(score)),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

// Generate and download PDF report for ISP
Future<void> _generateDriverPDF() async {
  if (_selectedUser == null || _userScore == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No driver data available to export')),
    );
    return;
  }

  final analytics = _selectedUser!['analytics_data'];
  if (analytics == null) return;

  final now = DateTime.now();
  final driverName = analytics['user_name'] ?? 'Unknown';
  final safeDriverName = driverName.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
  final fileName = 'NoTrackDrive_ISP_Report_${safeDriverName}_${DateFormat('yyyy-MM-dd_HHmm').format(now)}.pdf';

  // Get trip scores for chart
  List<double> tripScores = _userTrips
      .take(10)
      .map<double>((trip) => (trip['behavior_score'] ?? 0).toDouble())
      .toList()
      .reversed
      .toList();

  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        // Header
        pw.Container(
          padding: pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue800,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('NoTrackDrive', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  pw.SizedBox(height: 4),
                  pw.Text('Insurance Provider Driver Report', style: pw.TextStyle(fontSize: 14, color: PdfColors.white)),
                ],
              ),
              pw.Text('Confidential', style: pw.TextStyle(fontSize: 12, color: PdfColors.white, fontStyle: pw.FontStyle.italic)),
            ],
          ),
        ),
        pw.SizedBox(height: 20),

        // Driver info
        pw.Container(
          padding: pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue200),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Driver: $driverName', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Email: ${analytics['user_email'] ?? 'N/A'}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                  pw.Text('User ID: ${analytics['user_id'] ?? _searchedUserId}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                ],
              ),
              pw.Spacer(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Generated: ${DateFormat('MMMM d, yyyy').format(now)}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                  pw.Text('Time: ${DateFormat('h:mm a').format(now)}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 24),

        // Overall Score Box
        pw.Container(
          padding: pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue, width: 2),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Column(
                children: [
                  pw.Text('OVERALL SAFETY SCORE', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                  pw.SizedBox(height: 8),
                  pw.Text('${(_userScore!['score'] ?? 0).toInt()}', style: pw.TextStyle(fontSize: 48, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                  pw.Text('out of 100', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: _getPdfRiskColor(_userScore!['risk_level']),
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Text(_userScore!['risk_level'] ?? 'Unknown', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 24),

        // Statistics Section
        pw.Text('Driving Statistics', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
        pw.Divider(color: PdfColors.blue200),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _buildPdfStatBox('Total Trips', '${_userScore!['total_trips'] ?? 0}'),
            _buildPdfStatBox('Total Distance', '${(_userScore!['total_distance'] ?? 0).toStringAsFixed(1)} mi'),
            _buildPdfStatBox('Driving Time', '${(_userScore!['total_driving_time'] ?? 0).toStringAsFixed(1)} hrs'),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _buildPdfStatBox('Avg Trip Distance', '${(_userScore!['avg_trip_distance'] ?? 0).toStringAsFixed(1)} mi'),
            _buildPdfStatBox('Avg Trip Duration', '${(_userScore!['avg_trip_duration'] ?? 0).toStringAsFixed(0)} min'),
            _buildPdfStatBox('Events/100mi', '${(_userScore!['events_per_100_miles'] ?? 0).toStringAsFixed(1)}'),
          ],
        ),
        pw.SizedBox(height: 24),

        // Score Breakdown (matching backend calculation weights)
        pw.Text('Score Breakdown', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
        pw.Divider(color: PdfColors.blue200),
        pw.SizedBox(height: 8),
        _buildPdfScoreRow('Event Frequency (35%)', ((_userScore!['frequency_score'] ?? 0.85) * 100).toDouble()),
        _buildPdfScoreRow('Driving Smoothness (25%)', ((_userScore!['smoothness_score'] ?? 0.85) * 100).toDouble()),
        _buildPdfScoreRow('Speed Consistency (25%)', (_userScore!['speed_consistency'] ?? 0).toDouble()),
        _buildPdfScoreRow('Turn Safety (15%)', (_userScore!['turn_safety_score'] ?? 85).toDouble()),
        pw.SizedBox(height: 24),

        // Score Trajectory
        if (tripScores.isNotEmpty) ...[
          pw.Text('Score Trajectory (Last ${tripScores.length} Trips)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
          pw.Divider(color: PdfColors.blue200),
          pw.SizedBox(height: 8),
          _buildPdfScoreChart(tripScores, pdf),
          pw.SizedBox(height: 24),
        ],

        // Harsh Events Summary
        pw.Text('Harsh Events Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
        pw.Divider(color: PdfColors.blue200),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _buildPdfEventBox('Sudden Accelerations', analytics['total_sudden_accelerations'] ?? 0),
            _buildPdfEventBox('Sudden Decelerations', analytics['total_sudden_decelerations'] ?? 0),
            _buildPdfEventBox('Hard Stops', analytics['total_hard_stops'] ?? 0),
            _buildPdfEventBox('Dangerous Turns', analytics['total_dangerous_turns'] ?? 0),
          ],
        ),
        pw.SizedBox(height: 24),

        // Recent Trips Table
        if (_userTrips.isNotEmpty) ...[
          pw.Text('Recent Trips', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
          pw.Divider(color: PdfColors.blue200),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
            cellStyle: pw.TextStyle(fontSize: 10),
            cellPadding: pw.EdgeInsets.all(6),
            headers: ['Date', 'Distance', 'Duration', 'Score'],
            data: _userTrips.take(10).map((trip) {
              String dateStr = trip['end_time'] ?? '';
              String formattedDate = 'N/A';
              if (dateStr.isNotEmpty) {
                try {
                  DateTime date = DateTime.parse(dateStr).toLocal();
                  formattedDate = DateFormat('MMM d, yyyy').format(date);
                } catch (e) {}
              }
              return [
                formattedDate,
                '${(trip['distance'] ?? 0).toStringAsFixed(1)} mi',
                '${(trip['duration'] ?? 0).toStringAsFixed(0)} min',
                '${(trip['behavior_score'] ?? 0).toStringAsFixed(0)}',
              ];
            }).toList(),
          ),
        ],

        pw.SizedBox(height: 30),
        pw.Center(
          child: pw.Text(
            'Generated by NoTrackDrive Insurance Portal',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500, fontStyle: pw.FontStyle.italic),
          ),
        ),
      ],
    ),
  );

  final pdfBytes = await pdf.save();
  await savePdfFile(pdfBytes, fileName);

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF report downloaded: $fileName'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

pw.Widget _buildPdfStatBox(String label, String value) {
  return pw.Container(
    padding: pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );
}

pw.Widget _buildPdfScoreRow(String label, double score) {
  return pw.Container(
    margin: pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Text(label, style: pw.TextStyle(fontSize: 11)),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Stack(
            children: [
              pw.Container(
                height: 16,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
              ),
              pw.Container(
                height: 16,
                width: (score / 100).clamp(0.0, 1.0) * 200,
                decoration: pw.BoxDecoration(
                  color: _getPdfScoreColor(score),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Text('${score.toStringAsFixed(0)}%', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );
}

pw.Widget _buildPdfEventBox(String label, int count) {
  return pw.Container(
    padding: pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Text('$count', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
        pw.SizedBox(height: 4),
        pw.Text(label, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600), textAlign: pw.TextAlign.center),
      ],
    ),
  );
}

pw.Widget _buildPdfScoreChart(List<double> scoreData, pw.Document pdfDoc) {
  if (scoreData.isEmpty) {
    return pw.Text('No data available', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500));
  }

  const double chartWidth = 450;
  const double chartHeight = 100;
  const double leftMargin = 30;
  const double bottomMargin = 20;
  const double topMargin = 10;

  final helveticaFont = PdfFont.helvetica(pdfDoc.document);

  return pw.Container(
    height: chartHeight + bottomMargin + topMargin,
    width: chartWidth + leftMargin,
    child: pw.CustomPaint(
      size: PdfPoint(chartWidth + leftMargin, chartHeight + bottomMargin + topMargin),
      painter: (PdfGraphics canvas, PdfPoint size) {
        final double graphWidth = chartWidth - 10;
        final double graphHeight = chartHeight;

        // Draw Y-axis labels and grid lines
        for (int i = 0; i <= 4; i++) {
          final double y = topMargin + graphHeight - (i * graphHeight / 4);
          final int label = i * 25;

          canvas
            ..setColor(PdfColors.grey300)
            ..drawLine(leftMargin, y, leftMargin + graphWidth, y)
            ..strokePath();

          canvas
            ..setColor(PdfColors.grey700)
            ..drawString(helveticaFont, 8, '$label', leftMargin - 22, y - 3);
        }

        if (scoreData.length > 1) {
          final double xStep = graphWidth / (scoreData.length - 1);

          canvas.setColor(PdfColors.blue);
          for (int i = 0; i < scoreData.length - 1; i++) {
            final double x1 = leftMargin + i * xStep;
            final double y1 = topMargin + graphHeight - (scoreData[i].clamp(0, 100) / 100 * graphHeight);
            final double x2 = leftMargin + (i + 1) * xStep;
            final double y2 = topMargin + graphHeight - (scoreData[i + 1].clamp(0, 100) / 100 * graphHeight);

            canvas
              ..setLineWidth(2)
              ..drawLine(x1, y1, x2, y2)
              ..strokePath();
          }

          for (int i = 0; i < scoreData.length; i++) {
            final double x = leftMargin + i * xStep;
            final double y = topMargin + graphHeight - (scoreData[i].clamp(0, 100) / 100 * graphHeight);

            canvas
              ..setColor(PdfColors.blue800)
              ..drawEllipse(x, y, 3, 3)
              ..fillPath();

            canvas
              ..setColor(PdfColors.grey600)
              ..drawString(helveticaFont, 7, 'T${i + 1}', x - 4, topMargin + graphHeight + 6);
          }
        } else if (scoreData.length == 1) {
          final double x = leftMargin + graphWidth / 2;
          final double y = topMargin + graphHeight - (scoreData[0].clamp(0, 100) / 100 * graphHeight);

          canvas
            ..setColor(PdfColors.blue800)
            ..drawEllipse(x, y, 4, 4)
            ..fillPath();
        }
      },
    ),
  );
}

PdfColor _getPdfScoreColor(double score) {
  if (score >= 80) return PdfColors.green;
  if (score >= 60) return PdfColors.lightGreen;
  if (score >= 40) return PdfColors.orange;
  return PdfColors.red;
}

PdfColor _getPdfRiskColor(String? riskLevel) {
  switch (riskLevel?.toLowerCase()) {
    case 'low':
      return PdfColors.green;
    case 'moderate':
      return PdfColors.orange;
    case 'high':
      return PdfColors.red;
    default:
      return PdfColors.grey;
  }
}
}