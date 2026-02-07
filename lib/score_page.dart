import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'dart:convert';
import 'dart:ui' as ui;
import 'custom_app_bar.dart';
import 'current_trip_page.dart';
import 'graph_Score_Page.dart';
import 'trip_helper.dart';
import 'ipconfig.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';
import 'pdf_helper.dart';
import 'email_helper.dart';

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
                _buildStatCard(
                  icon: Icons.speed,
                  label: 'Total Distance',
                  value: '${totalDistanceMiles.toStringAsFixed(1)} mi',
                  color: Colors.green,
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
                    height: 180,
                    padding: EdgeInsets.fromLTRB(8, 12, 12, 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Graph legend
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Score per trip (T1 = oldest, T${scores.take(10).length} = newest)',
                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Expanded(child: _buildScoreTrajectory()),
                      ],
                    ),
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
    final now = DateTime.now();
    final driverName = userName.isNotEmpty ? userName : 'Driver';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        build: (pw.Context pdfContext) {
          return [
            // Header
            pw.Container(
              padding: pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue800,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  pw.Text('NOTRACKDRIVE', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  pw.SizedBox(height: 4),
                  pw.Text('Driving Safety Report', style: pw.TextStyle(fontSize: 14, color: PdfColors.white)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Driver info and date
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Driver: $driverName', style: pw.TextStyle(fontSize: 12)),
                pw.Text('Generated: ${DateFormat('MMMM d, yyyy h:mm a').format(now)}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              ],
            ),
            pw.SizedBox(height: 20),

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
                      pw.Text('$score', style: pw.TextStyle(fontSize: 48, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                      pw.Text('out of 100', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: score >= 80 ? PdfColors.green100 : score >= 60 ? PdfColors.orange100 : PdfColors.red100,
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Text(_getScoreLabel(score), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Summary Statistics Section
            pw.Text('Summary Statistics', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
            pw.Divider(color: PdfColors.blue200),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildPdfStatBox('Total Trips', '$totalTrips'),
                _buildPdfStatBox('Distance', '${totalDistanceMiles.toStringAsFixed(1)} mi'),
                _buildPdfStatBox('Duration', _formatDuration(totalDurationMinutes)),
              ],
            ),
            pw.SizedBox(height: 24),

            // Driving Habits Section
            pw.Text('Driving Habits Analysis', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
            pw.Divider(color: PdfColors.blue200),
            pw.SizedBox(height: 8),
            ...breakdown.entries.map((e) => pw.Container(
              margin: pw.EdgeInsets.only(bottom: 6),
              padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(e.key, style: pw.TextStyle(fontSize: 11)),
                  pw.Text(e.value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            )),
            pw.SizedBox(height: 24),

            // Score Trajectory Graph
            if (scores.isNotEmpty) ...[
              pw.Text('Score Trajectory', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.Divider(color: PdfColors.blue200),
              pw.SizedBox(height: 8),
              _buildPdfScoreChart(scores.take(10).toList().reversed.toList(), pdf),
              pw.SizedBox(height: 8),
              pw.Text(_getEmailTrendMessage(), style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
              pw.SizedBox(height: 24),
            ],

            // Recent Trips Table
            if (tripHistory.isNotEmpty) ...[
              pw.Text('Recent Trips', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.Divider(color: PdfColors.blue200),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
                cellStyle: pw.TextStyle(fontSize: 10),
                cellPadding: pw.EdgeInsets.all(6),
                headers: ['Date', 'Distance', 'Duration', 'Score'],
                data: tripHistory.take(10).map((trip) {
                  String dateStr = trip['date'] ?? '';
                  String formattedDate = 'N/A';
                  if (dateStr.isNotEmpty) {
                    try {
                      DateTime date = DateTime.parse(dateStr).toLocal();
                      formattedDate = DateFormat('MMM d, yyyy').format(date);
                    } catch (_) {}
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
            pw.SizedBox(height: 40),

            // Footer
            pw.Container(
              padding: pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                children: [
                  pw.Text('This report was generated by NoTrackDrive', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  pw.Text('For questions, contact support@notrackdrive.com', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                ],
              ),
            ),
          ];
        },
      ),
    );

    final pdfBytes = await pdf.save();
    // Filename format: NoTrackDrive_DriverName_Date_Time.pdf
    final safeDriverName = driverName.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
    final fileName = 'NoTrackDrive_${safeDriverName}_${DateFormat('yyyy-MM-dd_HHmm').format(now)}.pdf';

    // Use cross-platform PDF helper (works on both web and mobile)
    final success = await savePdfFile(pdfBytes, fileName);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kIsWeb ? 'PDF downloaded successfully!' : 'PDF ready to share!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save PDF. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generating PDF: $e')),
    );
  }
}

// Build a visual line chart for PDF
pw.Widget _buildPdfScoreChart(List<double> scoreData, pw.Document pdfDoc) {
  if (scoreData.isEmpty) {
    return pw.Text('No data available', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500));
  }

  const double chartWidth = 450;
  const double chartHeight = 120;
  const double leftMargin = 30;
  const double bottomMargin = 20;
  const double topMargin = 15;

  // Create fonts from the PDF document (must be done outside the painter closure)
  final helveticaFont = PdfFont.helvetica(pdfDoc.document);
  final helveticaBoldFont = PdfFont.helveticaBold(pdfDoc.document);

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

          // Grid line
          canvas
            ..setColor(PdfColors.grey300)
            ..drawLine(leftMargin, y, leftMargin + graphWidth, y)
            ..strokePath();

          // Y-axis label
          canvas
            ..setColor(PdfColors.grey700)
            ..drawString(
              helveticaFont,
              8,
              '$label',
              leftMargin - 22,
              y - 3,
            );
        }

        // Draw the line chart
        if (scoreData.length > 1) {
          final double xStep = graphWidth / (scoreData.length - 1);

          // Draw line
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

          // Draw data points and labels
          for (int i = 0; i < scoreData.length; i++) {
            final double x = leftMargin + i * xStep;
            final double y = topMargin + graphHeight - (scoreData[i].clamp(0, 100) / 100 * graphHeight);

            // Point
            canvas
              ..setColor(PdfColors.blue800)
              ..drawEllipse(x, y, 4, 4)
              ..fillPath();

            // Score label above point
            canvas
              ..setColor(PdfColors.blue900)
              ..drawString(
                helveticaBoldFont,
                8,
                '${scoreData[i].toInt()}',
                x - 6,
                y + 8,
              );

            // Trip label below
            canvas
              ..setColor(PdfColors.grey600)
              ..drawString(
                helveticaFont,
                7,
                'T${i + 1}',
                x - 4,
                topMargin + graphHeight + 8,
              );
          }
        } else if (scoreData.length == 1) {
          // Single point
          final double x = leftMargin + graphWidth / 2;
          final double y = topMargin + graphHeight - (scoreData[0].clamp(0, 100) / 100 * graphHeight);

          canvas
            ..setColor(PdfColors.blue800)
            ..drawEllipse(x, y, 5, 5)
            ..fillPath();

          canvas
            ..setColor(PdfColors.blue900)
            ..drawString(
              helveticaBoldFont,
              9,
              '${scoreData[0].toInt()}',
              x - 8,
              y + 10,
            );
        }
      },
    ),
  );
}

void _showEmailDialog(BuildContext context) {
  final emailController = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Email Report'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_file, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your report will be attached as a professional PDF',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            await _sendEmailReportWithPdf(context, emailController.text);
          },
          child: Text('Send with PDF'),
        ),
      ],
    ),
  );
}

