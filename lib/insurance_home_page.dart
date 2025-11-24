import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'trip_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';  // ADD THIS LINE


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
            _buildHarshEventsCard(isWeb: true),  // ADD THIS
            SizedBox(height: 24),
            _buildUserTripsCard(isWeb: true, forWebLayout: true, availableHeight: constraints.maxHeight * 0.4),
          ],
        ),
      ),
      SizedBox(width: 24),
      Expanded(
        flex: 1,
        child: _buildUserScoreCard(isWeb: true, forWebLayout: true),
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
      _buildHarshEventsCard(isWeb: isWeb),  // ADD THIS
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
      
      // Set the score data
      _userScore = {
        'score': analytics['overall_behavior_score'] ?? 0,
        'behavior_score': analytics['overall_behavior_score'] ?? 0,
        'accel_score': (analytics['avg_gentle_acceleration_score'] ?? 0) / 100,
        'brake_score': (analytics['avg_acceleration_consistency'] ?? 0) / 100,
        'trip_score': (analytics['overall_behavior_score'] ?? 0) / 100,
        'speed_consistency': analytics['speed_consistency_score'] ?? 0,
        'turn_quality': analytics['avg_turn_speed_score'] ?? 0,
        'safe_turns_percentage': analytics['safe_turns_percentage'] ?? 0,
        'risk_level': analytics['risk_level'] ?? 'Unknown',
        'total_trips': analytics['total_trips'] ?? 0,
        'total_distance': analytics['total_distance_miles'] ?? 0,
        'updated_at': analytics['analysis_timestamp'] ?? DateTime.now().toIso8601String(),
      };
      // In _selectUser, after setting _userScore, ADD:
      // Extract total harsh events from analytics
      if (analytics.containsKey('total_harsh_events')) {
        analytics['total_sudden_accelerations'] = analytics['total_harsh_events'];
      }
      // These should already be in the data, but ensure they're available
      analytics['total_sudden_accelerations'] = analytics['total_sudden_accelerations'] ?? 
        (analytics['trips'] as List?)?.fold<int>(0, (sum, trip) => sum + ((trip['sudden_accelerations'] ?? 0) as int)) ?? 0;
        
      analytics['total_sudden_decelerations'] = analytics['total_sudden_decelerations'] ?? 
        (analytics['trips'] as List?)?.fold(0, (sum, trip) => sum + ((trip['sudden_decelerations'] ?? 0) as int)) ?? 0;
        
      analytics['total_hard_stops'] = analytics['total_hard_stops'] ?? 
        (analytics['trips'] as List?)?.fold(0, (sum, trip) => sum + ((trip['hard_stops'] ?? 0) as int)) ?? 0;
        
      analytics['total_dangerous_turns'] = analytics['total_dangerous_turns'] ?? 
        (analytics['trips'] as List?)?.fold(0, (sum, trip) => sum + ((trip['dangerous_turns'] ?? 0) as int)) ?? 0;
      
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
                  
                  // Speed Consistency with % bar
                  if (_userScore!['speed_consistency'] != null)
                    _buildScoreDetailRow(
                      'Speed Consistency', 
                      _userScore!['speed_consistency'].toDouble()
                    ),
                  
                  // Safe Turns % with blue bar
                  if (_userScore!['safe_turns_percentage'] != null)
                    _buildScoreDetailRow(
                      'Safe Turns', 
                      _userScore!['safe_turns_percentage'].toDouble()
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

                SizedBox(height: 8),
                if (_userScore!.containsKey('updated_at'))
                  Text(
                    'Last updated: ${TripService.formatTimestamp(_userScore!['updated_at'])}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isWeb ? 14 : 12,
                    ),
                  ),

                // Calculation details section - added here (KEEP THIS)
                if (_userScore != null && _userScore!['calculation'] != null)
                  _buildCalculationDetails(context, _userScore!),

                SizedBox(height: 8),
                if (_userScore!.containsKey('updated_at'))
                  Text(
                    'Last updated: ${TripService.formatTimestamp(_userScore!['updated_at'])}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isWeb ? 14 : 12,
                    ),
                  ),
                

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
            value: value,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(value)),
          ),
        ),
        SizedBox(width: 8),
        Text(
          '$value%',
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
}