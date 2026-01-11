import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'dart:convert';
import 'custom_app_bar.dart';
import 'current_trip_page.dart';
import 'graph_Score_Page.dart';
import 'trip_helper.dart';
import 'ipconfig.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import 'data_manager.dart'; // Add this import


class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  _ScorePage createState() => _ScorePage();
}

class _ScorePage extends State<ScorePage> {
  int score = 0;
  int _selectedIndex = 2;
  late String role;
  bool isLoading = true;

  final String server = AppConfig.server;

  // Enhanced report data
  int totalTrips = 0;
  double totalDurationMinutes = 0.0;
  double totalDistanceMiles = 0.0;
  List<Map<String, dynamic>> tripHistory = [];  // For historical data
  String userName = '';

  // Used for graph
  List<double> scores = [];     // Will hold users all previous trip scores
  List<String> dates = [];      // Currently unfunctional, will hold all dates for corresponding scores



  Map<String, String> breakdown = {};   // Map receiving from backend. Key is the name of the habit, value is the severity

  // Initialize states, load users info, and load trip data gor graph
 @override
  void initState() {
    super.initState();
    _loadUserInfo();
    loadTripData();
  }

  // Loads the type of user (user, admin, service provider)
  // Future<void> _loadUserInfo() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   role = prefs.getString('role')!;

  //   final token = prefs.getString('access_token');

  //   final responseScore = await http.get(
  //     Uri.parse('$server/score'), 
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //   );


  //   // TODO Replace breakdown with correct names in database
  //   if (responseScore.statusCode == 200) {
  //       final data = json.decode(responseScore.body);
  //       setState(() {
  //         isLoading = false;

  //           final rawScore = data['totalScore'] ?? 0.0;
  //           final roundedScore = double.parse(rawScore.toStringAsFixed(2));

