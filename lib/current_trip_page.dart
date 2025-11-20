import 'dart:io'; // Add this import at the top
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'custom_app_bar.dart';
import 'home_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ipconfig.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'location_foreground_task.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

// Add this method in the CurrentTripPageState class
Future<bool> _checkNetworkConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    return false;
  }
  return false;
}

class CurrentTripPage extends StatefulWidget {
  const CurrentTripPage({super.key});

  @override
  CurrentTripPageState createState() => CurrentTripPageState();
}

class CurrentTripPageState extends State<CurrentTripPage> {
  bool isTripStarted = false;
  bool isLoading = true;
  Timer? _elapsedTimeTimer;
  Timer? _speedUpdateTimer;
  DateTime? tripStartTime;
  int _elapsedTime = 0;
  int _pointCounter = 0;
  final String server = AppConfig.server;
  Random rand = Random();
  late String role;
  //remove these calls if changes do not work
  final String trajectoryEndpoint = 'https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/store-trajectory-batch';
  final String finalizeEndpoint = 'https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/finalize-trip';
  int _selectedIndex = 0;
  double currentSpeed = 0.0;
  double maxSpeed = 0.0;
  Position? lastPosition;


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _requestPermissions();
    _initForegroundTask();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    role = prefs.getString('role')!;
    setState(() {
      isLoading = false;
    });
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'location_tracking',
        channelName: 'Location Tracking',
        channelDescription: 'Tracking your trip location',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        // Icon is set in Android manifest, not here
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(2000), // Repeat every 2 seconds
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  @override
  void dispose() {
    _elapsedTimeTimer?.cancel();
    _speedUpdateTimer?.cancel();
    super.dispose();
  }

