/*
 * User Home Page
 *
 * This is the main dashboard that regular drivers see after logging in.
 * Shows a big button to start recording a trip, recent trip history,
 * and a link to view their safety score.
 *
 * The recent trips load from cached analytics data to keep things snappy.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'current_trip_page.dart';
import 'trip_helper.dart';
import 'score_page.dart';
import 'data_manager.dart';

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
  State<UserHomePage> createState() => _UserHomePageState();
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

  /// Loads the user's most recent trips from the data manager
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

  /// Checks if there's an old trip that was never finished
  /// Shows a dialog asking if user wants to abandon or continue it
  Future<void> _checkForActiveTrip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? activeTripId = prefs.getString('current_trip_id');
    String? tripStartTime = prefs.getString('trip_start_time');

    if (activeTripId != null && activeTripId.isNotEmpty && tripStartTime != null) {
      DateTime startTime = DateTime.parse(tripStartTime);
      Duration timeSinceStart = DateTime.now().difference(startTime);

      // If trip is more than 4 hours old, it was probably forgotten
      if (timeSinceStart.inHours > 4) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Active Trip Found'),
                content: Text(
                  'You have an active trip from ${timeSinceStart.inHours} hours ago. '
                  'Would you like to abandon it or continue?'
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      // Clear the old trip data
                      await prefs.remove('current_trip_id');
                      await prefs.remove('trip_start_time');
                      await prefs.setInt('batch_counter', 0);
                      await prefs.setDouble('max_speed', 0.0);
                      await prefs.setInt('point_counter', 0);
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Previous trip abandoned')),
                      );
                    },
                    child: const Text('Abandon Trip'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CurrentTripPage()),
                      );
                    },
                    child: const Text('Continue Trip'),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  /// Builds the recent trips section card
  Widget _buildPreviousTripsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.lightBlueAccent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Trips',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            _buildTripsContent(),
          ],
        ),
      ),
    );
  }

  /// Returns the appropriate content for the trips section
  Widget _buildTripsContent() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
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
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.white70),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecentTrips,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (recentTrips.isEmpty) {
      return const Center(
        child: Text(
          'No recent trips available.',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    }

    // Show the trip list
    return Column(
      children: recentTrips.take(3).map((trip) {
        // Parse the timestamp for display
        String dateDisplay = "No date";
        String startTimeStr = trip['start_timestamp'] ?? '';
        if (startTimeStr.isNotEmpty) {
          try {
            DateTime startTime = DateTime.parse(startTimeStr).toLocal();
            dateDisplay = DateFormat('MMM d, yyyy • h:mm a').format(startTime);
          } catch (e) {
            dateDisplay = "Invalid date";
          }
        }

        double distance = (trip['total_distance_miles'] ?? 0.0).toDouble();

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_car, color: Colors.white, size: 20),
            ),
            title: Text(
              dateDisplay,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${distance.toStringAsFixed(2)} miles',
              style: TextStyle(color: Colors.white.withAlpha(204)),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              onPressed: () {
                TripService.showTripDetails(context, trip);
              },
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      }).toList(),
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
            // Welcome header with profile avatar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
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
                            style: const TextStyle(
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
            const SizedBox(height: 32),

            // Big Start Trip button
            Center(
              child: GestureDetector(
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? userDataJson = prefs.getString('user_data');

                  if (userDataJson != null) {
                    Map<String, dynamic> userData = json.decode(userDataJson);

                    // Make sure base point is set (needed for geofencing)
                    if (userData['base_point'] == null) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error: Base point not set. Please update your profile with a zipcode.'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 4),
                          ),
                        );
                      }
                      return;
                    }

                    // Navigate to trip recording page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CurrentTripPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
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
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car, size: 48, color: Colors.white),
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
            const SizedBox(height: 40),

            // Recent Trips section
            Text(
              'Recent Trips',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 16),
            _buildPreviousTripsSection(),
            const SizedBox(height: 24),

            // Safety Score section
            Text(
              'Your Safety Score',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScorePage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
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
                    const Icon(Icons.star, size: 40, color: Colors.amber),
                    const SizedBox(width: 16),
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
                          const SizedBox(height: 4),
                          Text(
                            'Check your latest driving safety assessment',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