  //           score = (roundedScore * 100).toInt();
  //         print('User Score : $score');
  //         breakdown = {
  //           "Braking": _ratingLabel(data['braking']),
  //           "Acceleration": _ratingLabel(data['acceleration']),
  //         };
  //       });
  //     } else {
  //       print('Failed to load score');
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }


  //   final responsePrevTrips = await http.get(
  //       Uri.parse('$server/previoustrips'), 
  //       headers: {
  //           'Authorization': 'Bearer $token',
  //           'Content-Type': 'application/json',
  //       }
  //   );

  //   if (responsePrevTrips.statusCode == 200) {
  //       final data = json.decode(responsePrevTrips.body);
  //       //TODO 
  //   }
  // }
  // revert to above function if below function causes issues
  // Future<void> _loadUserInfo() async {
  //   if (!mounted) return;  // ADD THIS LINE
    
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   role = prefs.getString('role')!;
    
  //   // Get user data to extract email
  //   String? userDataJson = prefs.getString('user_data');
  //   if (userDataJson == null) {
  //     if (mounted) setState(() => isLoading = false);  // ADD mounted check
  //     return;
  //   }
    
  //   Map<String, dynamic> userData = json.decode(userDataJson);
  //   String userEmail = userData['email'] ?? '';
    
  //   if (userEmail.isEmpty) {
  //     print('No email found for user');
  //     if (mounted) setState(() => isLoading = false);  // ADD mounted check
  //     return;
  //   }
    
  //   try {
  //     // Call your analyze-driver endpoint with email
  //     final response = await http.get(
  //       Uri.parse('https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/analyze-driver?email=$userEmail'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );
      
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
        
  //       if (mounted) {  // ADD mounted check
  //         setState(() {
  //           isLoading = false;
            
  //           // Extract overall behavior score
  //           double behaviorScore = (data['overall_behavior_score'] ?? 0).toDouble();
  //           score = behaviorScore.toInt();
            
  //           print('User Score: $score');
            
  //           // Extract breakdown metrics from your backend
  //           breakdown = {
  //             "Speed Consistency": _ratingLabel((data['speed_consistency_score'] ?? 0) / 100),
  //             "Acceleration": _ratingLabel((data['avg_gentle_acceleration_score'] ?? 0) / 100),
  //             "Turn Quality": _ratingLabel((data['avg_turn_speed_score'] ?? 0) / 100),
  //             "Safe Turns": _ratingLabel((data['safe_turns_percentage'] ?? 0) / 100),
  //           };
            
  //           // Extract trip scores for the graph
  //           if (data['trips'] != null && data['trips'] is List) {
  //             List<dynamic> tripsList = data['trips'];
  //             scores = tripsList.map((trip) {
  //               // Get behavior score from each trip
  //               double tripScore = (trip['behavior_score'] ?? 0).toDouble();
  //               return tripScore;
  //             }).toList();
              
  //             // Also extract dates for the graph if needed
  //             dates = tripsList.map((trip) {
  //               // Format the date from timestamp
  //               String timestamp = trip['start_timestamp'] ?? '';
  //               return timestamp; // You may want to format this
  //             }).toList();
  //           }
  //         });
  //       }
  //     } else {
  //       print('Failed to load score: ${response.statusCode}');
  //       print('Response: ${response.body}');
  //       if (mounted) setState(() => isLoading = false);  // ADD mounted check
  //     }
  //   } catch (error) {
  //     print('Error loading score: $error');
  //     if (mounted) setState(() => isLoading = false);  // ADD mounted check
  //   }
  // }
  // Revert to above function if below function causes issues
  Future<void> _loadUserInfo() async {
    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role')!;

    // Get user name
    String? userDataJson = prefs.getString('user_data');
    if (userDataJson != null) {
      Map<String, dynamic> userData = json.decode(userDataJson);
      userName = userData['name'] ?? '';
    }

    try {
      Map<String, dynamic>? data = await DataManager.getDriverAnalytics();

      if (data != null && mounted) {
        setState(() {
          isLoading = false;

          double behaviorScore = (data['overall_behavior_score'] ?? 0).toDouble();
          score = behaviorScore.toInt();

          breakdown = {
            "Speed Consistency": _ratingLabel((data['speed_consistency_score'] ?? 0) / 100),
            "Acceleration": _ratingLabel((data['avg_gentle_acceleration_score'] ?? 0) / 100),
            "Turn Quality": _ratingLabel((data['avg_turn_speed_score'] ?? 0) / 100),
            "Braking": _ratingLabel((data['avg_acceleration_consistency'] ?? 0) / 100),
          };

          if (data['trips'] != null && data['trips'] is List) {
            List<dynamic> tripsList = data['trips'];
            scores = tripsList.map((trip) {
              double tripScore = (trip['behavior_score'] ?? 0).toDouble();
              return tripScore;
            }).toList();

            // Populate enhanced report data
            totalTrips = tripsList.length;

            // Calculate total duration and distance
            totalDurationMinutes = 0.0;
            totalDistanceMiles = 0.0;
            tripHistory = [];

            for (var trip in tripsList) {
              totalDurationMinutes += (trip['duration_minutes'] ?? 0.0).toDouble();
              totalDistanceMiles += (trip['total_distance_miles'] ?? 0.0).toDouble();

              // Store trip history for the report
              tripHistory.add({
                'date': trip['start_timestamp'] ?? '',
                'score': (trip['behavior_score'] ?? 0).toDouble(),
                'distance': (trip['total_distance_miles'] ?? 0.0).toDouble(),
                'duration': (trip['duration_minutes'] ?? 0.0).toDouble(),
              });
            }

            // Also extract dates for the graph
            dates = tripsList.map((trip) {
              String timestamp = trip['start_timestamp'] ?? '';
              return timestamp;
            }).toList();
          }
        });
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (error) {
      print('Error loading score: $error');
      if (mounted) setState(() => isLoading = false);
    }
  }


  // loads a users scores and corresponding dates of a trip for graph
  Future<void> loadTripData() async {
  try {
    List<TripData> trips = await getPrevTripData();
    setState(() {
      scores = trips.map((t) => t.score).toList();
      dates = trips.map((t) => t.date).toList();
      isLoading = false;
    });
  } catch (e) {
    // handle error, show fallback UI or message
    setState(() {
      isLoading = false;
    });
  }
}


  // Will return different ratings depending on what final / metric score is given
  String _ratingLabel(num? value) {
    if (value == null) return "Unknown";

    final double val = value.toDouble();

    if (val >= 0.90) return "Excellent";
    if (val >= 0.70) return "Good";
    if (val >= 0.50) return "Average";
    return "Needs Improvement";
  }


@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Your Score',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.blue.shade700,
      elevation: 0,
    ),
    // If user doesn't have a score (error) direct them to start a trip
    body: isLoading
      ? const Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          onRefresh: () async {
            await DataManager.getDriverAnalytics(forceRefresh: true);
            await _loadUserInfo();
            await loadTripData();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Score display
              if (score > 0) ...[
                CircularPercentIndicator(
                  radius: screenHeight * .1,
                  lineWidth: 12.0,
                  percent: score / 100,
                  center: Text(
                    "$score%",
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  progressColor: scoreColor(score),
                  backgroundColor: Colors.grey[300]!,
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 1000,
                ),
                const SizedBox(height: 20),
                Text(
                  'Your Current Score: $score%',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ] else ...[
                // Show loading or no data message
                Text(
                  'Loading score...',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
                    const SizedBox(height: 30),
                    // Graph
                    // MiniScoreGraph(
                    //   scores: convertScore(scores),   // Converts scores from 0-1 to 0-100 
                    //   height: screenHeight *.22,      // makes heigh of graph dynamic to size of screen
                    //   dates: dates
                    // ),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      // Score Breakdown Container
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Score Breakdown",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...breakdown.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                  Text(
                                    entry.value,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                _showFullReportModal(context);    // Method to expand description of individual driving habits
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.lightBlueAccent,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: const Text("View Full Report"),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),  // Add this closing parenthesis for RefreshIndicator
    bottomNavigationBar: isLoading
        ? null
        // Creates bottom nav bar (role dependent)
        : CustomAppBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            role: role,
          ).buildBottomNavBar(context),
  );
}

// Method to build View Full Report with enhanced details, PDF download, and email sharing
void _showFullReportModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    isScrollControlled: true,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: ListView(
              controller: scrollController,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Full Driving Report",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  userName.isNotEmpty ? userName : 'Driver',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Generated on ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Overall Score Card (like credit score)
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [scoreColor(score), scoreColor(score).withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: scoreColor(score).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Safety Score',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '$score',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getScoreLabel(score),
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Summary Statistics
                Text(
                  'Summary Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.route,
                      label: 'Total Trips',
                      value: '$totalTrips',
                      color: Colors.blue,
                    ),
                    SizedBox(width: 12),
                    _buildStatCard(
                      icon: Icons.timer,
                      label: 'Total Time',
                      value: _formatDuration(totalDurationMinutes),
                      color: Colors.orange,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.speed,
                      label: 'Total Distance',
                      value: '${totalDistanceMiles.toStringAsFixed(1)} mi',
                      color: Colors.green,
                    ),
                    SizedBox(width: 12),
                    _buildStatCard(
                      icon: Icons.trending_up,
                      label: 'Avg Score',
                      value: scores.isNotEmpty
                          ? '${(scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(0)}'
                          : 'N/A',
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Score Breakdown
                Text(
                  'Driving Habits Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...breakdown.entries.map(
                  (entry) => Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getHabitIcon(entry.key),
                          color: _ratingColor(entry.value),
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                _getHabitDescription(entry.key),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _ratingColor(entry.value).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _ratingColor(entry.value),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Score Trajectory (Last 6-12 months)
                if (tripHistory.isNotEmpty) ...[
                  Text(
                    'Score Trajectory',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your driving scores over the past ${_getTimeframeLabel()}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 12),
                  Container(
                    height: 150,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: _buildScoreTrajectory(),
                  ),
                  SizedBox(height: 8),
                  _buildTrendIndicator(),
                  const SizedBox(height: 24),
                ],

                // Recent Trips Table
                if (tripHistory.isNotEmpty) ...[
                  Text(
                    'Recent Trip Scores',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  ...tripHistory.take(5).map((trip) {
                    String dateStr = trip['date'] ?? '';
                    String formattedDate = 'N/A';
                    if (dateStr.isNotEmpty) {
                      try {
                        DateTime date = DateTime.parse(dateStr).toLocal();
                        formattedDate = DateFormat('MMM d, yyyy').format(date);
                      } catch (e) {
                        formattedDate = 'N/A';
                      }
                    }
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Text(formattedDate, style: TextStyle(fontWeight: FontWeight.w500)),
                          Spacer(),
                          Text(
                            '${trip['distance'].toStringAsFixed(1)} mi',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(width: 16),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: scoreColor(trip['score'].toInt()).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${trip['score'].toInt()}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: scoreColor(trip['score'].toInt()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _generateAndSharePDF(context),
                        icon: Icon(Icons.picture_as_pdf),
                        label: Text('Download PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showEmailDialog(context),
                        icon: Icon(Icons.email),
                        label: Text('Email Report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: const Text("Close"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
}

// Helper function to build stat cards
Widget _buildStatCard({
  required IconData icon,
  required String label,
  required String value,
  required Color color,
}) {
  return Expanded(
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    ),
  );
}

String _formatDuration(double minutes) {
  if (minutes < 60) {
    return '${minutes.toInt()} min';
  } else {
    int hours = (minutes / 60).floor();
    int mins = (minutes % 60).round();
    return mins > 0 ? '$hours hr $mins min' : '$hours hr';
  }
}

String _getScoreLabel(int score) {
  if (score >= 90) return 'Excellent Driver';
  if (score >= 80) return 'Great Driver';
  if (score >= 70) return 'Good Driver';
  if (score >= 60) return 'Average Driver';
  return 'Needs Improvement';
}

IconData _getHabitIcon(String habit) {
  switch (habit.toLowerCase()) {
    case 'speed consistency':
      return Icons.speed;
    case 'acceleration':
      return Icons.trending_up;
    case 'turn quality':
      return Icons.turn_right;
    case 'braking':
      return Icons.pan_tool;
    default:
      return Icons.check_circle;
  }
}

String _getHabitDescription(String habit) {
  switch (habit.toLowerCase()) {
    case 'speed consistency':
      return 'How steady you maintain speed';
    case 'acceleration':
      return 'Smoothness of your acceleration';
    case 'turn quality':
      return 'Safe speed during turns';
    case 'braking':
      return 'Gradual and safe braking';
    default:
      return '';
  }
}

String _getTimeframeLabel() {
  if (tripHistory.length <= 10) return 'recent trips';
  if (tripHistory.length <= 30) return 'past month';
  if (tripHistory.length <= 90) return 'past 3 months';
  return 'past 6-12 months';
}

Widget _buildScoreTrajectory() {
  // Simple line chart representation
  if (scores.isEmpty) return Center(child: Text('No data available'));

  List<double> recentScores = scores.take(10).toList().reversed.toList();

  return CustomPaint(
    painter: ScoreTrajectoryPainter(recentScores),
    size: Size.infinite,
  );
}

Widget _buildTrendIndicator() {
  if (scores.length < 2) return SizedBox.shrink();

  // Compare recent scores to older scores
  List<double> recent = scores.take(5).toList();
  List<double> older = scores.skip(5).take(5).toList();

  if (older.isEmpty) return SizedBox.shrink();

  double recentAvg = recent.reduce((a, b) => a + b) / recent.length;
  double olderAvg = older.reduce((a, b) => a + b) / older.length;
  double diff = recentAvg - olderAvg;

  IconData icon;
  Color color;
  String message;

  if (diff > 5) {
    icon = Icons.trending_up;
    color = Colors.green;
    message = 'Your driving is improving! Keep it up.';
  } else if (diff < -5) {
    icon = Icons.trending_down;
    color = Colors.orange;
    message = 'Your score has dipped. Focus on smooth driving.';
  } else {
    icon = Icons.trending_flat;
    color = Colors.blue;
    message = 'Your driving is consistent. Great job!';
  }

  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(icon, color: color),
        SizedBox(width: 8),
        Expanded(
          child: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        ),
      ],
    ),
  );
}

Future<void> _generateAndSharePDF(BuildContext context) async {
  try {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Driving Safety Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Paragraph(text: 'Driver: ${userName.isNotEmpty ? userName : "N/A"}'),
            pw.Paragraph(text: 'Generated: ${DateFormat('MMM d, yyyy').format(DateTime.now())}'),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Header(level: 1, child: pw.Text('Overall Score: $score')),
            pw.Paragraph(text: _getScoreLabel(score)),
            pw.SizedBox(height: 20),
            pw.Header(level: 1, child: pw.Text('Summary Statistics')),
            pw.Bullet(text: 'Total Trips: $totalTrips'),
            pw.Bullet(text: 'Total Distance: ${totalDistanceMiles.toStringAsFixed(1)} miles'),
            pw.Bullet(text: 'Total Duration: ${_formatDuration(totalDurationMinutes)}'),
            pw.Bullet(text: 'Average Score: ${scores.isNotEmpty ? (scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(0) : "N/A"}'),
            pw.SizedBox(height: 20),
            pw.Header(level: 1, child: pw.Text('Driving Habits Breakdown')),
            ...breakdown.entries.map((e) => pw.Bullet(text: '${e.key}: ${e.value}')),
            pw.SizedBox(height: 20),
            if (tripHistory.isNotEmpty) ...[
              pw.Header(level: 1, child: pw.Text('Recent Trip Scores')),
              pw.Table.fromTextArray(
                headers: ['Date', 'Distance', 'Duration', 'Score'],
                data: tripHistory.take(10).map((trip) {
                  String dateStr = trip['date'] ?? '';
                  String formattedDate = 'N/A';
                  if (dateStr.isNotEmpty) {
                    try {
                      DateTime date = DateTime.parse(dateStr).toLocal();
                      formattedDate = DateFormat('MMM d, yyyy').format(date);
                    } catch (e) {}
                  }
                  return [
                    formattedDate,
                    '${trip['distance'].toStringAsFixed(1)} mi',
                    '${trip['duration'].toStringAsFixed(0)} min',
                    '${trip['score'].toInt()}',
                  ];
                }).toList(),
              ),
            ],
            pw.SizedBox(height: 30),
            pw.Paragraph(
              text: 'This report was generated by DriveGuard. For questions, contact support.',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/driving_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'My Driving Safety Report',
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generating PDF: $e')),
    );
  }
}

void _showEmailDialog(BuildContext context) {
  final emailController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Email Report'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Enter the email address to send this report to:'),
          SizedBox(height: 16),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await _sendEmailReport(context, emailController.text);
          },
          child: Text('Send'),
        ),
      ],
    ),
  );
}

Future<void> _sendEmailReport(BuildContext context, String email) async {
  if (email.isEmpty || !email.contains('@')) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter a valid email address')),
    );
    return;
  }

  try {
    // Generate summary text for email
    String body = '''
Driving Safety Report

Driver: ${userName.isNotEmpty ? userName : "N/A"}
Date: ${DateFormat('MMM d, yyyy').format(DateTime.now())}

OVERALL SCORE: $score (${_getScoreLabel(score)})

SUMMARY:
- Total Trips: $totalTrips
- Total Distance: ${totalDistanceMiles.toStringAsFixed(1)} miles
- Total Duration: ${_formatDuration(totalDurationMinutes)}
- Average Score: ${scores.isNotEmpty ? (scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(0) : "N/A"}

DRIVING HABITS:
${breakdown.entries.map((e) => '- ${e.key}: ${e.value}').join('\n')}

This report was generated by DriveGuard.
''';

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Driving Safety Report - ${DateFormat('MMM d, yyyy').format(DateTime.now())}&body=${Uri.encodeComponent(body)}',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open email app')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error sending email: $e')),
    );
  }
}

  // Builds a page that directs user to start a trip if they have no trips recorded
  Widget _buildNoTripsYet(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No trips recorded yet",
            style: TextStyle(
              fontSize: 18, 
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.blue[800],
            ),
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CurrentTripPage()),
              );
            },
            child: const Text("Start a new trip"),
          ),
        ],
      ),
    );
  }





  // Changes page depedning on what icon you click on bottom nav bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Creates color for score circle
  Color scoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }


  // Used in View Full Report. Makes words correspond to colors
  Color _ratingColor(String rating) {
    switch (rating.toLowerCase()) {
      case "excellent":
        return Colors.green;
      case "good":
        return Colors.orange;
      case "average":
        return Colors.amber;
      case "needs improvement":
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  List<double> convertScore(List<double> scores) {
    return scores.map((score) => score * 100).toList();
  }

  // Gets all trips scores and dates they were done on and puts it in a list to be used by the graph
  Future<List<TripData>> getPrevTripData () async {
    

    List<TripData> dateScoreList = [];    // list of all scores dates and associated scores
    
    List<Map<String, dynamic>> prevTripList = await TripService.fetchPreviousTripsData();   // list for previous trip structs
    
    // counter for testing
    int counter = 0;

    for (var prevTrip in prevTripList){
      counter++;
      // gets each scores score and start time
      double? score = prevTrip['trip_score'];
      String? date = prevTrip['start_time'];

      // used for testing date and score
      print("$counter) score: $score    date: $date");
      
      // If score and date are not null, add them to list
      //
      // update to use actual date
      if (/*date != null &&*/ score != null) { 
        dateScoreList.add(TripData(date: "date", score: score));
      }
        
    }

    print("Dates and Scores: ${dateScoreList.toList()}");

    
    if (dateScoreList.isNotEmpty){
      return dateScoreList;
    }

    else {
      throw Exception('No valid trip data found.');
    }
      
  }
  

}

// Class to hold date and score to display on graph
class TripData {
  final String date;
  final double score;

  TripData({required this.date, required this.score});
}

// Custom painter for score trajectory visualization
class ScoreTrajectoryPainter extends CustomPainter {
  final List<double> scoreData;
  ScoreTrajectoryPainter(this.scoreData);

  @override
  void paint(Canvas canvas, Size size) {
    if (scoreData.isEmpty) return;

    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final path = Path();
    final double xStep = size.width / (scoreData.length - 1).clamp(1, scoreData.length);
    final double minScore = scoreData.reduce((a, b) => a < b ? a : b);
    final double maxScore = scoreData.reduce((a, b) => a > b ? a : b);
    final double range = (maxScore - minScore).clamp(1, 100);

    for (int i = 0; i < scoreData.length; i++) {
      final x = i * xStep;
      final y = size.height - ((scoreData[i] - minScore) / range) * size.height * 0.8 - size.height * 0.1;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