  // Method to format the elapsed time into HH:MM:SS, MM:SS, or just seconds
  String formatElapsedTime() {
    int hours = _elapsedTime ~/ 3600;
    int minutes = (_elapsedTime % 3600) ~/ 60;
    int seconds = _elapsedTime % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$seconds sec';
    }
  }

  // Request location permissions at runtime
  Future<void> _requestPermissions() async {
    // Check the current permission status
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // If permission is denied, request the permission
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // If the permission is denied permanently, inform the user to enable it manually in settings
      debugPrint(
        "Location permissions are permanently denied. Please enable them in app settings.",
      );
      _showPermissionDialog(
        "Location permission is permanently denied. Please enable it in settings.",
      );
    } else if (permission == LocationPermission.denied) {
      // If permission is denied (not permanently), inform the user that permission was denied
      debugPrint("Location permission was denied.");
      _showPermissionDialog(
        "Location permission was denied. Please enable it to use this feature.",
      );
    } else {
      // Permission granted
      debugPrint("Location permission granted.");
    }
  }

  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _openAppSettings();
                Navigator.of(context).pop();
              },
              child: Text('Go to Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openAppSettings() async {
    bool opened = await Geolocator.openAppSettings();
    if (!opened) {
      debugPrint('Could not open app settings.');
    }
  }

  Future<void> _showLoadingDialog(String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  Future<void> startTrip() async {
    // Check network first
    bool hasNetwork = await _checkNetworkConnection();
    if (!hasNetwork) {
      _showErrorDialog(
        'No Internet Connection',
        'An internet connection is required to start tracking. Please check your connection and try again.',
      );
      return;
    }
    
    // Check location permissions - CRITICAL for background tracking
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await _requestPermissions();
      permission = await Geolocator.checkPermission();
    }

    // iOS CRITICAL: Require 'Always' permission for background tracking during trips
    if (permission == LocationPermission.whileInUse) {
      // User has 'When In Use' but needs 'Always' for background tracking
      bool? upgradePermission = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Background Location Required'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To track your trips even when your phone is locked or the app is in the background, Drive Guard needs "Always" location permission.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 12),
                Text(
                  'Steps:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text('1. Tap "Go to Settings" below', style: TextStyle(fontSize: 13)),
                Text('2. Select "Location"', style: TextStyle(fontSize: 13)),
                Text('3. Choose "Always"', style: TextStyle(fontSize: 13)),
                Text('4. Return to app and try again', style: TextStyle(fontSize: 13)),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '⚠️ Without "Always" permission, tracking will stop when your screen locks.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _openAppSettings();
                  Navigator.of(context).pop(true);
                },
                child: Text('Go to Settings'),
              ),
            ],
          );
        },
      );

      if (upgradePermission != true) {
        return; // User cancelled
      }

      // After returning from settings, re-check permission
      await Future.delayed(Duration(milliseconds: 500));
      permission = await Geolocator.checkPermission();

      if (permission != LocationPermission.always) {
        _showErrorDialog(
          'Permission Required',
          'Please enable "Always" location permission in Settings to start tracking.',
        );
        return;
      }
    }

    if (permission == LocationPermission.always) {
      
      // Verify base point exists
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataJson = prefs.getString('user_data');
      if (userDataJson == null) {
        _showErrorDialog('Error', 'User data not found. Please log in again.');
        return;
      }
      
      Map<String, dynamic> userData = json.decode(userDataJson);
      if (userData['base_point'] == null) {
        _showErrorDialog(
          'Setup Required',
          'You need to set up your base location (zipcode) in your profile before starting a trip. This is required for privacy protection.',
        );
        return;
      }
      
      // Create trip ID for this session
      String userId = userData['user_id'] ?? '';
      if (userId.isEmpty) {
        _showErrorDialog('Error', 'User ID not found. Please log in again.');
        return;
      }
      
      String tripId = 'trip_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      
      setState(() {
        isTripStarted = true;
        _elapsedTime = 0;
        _pointCounter = 0;
        tripStartTime = DateTime.now();
        currentSpeed = 0.0;
        maxSpeed = 0.0;
      });
      
      // Save trip metadata to SharedPreferences
      await prefs.setString('current_trip_id', tripId);
      await prefs.setString('trip_start_time', tripStartTime!.toIso8601String());
      await prefs.setInt('batch_counter', 0);
      await prefs.setDouble('max_speed', 0.0);
      await prefs.setInt('point_counter', 0);
      await prefs.setDouble('current_speed', 0.0);
      
      print('✅ Created trip: $tripId');
      
      // Timer to update elapsed time (works on all platforms)
      _elapsedTimeTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _elapsedTime++;
          });
        }
      });
      
      // Platform-specific tracking
      if (kIsWeb) {
        // WEB PLATFORM: Use timer-based location polling
        print('🌐 Web platform detected - using timer-based tracking');
        
        // Start a timer to collect location data every 2 seconds
        _speedUpdateTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
          if (!isTripStarted || !mounted) {
            timer.cancel();
            return;
          }
          
          try {
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            ).timeout(Duration(seconds: 5));
            
            // Calculate speed (improved logic matching mobile)
            double speedMph = 0.0;
            bool usedGpsSpeed = false;

            // Method 1: Try GPS-provided speed
            if (position.speed != null && position.speed! >= 0) {
              speedMph = position.speed! * 2.237; // Convert m/s to mph
              usedGpsSpeed = true;
              print('📊 Web: Using GPS speed: ${speedMph.toStringAsFixed(1)} mph');
            }
            // Method 2: Calculate from previous position
            else if (lastPosition != null) {
              double distanceMeters = Geolocator.distanceBetween(
                lastPosition!.latitude,
                lastPosition!.longitude,
                position.latitude,
                position.longitude,
              );
              double distanceMiles = distanceMeters * 0.000621371; // meters to miles
              double timeHours = 2.0 / 3600.0; // 2 seconds in hours

              if (distanceMeters > 0.5) { // Ignore tiny movements
                speedMph = distanceMiles / timeHours;
                print('📊 Web: Calculated speed: ${speedMph.toStringAsFixed(1)} mph from ${distanceMeters.toStringAsFixed(1)}m');
              }
            }

            // Cap unrealistic speeds
            if (speedMph > 150) {
              speedMph = currentSpeed; // Keep previous speed
              print('⚠️ Web: Unrealistic speed capped');
            }

            // Update state
            setState(() {
              currentSpeed = speedMph;
              if (speedMph > maxSpeed) {
                maxSpeed = speedMph;
              }
              _pointCounter++;
            });

            lastPosition = position;

            // Store in SharedPreferences for consistency
            await prefs.setDouble('current_speed', speedMph);
            await prefs.setDouble('max_speed', maxSpeed);
            await prefs.setInt('point_counter', _pointCounter);

            print('📍 Web tracking - Point #$_pointCounter, Speed: ${speedMph.toStringAsFixed(1)} mph, Max: ${maxSpeed.toStringAsFixed(1)} mph');
            
          } catch (e) {
            print('❌ Error getting location on web: $e');
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip started! Tracking location...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
      } else {
        // MOBILE PLATFORM: Use foreground service
        print('📱 Mobile platform detected - using foreground service');
        
        // Start the foreground service for mobile
        ServiceRequestResult result = await FlutterForegroundTask.startService(
          notificationTitle: 'Trip in Progress',
          notificationText: 'Tracking your location',
          callback: startCallback,
        );

        print('Service start result: $result');
        
        // Verify service is running
        await Future.delayed(Duration(milliseconds: 500));
        
        if (await FlutterForegroundTask.isRunningService) {
          print('✅ Background location tracking started successfully');
          
          // Timer to read speed data from background service - runs every 1 second
          _speedUpdateTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
            if (!mounted || !isTripStarted) {
              timer.cancel();
              return;
            }

            try {
              SharedPreferences prefs = await SharedPreferences.getInstance();

              // Read all metrics from background service
              double? storedMaxSpeed = prefs.getDouble('max_speed');
              double? storedCurrentSpeed = prefs.getDouble('current_speed');
              int? storedPointCounter = prefs.getInt('point_counter');

              // Debug logging
              if (storedPointCounter != null && storedPointCounter > 0) {
                print('📱 UI Update - Points: $storedPointCounter, Speed: ${storedCurrentSpeed?.toStringAsFixed(1) ?? "0.0"} mph, Max: ${storedMaxSpeed?.toStringAsFixed(1) ?? "0.0"} mph');
              }

              // Update UI state
              setState(() {
                if (storedMaxSpeed != null) {
                  maxSpeed = storedMaxSpeed;
                }

                if (storedCurrentSpeed != null) {
                  currentSpeed = storedCurrentSpeed;
                }

                if (storedPointCounter != null) {
                  _pointCounter = storedPointCounter;
                }
              });
            } catch (e) {
              print('❌ Error reading trip data from SharedPreferences: $e');
            }
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Trip started! Background tracking active.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          print('❌ Background tracking service failed to start');
          setState(() {
            isTripStarted = false;
            _elapsedTime = 0;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to start location tracking. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      _showErrorDialog(
        'Location Permission Required',
        'Please grant location permission to track your trips.',
      );
    }
  }

  @pragma('vm:entry-point')
  void startCallback() {
    FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
  }

  // Stop the trip but KEEP delta points visible
  // void stopTrip() async {
  //   setState(() {
  //     isTripStarted = false; // Stops the trip but keeps everything visible
  //   });

  //   // Send remaining data but DO NOT clear `deltaPoints` or reset UI
  //   if (_elapsedTime > 5) {
  //     sendTripData();
  //   }

  //   // Stop all timers
  //   _deltaTimer?.cancel();
  //   _elapsedTimeTimer?.cancel();
  //   _sendDataTimer?.cancel();

  //   // Forces UI refresh without clearing data
  //   setState(() {});
  // }
  // revert to above function if below modified stoptrip() causes issues
  void stopTrip() async {
    setState(() {
      isTripStarted = false;
    });

    // Stop platform-specific tracking
    if (kIsWeb) {
      print('🌐 Stopping web tracking');
      // Web platform - timers will be cancelled below
    } else {
      // Mobile platform - stop foreground service
      print('📱 Stopping mobile foreground service');
      await FlutterForegroundTask.stopService();
    }

    // Check network connection
    bool hasNetwork = await _checkNetworkConnection();
    if (!hasNetwork) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No internet connection. Trip data saved locally.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
      // Stop timers but keep trip data
      _elapsedTimeTimer?.cancel();
      _speedUpdateTimer?.cancel();
      setState(() {});
      return;
    }

    // Finalize trip with backend
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tripId = prefs.getString('current_trip_id');
    String? tripStartTime = prefs.getString('trip_start_time');
    String? userDataJson = prefs.getString('user_data');

    if (tripId != null && tripId.isNotEmpty && tripStartTime != null && userDataJson != null) {
      Map<String, dynamic> userData = json.decode(userDataJson);
      String userId = userData['user_id'] ?? '';
      
      DateTime startTime = DateTime.parse(tripStartTime);
      DateTime endTime = DateTime.now();
      double durationMinutes = endTime.difference(startTime).inSeconds / 60.0;

      // Ensure minimum trip duration
      if (durationMinutes < 0.5) {
        durationMinutes = 0.5; // Minimum 30 seconds
      }

      Map<String, dynamic> finalizeData = {
        'user_id': userId,
        'trip_id': tripId,
        'start_timestamp': tripStartTime,
        'end_timestamp': endTime.toIso8601String(),
        'trip_quality': {
          'use_gps_metrics': true,
          'gps_max_speed_mph': maxSpeed,
          'actual_duration_minutes': durationMinutes,
          'actual_distance_miles': (_pointCounter * 0.1), // Rough estimate
          'total_points': _pointCounter,
          'valid_points': _pointCounter,
          'rejected_points': 0,
          'average_accuracy': 5.0,
          'gps_quality_score': 0.9,
        }
      };
      
      print('📊 Finalizing trip: $tripId with $_pointCounter points');
      
      try {
        // Try to finalize trip with retry logic
        bool finalized = false;
        int retries = 0;
        const maxRetries = 3;
        
        while (!finalized && retries < maxRetries) {
          try {
            final response = await http.post(
              Uri.parse(finalizeEndpoint),
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode(finalizeData),
            ).timeout(Duration(seconds: 10));
            
            if (response.statusCode == 200) {
              finalized = true;
              print('✅ Trip finalized successfully');
              
              // Clear trip data
              await prefs.remove('current_trip_id');
              await prefs.remove('trip_start_time');
              await prefs.setInt('batch_counter', 0);
              await prefs.setDouble('max_speed', 0.0);
              await prefs.setInt('point_counter', 0);
              await prefs.setDouble('current_speed', 0.0);
              
              // Reset UI state
              setState(() {
                maxSpeed = 0.0;
                currentSpeed = 0.0;
                _pointCounter = 0;
                _elapsedTime = 0;
                lastPosition = null;
              });
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Trip saved successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              print('❌ Finalization failed with status: ${response.statusCode}');
              print('Response body: ${response.body}');
              retries++;
              if (retries < maxRetries) {
                await Future.delayed(Duration(seconds: 2));
              }
            }
          } catch (e) {
            print('❌ Finalization attempt ${retries + 1} failed: $e');
            retries++;
            if (retries < maxRetries) {
              await Future.delayed(Duration(seconds: 2));
            }
          }
        }
        
        if (!finalized) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save trip. Please check your connection.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } catch (error) {
        print('❌ Error finalizing trip: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving trip: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('⚠️ No active trip to finalize');
    }

    // Stop timers
    _elapsedTimeTimer?.cancel();
    _speedUpdateTimer?.cancel();
    
    setState(() {});
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Future<void> sendTripData() async {
  //   final String url = '$server/points';
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('access_token');

  //   Map<String, dynamic> data = {
  //     'isStart': _elapsedTime <= 30,
  //     'start_time': DateTime.now().toIso8601String(),
  //     'elapsed_time': _elapsedTime,
  //     'delta_points': deltaPoints,
  //     'isEnd': !isTripStarted,
  //   };

  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: json.encode(data),
  //     );

  //     if (response.statusCode == 202) {
  //       deltaPoints.clear();
  //     } else {
  //       debugPrint('Error sending trip data');
  //     }
  //   } catch (error) {
  //     debugPrint('Error: $error');
  //   }
  // }
  // IF below function causes issues revert to above sendTripData function
  

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: !isTripStarted, // Can only navigate away when trip is NOT active
      onPopInvoked: (bool didPop) {
        if (didPop) return; // If pop already happened, do nothing
        
        // If user tried to leave during active trip
        if (isTripStarted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please stop the trip before leaving this page'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // If trip is not active, navigate to home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(role: role)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar:
            isLoading
                ? null
                : CustomAppBar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                  role: role,
                ),
        body:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Column(
                    children: [
                      _buildStatusCard(screenWidth),
                      SizedBox(height: screenHeight * 0.02),
                      _buildTimerCard(screenWidth),
                      SizedBox(height: screenHeight * 0.02),
                      if (isTripStarted) _buildTripStats(screenWidth),
                      if (isTripStarted) SizedBox(height: screenHeight * 0.02),
                      // _buildMapView(screenHeight, screenWidth),
                      // SizedBox(height: screenHeight * 0.01),
                      // _buildDeltaList(screenHeight, screenWidth),
                      SizedBox(height: screenHeight * 0.01),
                      _buildActionButton(screenWidth),
                      SizedBox(height: screenHeight * 0.01),
                    ],
                  ),
                ),
        bottomNavigationBar:
            isLoading
                ? null
                : CustomAppBar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                  role: role,
                ).buildBottomNavBar(context),
      ),
    );
  }

  Widget _buildStatusCard(double screenWidth) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Center(
          child: Text(
            'Trip Status: ${isTripStarted ? "Ongoing" : "Stopped"}',
            style: TextStyle(
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCard(double screenWidth) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      shadowColor: Colors.black38,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer, color: Colors.blue, size: screenWidth * 0.08),
            SizedBox(width: screenWidth * 0.03),
            Text(
              'Elapsed Time: ${formatElapsedTime()}',
              style: TextStyle(
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildDeltaList(double screenHeight, double screenWidth) {
  //   return SizedBox(
  //     height: screenHeight * 0.2,
  //     child: Card(
  //       elevation: 8,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(screenWidth * 0.04),
  //       ),
  //       shadowColor: Colors.black26,
  //       child: Padding(
  //         padding: EdgeInsets.all(screenWidth * 0.02),
  //         child:
  //             false // Temporarily disabled  
  //               ? ListView.builder(
  //                   itemCount: 0,
  //                   itemBuilder: (context, index) {
  //                     var delta = {};
  //                     return ListTile(
  //                       leading: Icon(
  //                         Icons.location_on,
  //                         color: Colors.redAccent,
  //                       ),
  //                       title: Text(
  //                         "Point #${delta['point_number']}",
  //                         style: TextStyle(fontWeight: FontWeight.bold),
  //                       ),
  //                       subtitle: Text(
  //                         "ΔLat: ${delta['delta_latitude']}, ΔLon: ${delta['delta_longitude']}",
  //                       ),
  //                       tileColor:
  //                           index % 2 == 0 ? Colors.grey[100] : Colors.white,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(
  //                           screenWidth * 0.03,
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 )
  //                 : Center(
  //                   child: Text(
  //                     "No data available",
  //                     style: TextStyle(
  //                       color: Colors.grey,
  //                       fontSize: screenWidth * 0.04,
  //                     ),
  //                   ),
  //                 ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildMapView(double screenHeight, double screenWidth) {
  //   return Container(
  //     height: screenHeight * 0.25,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(screenWidth * 0.03),
  //       boxShadow: [
  //         BoxShadow(color: Colors.black26, blurRadius: screenWidth * 0.015),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: EdgeInsets.all(screenWidth * 0.02),
  //       child:
  //           deltaPointsClone.isNotEmpty
  //               ? CustomPaint(
  //                 painter: RoutePainter(deltaPointsClone),
  //                 child: Container(),
  //               )
  //               : Center(
  //                 child: Text(
  //                   "No route data available",
  //                   style: TextStyle(
  //                     color: Colors.grey,
  //                     fontSize: screenWidth * 0.04,
  //                   ),
  //                 ),
  //               ),
  //     ),
  //   );
  // }


  Widget _buildTripStats(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: screenWidth * 0.015),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn(
            Icons.timer,
            'Duration',
            formatElapsedTime(),
            Colors.blue,
          ),
          _buildStatColumn(
            Icons.speed,
            'Current',
            '${currentSpeed.toStringAsFixed(1)} mph',
            Colors.green,
          ),
          _buildStatColumn(
            Icons.trending_up,
            'Max Speed',
            '${maxSpeed.toStringAsFixed(1)} mph',
            Colors.red,
          ),
          _buildStatColumn(
            Icons.location_on,
            'Points',
            '$_pointCounter',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // Widget _buildMapView(double screenHeight, double screenWidth) {
  //   return Container(
  //     height: screenHeight * 0.25,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(screenWidth * 0.03),
  //       boxShadow: [
  //         BoxShadow(color: Colors.black26, blurRadius: screenWidth * 0.015),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: EdgeInsets.all(screenWidth * 0.02),
  //       child: Column(
  //         children: [
  //           // Speed display row
  //           if (isTripStarted) 
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 Text(
  //                   'Current: ${currentSpeed.toStringAsFixed(1)} mph',
  //                   style: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: screenWidth * 0.035,
  //                   ),
  //                 ),
  //                 Text(
  //                   'Max: ${maxSpeed.toStringAsFixed(1)} mph',
  //                   style: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: screenWidth * 0.035,
  //                     color: Colors.red,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           SizedBox(height: 8),
  //           // Map visualization
  //           Expanded(
  //             // Temporarily disabled
  //             child: false 
  //               ? CustomPaint(
  //                   painter: RoutePainter([]),
  //                     child: Container(),
  //                   )
  //                 : Center(
  //                     child: Text(
  //                       "No route data available",
  //                       style: TextStyle(
  //                         color: Colors.grey,
  //                         fontSize: screenWidth * 0.04,
  //                       ),
  //                     ),
  //                   ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildActionButton(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(top: screenWidth * 0.05),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isTripStarted ? stopTrip : startTrip,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1,
            vertical: screenWidth * 0.05,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.08),
          ),
          elevation: 10,
          backgroundColor:
              isTripStarted ? Colors.redAccent : Colors.greenAccent,
          foregroundColor: Colors.white,
          shadowColor: Colors.black,
        ),
        child: Text(
          isTripStarted ? 'Stop Trip' : 'Start Trip',
          style: TextStyle(
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class RoutePainter extends CustomPainter {
  final List<Map<String, dynamic>> points;

  RoutePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return; // Need at least two points to draw

    Paint pathPaint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    Paint pointPaint =
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill;

    // Convert delta values into absolute positions
    int baseLat = 0;
    int baseLon = 0;

    List<Offset> offsets = [];
    for (int i = points.length - 1; i >= 0; i--) {
      baseLat += points[i]['delta_latitude'] as int;
      baseLon += points[i]['delta_longitude'] as int;
      offsets.add(Offset(baseLon.toDouble(), -baseLat.toDouble()));
    }

    if (offsets.length < 2) return; // Ensure enough points to draw

    // Find min/max for scaling
    double minX = offsets.map((o) => o.dx).reduce(min);
    double maxX = offsets.map((o) => o.dx).reduce(max);
    double minY = offsets.map((o) => o.dy).reduce(min);
    double maxY = offsets.map((o) => o.dy).reduce(max);

    double scaleX = (maxX - minX) != 0 ? size.width / (maxX - minX) : 1;
    double scaleY = (maxY - minY) != 0 ? size.height / (maxY - minY) : 1;

    // Normalize the points to fit within the canvas
    List<Offset> scaledOffsets =
        offsets.map((o) {
          double x = (o.dx - minX) * scaleX;
          double y = size.height - (o.dy - minY) * scaleY;
          return Offset(x, y);
        }).toList();

    Path path = Path();
    path.moveTo(scaledOffsets.first.dx, scaledOffsets.first.dy);
    for (var offset in scaledOffsets.skip(1)) {
      path.lineTo(offset.dx, offset.dy);
    }

    // Draw the path
    canvas.drawPath(path, pathPaint);

    // Draw the points
    for (var offset in scaledOffsets) {
      canvas.drawCircle(offset, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CountdownDialog extends StatefulWidget {
  final int initialSeconds;

  const CountdownDialog({super.key, required this.initialSeconds});

  @override
  CountdownDialogState createState() => CountdownDialogState();
}

class CountdownDialogState extends State<CountdownDialog> {
  late int remaining;

  @override
  void initState() {
    super.initState();
    remaining = widget.initialSeconds;
    _startCountdown();
  }

  void _startCountdown() async {
    while (remaining > 0) {
      await Future.delayed(Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        remaining--;
      });
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Warming up GPS"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Starting trip in $remaining seconds..."),
        ],
      ),
    );
  }
}
