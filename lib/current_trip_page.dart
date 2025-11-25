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

// CRITICAL FOR iOS: This callback MUST be a top-level function (outside any class)
// iOS requires this because the foreground task runs in a separate isolate
// and cannot access instance methods or class members
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
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
  double _totalDistance = 0.0; // Real-time distance tracking in miles
  int _batchCounter = 0; // Track number of batches uploaded
  Position? lastPosition;
  final List<Map<String, dynamic>> _webDeltaPoints = []; // Store delta points for web
  int _webBatchCounter = 0;

  // Web-compatible network check
  Future<bool> _checkNetworkConnection() async {
    if (kIsWeb) {
      // On web, assume network is available
      // Web apps can't run without network anyway
      print('🌐 Web platform - assuming network connectivity');
      return true;
    } else {
      // On mobile, try a simple HTTP request
      try {
        final response = await http.get(Uri.parse('https://www.google.com')).timeout(Duration(seconds: 3));
        return response.statusCode == 200;
      } catch (e) {
        print('❌ Network check failed: $e');
        return false;
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadTripState(); // Load persisted trip state
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

  Future<void> _loadTripState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Restore trip state if exists
    setState(() {
      _totalDistance = prefs.getDouble('total_distance') ?? 0.0;
      _batchCounter = prefs.getInt('batch_counter') ?? 0;
      _pointCounter = prefs.getInt('point_counter') ?? 0;
      currentSpeed = prefs.getDouble('current_speed') ?? 0.0;
      maxSpeed = prefs.getDouble('max_speed') ?? 0.0;

      // Load trip metadata if active
      String? tripId = prefs.getString('current_trip_id');
      String? startTimeStr = prefs.getString('trip_start_time');

      if (tripId != null && startTimeStr != null) {
        isTripStarted = true;
        tripStartTime = DateTime.parse(startTimeStr);
        print('✅ Restored trip state: Distance=${_totalDistance.toStringAsFixed(3)}mi, Points=$_pointCounter, Batches=$_batchCounter');
      }
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

    // Note: ReceivePort listener will be set up AFTER service starts
    // (ReceivePort doesn't exist until service is running)
  }

  // Callback to receive data from background isolate via SendPort
  void _onReceiveTaskData(dynamic data) {
    print("📥 ========== UI RECEIVED DATA FROM BACKGROUND ISOLATE ==========");
    print("📥 Raw data type: ${data.runtimeType}");
    print("📥 Raw data content: $data");

    if (data == null) {
      print("❌ ERROR: Received null data from background isolate!");
      print("📥 ========== DATA RECEIVE END (NULL) ==========");
      return;
    }

    if (data is Map) {
      print("✅ Data is a Map - proceeding to update UI");
      print("📥 Map keys: ${data.keys.toList()}");

      setState(() {
        if (data.containsKey('point_counter')) {
          int newCounter = data['point_counter'] as int;
          print("📊 Updating point counter: $_pointCounter -> $newCounter");
          _pointCounter = newCounter;
          print("✅ Point counter updated successfully: $_pointCounter");
        } else {
          print("⚠️ WARNING: point_counter key not found in data");
        }

        if (data.containsKey('current_speed')) {
          double newSpeed = (data['current_speed'] as num).toDouble();
          print("📊 Updating current speed: ${currentSpeed.toStringAsFixed(1)} -> ${newSpeed.toStringAsFixed(1)} mph");
          currentSpeed = newSpeed;
          print("✅ Current speed updated successfully: ${currentSpeed.toStringAsFixed(1)} mph");
        } else {
          print("⚠️ WARNING: current_speed key not found in data");
        }

        if (data.containsKey('max_speed')) {
          double newMaxSpeed = (data['max_speed'] as num).toDouble();
          print("📊 Updating max speed: ${maxSpeed.toStringAsFixed(1)} -> ${newMaxSpeed.toStringAsFixed(1)} mph");
          maxSpeed = newMaxSpeed;
          print("✅ Max speed updated successfully: ${maxSpeed.toStringAsFixed(1)} mph");
        } else {
          print("⚠️ WARNING: max_speed key not found in data");
        }
      });

      print("✅ setState() called - UI should rebuild now");
      print("📥 ========== UI UPDATE COMPLETE ==========");
    } else {
      print("❌ ERROR: Data is not a Map! Type: ${data.runtimeType}");
      print("📥 ========== DATA RECEIVE END (WRONG TYPE) ==========");
    }
  }

  @override
  void dispose() {
    _elapsedTimeTimer?.cancel();
    _speedUpdateTimer?.cancel();
    // Note: ReceivePort listener is automatically cleaned up by flutter_foreground_task
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

    // PLATFORM-SPECIFIC PERMISSION HANDLING
    if (!kIsWeb && permission == LocationPermission.whileInUse) {
      // MOBILE ONLY: User has 'When In Use' but needs 'Always' for background tracking
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

    // PROCEED WITH TRIP START IF:
    // - Web/Desktop: whileInUse is sufficient
    // - Mobile: always permission is granted
    bool hasValidPermission = kIsWeb
        ? (permission == LocationPermission.whileInUse || permission == LocationPermission.always)
        : permission == LocationPermission.always;

    if (hasValidPermission) {
      print('✅ Location permission validated for platform');
      print('   Platform: ${kIsWeb ? "Web" : "Mobile"}');
      print('   Permission level: $permission');
      
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
        _totalDistance = 0.0; // Reset distance
        _batchCounter = 0; // Reset batch counter
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
      await prefs.setDouble('total_distance', 0.0); // Store distance
      
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
        print('🌐 ========== WEB PLATFORM TRACKING STARTING ==========');
        print('🌐 Web platform detected - using timer-based tracking');
        print('🌐 Timer will trigger every 2 seconds to collect GPS data');
        print('🌐 Trip ID: $tripId');
        print('🌐 User ID: $userId');

        // Start a timer to collect location data every 2 seconds
        _speedUpdateTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
          if (!isTripStarted || !mounted) {
            print('🌐 Timer cancelled - trip stopped or widget unmounted');
            timer.cancel();
            return;
          }

          print('🌐 ========== WEB GPS POLL #$_pointCounter ==========');

          try {
            print('🌐 Requesting GPS position...');
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            ).timeout(Duration(seconds: 5));

            print('✅ GPS position obtained - Accuracy: ${position.accuracy}m');
            
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

            // Calculate distance from last position
            double segmentDistance = 0.0;
            if (lastPosition != null) {
              double distanceMeters = Geolocator.distanceBetween(
                lastPosition!.latitude,
                lastPosition!.longitude,
                position.latitude,
                position.longitude,
              );
              segmentDistance = distanceMeters * 0.000621371; // Convert meters to miles

              // Only add distance if movement is significant (filter GPS drift)
              if (segmentDistance > 0.001) { // Minimum 5.3 feet
                _totalDistance += segmentDistance;
              }
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
            await prefs.setDouble('total_distance', _totalDistance);

            // Calculate delta coordinates for web (same as mobile)
            String? userDataJson = prefs.getString('user_data');
            if (userDataJson != null) {
              Map<String, dynamic> userData = json.decode(userDataJson);
              if (userData['base_point'] != null) {
                double baseLat = (userData['base_point']['latitude'] ?? 0.0).toDouble();
                double baseLon = (userData['base_point']['longitude'] ?? 0.0).toDouble();

                int deltaLat = ((position.latitude - baseLat) * 1000000).round();
                int deltaLon = ((position.longitude - baseLon) * 1000000).round();

                // Store delta point
                _webDeltaPoints.add({
                  'dlat': deltaLat,
                  'dlon': deltaLon,
                  'dt': 2000, // 2 seconds interval
                  't': DateTime.now().toIso8601String(),
                  'p': _pointCounter,
                  'speed_mph': speedMph,
                  'accuracy': position.accuracy,
                  'speed_source': usedGpsSpeed ? 'gps' : 'calculated',
                });

                print('📊 Delta point stored - Buffer size: ${_webDeltaPoints.length}/25');

                // Send batch when we have 25 points
                if (_webDeltaPoints.length >= 25) {
                  print('📤 ========== WEB BATCH READY ==========');
                  await _sendWebBatchToServer(prefs, userId, tripId);
                  setState(() {
                    _batchCounter++;
                  });
                  await prefs.setInt('batch_counter', _batchCounter);
                }
              }
            }

            print('✅ Web tracking - Point #$_pointCounter collected');
            print('✅ Speed: ${speedMph.toStringAsFixed(1)} mph, Max: ${maxSpeed.toStringAsFixed(1)} mph');
            print('🌐 ========== WEB GPS POLL #$_pointCounter END ==========');

          } catch (e) {
            print('❌ ========== WEB GPS ERROR ==========');
            print('❌ Error getting location on web: $e');

            if (e.toString().contains('TimeoutException')) {
              print('⏰ GPS timeout - may be indoors or GPS warming up');
            } else if (e.toString().contains('permission')) {
              print('❌ Location permission issue');
            }

            print('🌐 ========== WEB GPS POLL #$_pointCounter END (ERROR) ==========');
          }
        });
        
        print('✅ ========== WEB TRACKING STARTED SUCCESSFULLY ==========');
        print('🌐 GPS polling is active - check console for updates');
        print('🌐 UI will update with speed and point count');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip started! Web tracking active - check console (F12)'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
      } else {
        // MOBILE PLATFORM: Use simple timer GPS (same as web - IT WORKS!)
        print('📱 Mobile platform - using timer GPS tracking (like web)');
        
        // Get user data for batch sending
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userDataJson = prefs.getString('user_data');
        String userId = '';
        if (userDataJson != null) {
          Map<String, dynamic> userData = json.decode(userDataJson);
          userId = userData['user_id'] ?? '';
        }

        // Start GPS polling timer - every 2 seconds (SAME AS WEB - IT WORKS!)
        _speedUpdateTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
          if (!mounted || !isTripStarted) {
            timer.cancel();
            return;
          }

          print('📱 ========== MOBILE GPS POLL #$_pointCounter ==========');

          try {
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.bestForNavigation,
            ).timeout(Duration(seconds: 5));

            print('✅ GPS: Accuracy ${position.accuracy}m');

            // Calculate speed (same as web)
            double speedMph = 0.0;
            bool usedGpsSpeed = false;

            if (position.speed != null && position.speed! >= 0) {
              speedMph = position.speed! * 2.237;
              usedGpsSpeed = true;
            } else if (lastPosition != null) {
              double distanceMeters = Geolocator.distanceBetween(
                lastPosition!.latitude, lastPosition!.longitude,
                position.latitude, position.longitude,
              );
              double distanceMiles = distanceMeters * 0.000621371;
              double timeHours = 2.0 / 3600.0;
              if (distanceMeters > 0.5) {
                speedMph = distanceMiles / timeHours;
              }
            }

            if (speedMph > 150) speedMph = currentSpeed;

            // Calculate distance from last position (same as web)
            double segmentDistance = 0.0;
            if (lastPosition != null) {
              double distanceMeters = Geolocator.distanceBetween(
                lastPosition!.latitude, lastPosition!.longitude,
                position.latitude, position.longitude,
              );
              segmentDistance = distanceMeters * 0.000621371; // Convert meters to miles

              // Only add distance if movement is significant (filter GPS drift)
              if (segmentDistance > 0.001) { // Minimum 5.3 feet
                _totalDistance += segmentDistance;
              }
            }

            // UPDATE UI - THIS WORKS! (same as web)
            setState(() {
              currentSpeed = speedMph;
              if (speedMph > maxSpeed) maxSpeed = speedMph;
              _pointCounter++;
            });

            lastPosition = position;

            // Save distance to SharedPreferences
            await prefs.setDouble('total_distance', _totalDistance);

            // Calculate and store deltas
            if (userDataJson != null) {
              Map<String, dynamic> userData = json.decode(userDataJson);
              if (userData['base_point'] != null) {
                double baseLat = (userData['base_point']['latitude'] ?? 0.0).toDouble();
                double baseLon = (userData['base_point']['longitude'] ?? 0.0).toDouble();

                int deltaLat = ((position.latitude - baseLat) * 1000000).round();
                int deltaLon = ((position.longitude - baseLon) * 1000000).round();

                _webDeltaPoints.add({
                  'dlat': deltaLat,
                  'dlon': deltaLon,
                  'dt': 2000,
                  't': DateTime.now().toIso8601String(),
                  'p': _pointCounter,
                  'speed_mph': speedMph,
                  'accuracy': position.accuracy,
                  'speed_source': usedGpsSpeed ? 'gps' : 'calculated',
                });

                print('📊 Point #$_pointCounter - Delta: ($deltaLat, $deltaLon), Speed: ${speedMph.toStringAsFixed(1)} mph');
                print('📊 Buffer: ${_webDeltaPoints.length}/25 points');

                // Send batch at 25 points
                if (_webDeltaPoints.length >= 25) {
                  print('📤 Batch ready - sending to server');
                  await _sendWebBatchToServer(prefs, userId, tripId);
                  setState(() {
                    _batchCounter++;
                  });
                  await prefs.setInt('batch_counter', _batchCounter);
                }
              }
            }

          } catch (e) {
            print('❌ GPS error: $e');
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip started! GPS tracking active.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      print('❌ Invalid location permission: $permission');
      print('   Platform: ${kIsWeb ? "Web" : "Mobile"}');

      String message = kIsWeb
          ? 'Please allow location access in your browser to track trips.'
          : 'Please grant "Always" location permission in Settings to track your trips.';

      _showErrorDialog(
        'Location Permission Required',
        message,
      );
    }
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
      print('🌐 ========== STOPPING WEB TRACKING ==========');

      // Send any remaining delta points before stopping
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataJson = prefs.getString('user_data');
      String? tripId = prefs.getString('current_trip_id');

      if (_webDeltaPoints.isNotEmpty && userDataJson != null && tripId != null) {
        Map<String, dynamic> userData = json.decode(userDataJson);
        String userId = userData['user_id'] ?? '';

        print('📤 Sending final batch with ${_webDeltaPoints.length} remaining points');
        await _sendWebBatchToServer(prefs, userId, tripId);
        // Increment batch counter for the final incomplete batch
        setState(() {
          _batchCounter++;
        });
        await prefs.setInt('batch_counter', _batchCounter);
      }

      print('🌐 Web tracking stopped');
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
          'actual_distance_miles': _totalDistance, // FIXED: Use accurate distance
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
                _totalDistance = 0.0; // Reset distance
                _batchCounter = 0; // Reset batch counter
                lastPosition = null;
                _webDeltaPoints.clear(); // Clear web delta buffer
                _webBatchCounter = 0; // Reset batch counter
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

  Future<void> _sendWebBatchToServer(SharedPreferences prefs, String userId, String tripId) async {
    print('🌐 ========== SENDING WEB BATCH TO SERVER ==========');

    _webBatchCounter++;
    int batchNumber = _webBatchCounter;

    print('👤 User ID: $userId');
    print('🚗 Trip ID: $tripId');
    print('📦 Batch number: $batchNumber');
    print('📊 Delta points: ${_webDeltaPoints.length}');

    // Transform delta points to match backend format
    List<Map<String, dynamic>> deltas = [];
    for (int i = 0; i < _webDeltaPoints.length; i++) {
      var point = _webDeltaPoints[i];

      deltas.add({
        'delta_lat': point['dlat'],
        'delta_long': point['dlon'],
        'delta_time': point['dt'].toDouble(),
        'timestamp': point['t'],
        'sequence': point['p'],
        'speed_mph': point['speed_mph'],
        'speed_source': point['speed_source'] ?? 'calculated',
        'speed_confidence': point['speed_source'] == 'gps' ? 0.95 : 0.7,
        'gps_accuracy': point['accuracy'] ?? 5.0,
        'is_stationary': point['speed_mph'] < 2.0,
        'data_quality': point['accuracy'] != null && point['accuracy'] < 10 ? 'high' : 'medium',
      });
    }

    // Prepare batch data matching backend format
    Map<String, dynamic> data = {
      'user_id': userId,
      'trip_id': tripId,
      'batch_number': batchNumber,
      'batch_size': deltas.length,
      'first_point_timestamp': _webDeltaPoints.isNotEmpty ? _webDeltaPoints.last['t'] : DateTime.now().toIso8601String(),
      'last_point_timestamp': _webDeltaPoints.isNotEmpty ? _webDeltaPoints.first['t'] : DateTime.now().toIso8601String(),
      'deltas': deltas,
      'quality_metrics': {
        'valid_points': deltas.length,
        'rejected_points': 0,
        'average_accuracy': 5.0,
        'speed_data_quality': 0.8,
        'gps_quality_score': 0.9,
      }
    };

    print('📡 Making HTTP POST request to backend...');
    print('🌐 Endpoint: $trajectoryEndpoint');

    try {
      final response = await http.post(
        Uri.parse(trajectoryEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      ).timeout(Duration(seconds: 30));

      print('📡 Response received: Status ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ ========== WEB BATCH UPLOADED SUCCESSFULLY ==========');
        print('✅ Batch #$batchNumber uploaded successfully');
        print('✅ Response body: ${response.body}');

        // Clear the batch after successful upload
        _webDeltaPoints.clear();
        print('📦 Buffer cleared, ready for next batch');
      } else {
        print('❌ ========== WEB BATCH UPLOAD FAILED ==========');
        print('❌ Batch upload failed: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('❌ ========== WEB BATCH UPLOAD ERROR ==========');
      print('❌ Batch upload error: $e');
      print('❌ Stack trace: $stackTrace');
    }

    print('🌐 ========== WEB BATCH SEND COMPLETE ==========');
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
      child: Column(
        children: [
          // First row
          Row(
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
            ],
          ),
          SizedBox(height: screenWidth * 0.03),
          // Second row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                Icons.straighten,
                'Distance',
                '${_totalDistance.toStringAsFixed(2)} mi',
                Colors.purple,
              ),
              _buildStatColumn(
                Icons.location_on,
                'Points',
                '$_pointCounter',
                Colors.orange,
              ),
              _buildStatColumn(
                Icons.cloud_upload,
                'Batches',
                '$_batchCounter',
                Colors.teal,
              ),
            ],
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
