import 'dart:io';

import 'package:flutter/material.dart';
import 'current_trip_page.dart';
import 'trip_helper.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';

import 'data_manager.dart'; // Add this import

import 'dart:math';

class UserHomePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final File? profileImage;

  const UserHomePage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.profileImage,
  });

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  List<dynamic> recentTrips = [];
  String errorMessage = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecentTrips();
    _checkForActiveTrip();
  }

  // Future<void> _loadRecentTrips() async {
  //   setState(() {
  //     isLoading = true;
  //     errorMessage = '';
  //   });

  //   try {
  //     List<dynamic> trips = await TripService.fetchPreviousTrips();
  //     setState(() {
  //       recentTrips = trips.take(3).toList();
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //       errorMessage = 'Failed to load recent trips';
  //     });
  //   }
  // }
  // revert to above function if below fails
  // Future<void> _loadRecentTrips() async {
  //   if (!mounted) return;
    
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
    
  //   // Check for cached data first
  //   String? cachedTrips = prefs.getString('cached_trips');
  //   String? cacheTime = prefs.getString('cache_time');
    
  //   // Use cache if less than 5 minutes old
  //   if (cachedTrips != null && cacheTime != null) {
  //     try {
  //       DateTime cached = DateTime.parse(cacheTime);
  //       if (DateTime.now().difference(cached).inMinutes < 5) {
  //         List<dynamic> trips = json.decode(cachedTrips);
  //         if (mounted) {
  //           setState(() {
  //             recentTrips = trips.take(3).toList();
  //             isLoading = false;
  //           });
  //         }
  //         return; // Exit early with cached data
  //       }
  //     } catch (e) {
  //       // If cache is corrupted, continue to fetch fresh data
  //       print('Cache error: $e');
  //     }
  //   }
    
  //   // If no valid cache, show loading and fetch fresh data
  //   setState(() {
  //     isLoading = true;
  //     errorMessage = '';
  //   });

  //   String? userDataJson = prefs.getString('user_data');
    
  //   if (userDataJson == null) {
  //     if (mounted) {
  //       setState(() {
  //         recentTrips = [];
  //         isLoading = false;
  //       });
  //     }
  //     return;
  //   }
    
  //   Map<String, dynamic> userData = json.decode(userDataJson);
  //   String userEmail = userData['email'] ?? '';
    
  //   try {
  //     // Use YOUR analyze-driver endpoint
  //     final response = await http.get(
  //       Uri.parse('https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/analyze-driver?email=$userEmail'),
  //     );
      
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       List<dynamic> trips = data['trips'] ?? [];
        
  //       // Cache the trips for faster loading next time
  //       await prefs.setString('cached_trips', json.encode(trips));
  //       await prefs.setString('cache_time', DateTime.now().toIso8601String());
        
  //       if (mounted) {
  //         setState(() {
  //           // Take only the 3 most recent trips
  //           recentTrips = trips.take(3).toList();
  //           isLoading = false;
  //         });
  //       }
  //     } else {
  //       if (mounted) {
  //         setState(() {
  //           recentTrips = [];
  //           isLoading = false;
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         recentTrips = [];
  //         isLoading = false;
  //         errorMessage = '';  // Don't show error, just show empty state
  //       });
  //     }
  //   }
  // }
  // revert to above function if below fails
  Future<void> _loadRecentTrips() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      Map<String, dynamic>? analytics = await DataManager.getDriverAnalytics();
      
      if (analytics != null) {
        List<dynamic> trips = analytics['trips'] ?? [];
        
        if (mounted) {
          setState(() {
            recentTrips = trips.take(3).toList();
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            recentTrips = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          recentTrips = [];
          isLoading = false;
          errorMessage = '';
        });
      }
    }
  }

  Future<void> _checkForActiveTrip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? activeTripId = prefs.getString('current_trip_id');
    String? tripStartTime = prefs.getString('trip_start_time');
    
    if (activeTripId != null && activeTripId.isNotEmpty && tripStartTime != null) {
      // There's an active trip - check if it's been more than 4 hours (likely abandoned)
      DateTime startTime = DateTime.parse(tripStartTime);
      Duration timeSinceStart = DateTime.now().difference(startTime);
      
      if (timeSinceStart.inHours > 4) {
        // Trip likely abandoned - show dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Active Trip Found'),
                content: Text(
                  'You have an active trip from ${timeSinceStart.inHours} hours ago. '
                  'Would you like to abandon it or continue?'
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      // Abandon trip - clear data
                      await prefs.remove('current_trip_id');
                      await prefs.remove('trip_start_time');
                      await prefs.setInt('batch_counter', 0);
                      await prefs.setDouble('max_speed', 0.0);
                      await prefs.setInt('point_counter', 0);
                      Navigator.of(context).pop();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Previous trip abandoned')),
                      );
                    },
                    child: Text('Abandon Trip'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to current trip page to resume
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CurrentTripPage()),
                      );
                    },
                    child: Text('Continue Trip'),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }


  Widget _buildPreviousTripsSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.lightBlueAccent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Trips',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            isLoading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading trips...',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.white70),
                          SizedBox(height: 12),
                          Text(
                            errorMessage,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadRecentTrips,
                            child: Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    )
                  : recentTrips.isEmpty
                        ? Center(
                            child: Text(
                              'No recent trips available.',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          )
                        : Column(
                            children: recentTrips.take(3).map((trip) {
                              // Parse the date properly from your backend
                              String dateDisplay = "No date";
                              String startTimeStr = trip['start_timestamp'] ?? '';
                              if (startTimeStr.isNotEmpty) {
                                try {
                                  DateTime startTime = DateTime.parse(startTimeStr).toLocal(); // Convert to local time
                                  dateDisplay = DateFormat('MMM d, yyyy • h:mm a').format(startTime);
                                } catch (e) {
                                  dateDisplay = "Invalid date";
                                }
                              }
                              
                              // Get distance from your backend field names
                              double distance = (trip['total_distance_miles'] ?? 0.0).toDouble();
                              
                              return Container(
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(26),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[700],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.directions_car,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    dateDisplay,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${distance.toStringAsFixed(2)} miles',
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(204),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.chevron_right,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      TripService.showTripDetails(context, trip);
                                    },
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String displayName = '${widget.firstName} ${widget.lastName}';
    String initials = (widget.firstName.isNotEmpty && widget.lastName.isNotEmpty)
        ? '${widget.firstName[0]}${widget.lastName[0]}'.toUpperCase()
        : '??';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with welcome and profile
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade300,
                    backgroundImage: widget.profileImage != null 
                        ? FileImage(widget.profileImage!) 
                        : null,
                    child: widget.profileImage == null
                        ? Text(
                            initials,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Start Trip Button
            Center(
              child: GestureDetector(
                onTap: () async {
                  // Initialize trip state before navigating
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? userDataJson = prefs.getString('user_data');
                  
                  if (userDataJson != null) {
                    Map<String, dynamic> userData = json.decode(userDataJson);
                    
                    // ✅ VERIFY BASE POINT EXISTS
                    if (userData['base_point'] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: Base point not set. Please update your profile with a zipcode.'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 4),
                        ),
                      );
                      return; // Don't start trip without base point
                    }
                    
                    String userId = userData['user_id'] ?? '';
                    
                    // Generate new trip ID
                    int timestamp = DateTime.now().millisecondsSinceEpoch;
                    int randomNum = Random().nextInt(999999);
                    String tripId = 'trip_${userId}_${timestamp}_$randomNum';
                    
                    // Store trip info
                    await prefs.setString('current_trip_id', tripId);
                    await prefs.setString('trip_start_time', DateTime.now().toIso8601String());
                    await prefs.setInt('batch_counter', 0);
                    await prefs.setDouble('max_speed', 0.0);
                    
                    print('✅ New trip started: $tripId');
                    print('Base point: ${userData['base_point']['city']}, ${userData['base_point']['state']}');
                    
                    // Navigate to current trip page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CurrentTripPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: User data not found. Please log in again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue.shade700, Colors.blue.shade400],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withAlpha(102),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 48,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Start Trip",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),

            // Recent Trips Section
            Text(
              'Recent Trips',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: 16),
            _buildPreviousTripsSection(),
            SizedBox(height: 24),

            // Score Section
            Text(
              'Your Safety Score',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                // Navigate to score page
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.blue.shade50, Colors.white],
                  ),
                  border: Border.all(color: Colors.blue.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 40, color: Colors.amber),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'View your score',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Check your latest driving safety assessment',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.blue.shade400),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}