Future<void> _sendEmailReportWithPdf(BuildContext context, String email) async {
  if (email.isEmpty || !email.contains('@')) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter a valid email address')),
    );
    return;
  }

  // Show loading indicator
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          SizedBox(width: 16),
          Text('Generating PDF report...'),
        ],
      ),
      duration: Duration(seconds: 10),
    ),
  );

  try {
    final now = DateTime.now();
    final driverName = userName.isNotEmpty ? userName : 'Driver';

    // Generate PDF
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        build: (pw.Context pdfContext) {
          return [
            // Header
            pw.Container(
              padding: pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue800,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  pw.Text('NOTRACKDRIVE', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  pw.SizedBox(height: 4),
                  pw.Text('Driving Safety Report', style: pw.TextStyle(fontSize: 14, color: PdfColors.white)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Driver info and date
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Driver: $driverName', style: pw.TextStyle(fontSize: 12)),
                pw.Text('Generated: ${DateFormat('MMMM d, yyyy h:mm a').format(now)}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              ],
            ),
            pw.SizedBox(height: 20),

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
                      pw.Text('$score', style: pw.TextStyle(fontSize: 48, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                      pw.Text('out of 100', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: score >= 80 ? PdfColors.green100 : score >= 60 ? PdfColors.orange100 : PdfColors.red100,
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Text(_getScoreLabel(score), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Summary Statistics Section
            pw.Text('Summary Statistics', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
            pw.Divider(color: PdfColors.blue200),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildPdfStatBox('Total Trips', '$totalTrips'),
                _buildPdfStatBox('Distance', '${totalDistanceMiles.toStringAsFixed(1)} mi'),
                _buildPdfStatBox('Duration', _formatDuration(totalDurationMinutes)),
              ],
            ),
            pw.SizedBox(height: 24),

            // Driving Habits Section
            pw.Text('Driving Habits Analysis', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
            pw.Divider(color: PdfColors.blue200),
            pw.SizedBox(height: 8),
            ...breakdown.entries.map((e) => pw.Container(
              margin: pw.EdgeInsets.only(bottom: 6),
              padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(e.key, style: pw.TextStyle(fontSize: 11)),
                  pw.Text(e.value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            )),
            pw.SizedBox(height: 24),

            // Score Trajectory Graph
            if (scores.isNotEmpty) ...[
              pw.Text('Score Trajectory', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.Divider(color: PdfColors.blue200),
              pw.SizedBox(height: 8),
              _buildPdfScoreChart(scores.take(10).toList().reversed.toList(), pdf),
              pw.SizedBox(height: 8),
              pw.Text(_getEmailTrendMessage(), style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
              pw.SizedBox(height: 24),
            ],

            // Recent Trips Table
            if (tripHistory.isNotEmpty) ...[
              pw.Text('Recent Trips', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.Divider(color: PdfColors.blue200),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
                cellStyle: pw.TextStyle(fontSize: 10),
                cellPadding: pw.EdgeInsets.all(6),
                headers: ['Date', 'Distance', 'Duration', 'Score'],
                data: tripHistory.take(10).map((trip) {
                  String dateStr = trip['date'] ?? '';
                  String formattedDate = 'N/A';
                  if (dateStr.isNotEmpty) {
                    try {
                      DateTime date = DateTime.parse(dateStr).toLocal();
                      formattedDate = DateFormat('MMM d, yyyy').format(date);
                    } catch (_) {}
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
            pw.SizedBox(height: 40),

            // Footer
            pw.Container(
              padding: pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                children: [
                  pw.Text('This report was generated by NoTrackDrive', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  pw.Text('For questions, contact support@notrackdrive.com', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                ],
              ),
            ),
          ];
        },
      ),
    );

    final pdfBytes = await pdf.save();
    // Filename format: NoTrackDrive_DriverName_Date_Time.pdf
    final safeDriverName = driverName.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
    final fileName = 'NoTrackDrive_${safeDriverName}_${DateFormat('yyyy-MM-dd_HHmm').format(now)}.pdf';

    // Clear the loading snackbar
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Send email with PDF - clean, non-repetitive body
    final emailBody = '''Please find my NoTrackDrive Driving Safety Report attached.

Summary:
- Overall Score: $score/100 (${_getScoreLabel(score)})
- Total Trips: $totalTrips
- Total Distance: ${totalDistanceMiles.toStringAsFixed(1)} miles

Best regards,
$driverName''';

    final success = await sendEmailWithPdf(
      recipientEmail: email,
      subject: 'NoTrackDrive Report - $driverName - ${DateFormat('MMM d, yyyy').format(now)}',
      bodyText: emailBody,
      pdfBytes: pdfBytes,
      pdfFileName: fileName,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kIsWeb
              ? 'PDF downloaded! Attach it to your email.'
              : 'Email prepared with PDF attachment!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email'), backgroundColor: Colors.red),
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
    );
  }
}

// Helper for PDF stat boxes
pw.Widget _buildPdfStatBox(String label, String value) {
  return pw.Container(
    padding: pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: PdfColors.blue50,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
        pw.SizedBox(height: 4),
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      ],
    ),
  );
}

// Helper to get trend message for email
String _getEmailTrendMessage() {
  if (scores.length < 2) return '';

  List<double> recent = scores.take(5).toList();
  List<double> older = scores.skip(5).take(5).toList();

  if (older.isEmpty) return '';

  double recentAvg = recent.reduce((a, b) => a + b) / recent.length;
  double olderAvg = older.reduce((a, b) => a + b) / older.length;
  double diff = recentAvg - olderAvg;

  if (diff > 5) {
    return 'Trend: IMPROVING - Your driving is getting better!';
  } else if (diff < -5) {
    return 'Trend: DECLINING - Focus on smoother driving.';
  } else {
    return 'Trend: STABLE - Consistent driving performance.';
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

// Custom painter for score trajectory visualization with axis labels
class ScoreTrajectoryPainter extends CustomPainter {
  final List<double> scoreData;
  final List<String> dateLabels;

  ScoreTrajectoryPainter(this.scoreData, {this.dateLabels = const []});

  @override
  void paint(Canvas canvas, Size size) {
    if (scoreData.isEmpty) return;

    // Define margins for axis labels (increased left margin for better spacing)
    const double leftMargin = 40;
    const double bottomMargin = 25;
    const double chartPadding = 15; // Extra padding from Y-axis for first point
    final double chartWidth = size.width - leftMargin - chartPadding;
    final double chartHeight = size.height - bottomMargin;

    // Paint styles
    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    final textStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 10,
    );

    // Draw Y-axis labels (0, 50, 100)
    final yLabels = [0, 50, 100];
    for (var label in yLabels) {
      final y = chartHeight - (label / 100) * chartHeight;

      // Draw grid line
      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(size.width, y),
        gridPaint,
      );

      // Draw label
      final textSpan = TextSpan(text: '$label', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(leftMargin - textPainter.width - 4, y - textPainter.height / 2));
    }

    // Draw score line
    final path = Path();
    final double xStep = chartWidth / (scoreData.length - 1).clamp(1, scoreData.length);

    for (int i = 0; i < scoreData.length; i++) {
      final x = leftMargin + chartPadding + i * xStep;
      // Use fixed scale 0-100 for consistency
      final y = chartHeight - (scoreData[i].clamp(0, 100) / 100) * chartHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, dotPaint);

      // Draw score value above each point
      final scoreSpan = TextSpan(
        text: '${scoreData[i].toInt()}',
        style: TextStyle(color: Colors.blue[700], fontSize: 9, fontWeight: FontWeight.bold),
      );
      final scorePainter = TextPainter(
        text: scoreSpan,
        textDirection: ui.TextDirection.ltr,
      );
      scorePainter.layout();
      scorePainter.paint(canvas, Offset(x - scorePainter.width / 2, y - 16));
    }

    canvas.drawPath(path, linePaint);

    // Draw X-axis labels (Trip numbers)
    if (scoreData.length <= 10) {
      for (int i = 0; i < scoreData.length; i++) {
        final x = leftMargin + chartPadding + i * xStep;
        final labelSpan = TextSpan(text: 'T${i + 1}', style: textStyle);
        final labelPainter = TextPainter(
          text: labelSpan,
          textDirection: ui.TextDirection.ltr,
        );
        labelPainter.layout();
        labelPainter.paint(canvas, Offset(x - labelPainter.width / 2, chartHeight + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
