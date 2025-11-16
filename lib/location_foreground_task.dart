import 'dart:async';
import 'dart:convert';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'ipconfig.dart';
import 'dart:isolate';


class LocationTaskHandler extends TaskHandler {
    Map<String, dynamic>? _basePoint;
    DateTime? _lastPointTime;
    double? _prevLatActual, _prevLonActual;  // For speed calculation

    Timer? _timer;
    int? _prevLat, _prevLon;
    int _counter = 0;
    final List<Map<String, dynamic>> _deltaPoints = [];

    @override
    Future<void> onStart(DateTime timestamp, TaskStarter task) async {
        print("Loading user base point for delta calculations...");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userDataJson = prefs.getString('user_data');
        
        if (userDataJson != null) {
            Map<String, dynamic> userData = json.decode(userDataJson);
            if (userData['base_point'] != null) {
                _basePoint = userData['base_point'];
                print("Base point loaded: ${_basePoint!['city']}, ${_basePoint!['state']}");
                print("Base coordinates: ${_basePoint!['latitude']}, ${_basePoint!['longitude']}");
            } else {
                print("WARNING: No base point found in user data!");
            }
        }
        _lastPointTime = DateTime.now();
        // Enable iOS background location updates
        await Geolocator.requestPermission();
        
        // iOS-specific: Request always permission for background
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission != LocationPermission.always) {
            print("WARNING: Background tracking requires 'Always' location permission on iOS");
        }
    }

    @override 
    void onRepeatEvent(DateTime timestamp) async {
        await onEvent(timestamp, null);
    }

    @override
    Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
        print("📍 Location event triggered at ${DateTime.now().toIso8601String()}");
        
        if (_basePoint == null) {
            print("❌ ERROR: No base point available, cannot calculate deltas!");
            return;
        }
        
        try {
            // Add timeout to prevent hanging
            Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
            ).timeout(Duration(seconds: 10));
            
            print("✅ Got position: ${position.latitude}, ${position.longitude}, speed: ${position.speed}");
            
            DateTime now = DateTime.now();
            
            // Calculate time difference in milliseconds
            int deltaTimeMs = _lastPointTime != null ? 
                now.difference(_lastPointTime!).inMilliseconds : 1000;
            
            // Get base point coordinates
            double baseLat = (_basePoint!['latitude'] ?? 0.0).toDouble();
            double baseLon = (_basePoint!['longitude'] ?? 0.0).toDouble();
            
            print("📐 Base point: lat=$baseLat, lon=$baseLon");
            
            // Calculate deltas relative to base point (multiply by 1,000,000 for fixed-point)
            int deltaLat = ((position.latitude - baseLat) * 1000000).round();
            int deltaLon = ((position.longitude - baseLon) * 1000000).round();
            
            // Calculate speed
            double speedMph = 0.0;
            if (position.speed != null && position.speed! >= 0) {
                speedMph = position.speed! * 2.237; // Convert m/s to mph
                print("📊 Using GPS speed: ${speedMph.toStringAsFixed(1)} mph");
            } else if (_prevLatActual != null && _prevLonActual != null) {
                double distance = Geolocator.distanceBetween(
                    _prevLatActual!, _prevLonActual!,
                    position.latitude, position.longitude
                ) * 0.000621371; // meters to miles
                double timeHours = deltaTimeMs / 3600000.0; // ms to hours
                if (timeHours > 0) speedMph = distance / timeHours;
                print("📊 Calculated speed: ${speedMph.toStringAsFixed(1)} mph");
            }
            
            _deltaPoints.insert(0, {
                'dlat': deltaLat,
                'dlon': deltaLon,
                'dt': deltaTimeMs,
                't': now.toIso8601String(),
                'p': _counter++,
                'speed_mph': speedMph,
                'gps_speed': position.speed,
                'accuracy': position.accuracy,
            });
            
            // Update point counter in SharedPreferences for UI
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setInt('point_counter', _counter);
            await prefs.setDouble('current_speed', speedMph);

            // Track max speed
            double storedMaxSpeed = prefs.getDouble('max_speed') ?? 0.0;
            if (speedMph > storedMaxSpeed) {
              await prefs.setDouble('max_speed', speedMph);
              print("🏁 New max speed: ${speedMph.toStringAsFixed(1)} mph");
            }
            
            print("✅ Delta calculated - Lat: $deltaLat, Lon: $deltaLon, Time: ${deltaTimeMs}ms, Speed: ${speedMph.toStringAsFixed(1)}mph, Points: $_counter");
            
            // Store for next calculation
            _prevLatActual = position.latitude;
            _prevLonActual = position.longitude;
            _lastPointTime = now;
            
            // Send batch when we have 25 points
            if (_deltaPoints.length >= 25) {
                print("📤 Batch ready - sending ${_deltaPoints.length} points to server");
                await _sendToServer();
                _deltaPoints.clear();
            }
            
        } catch (e, stackTrace) {
            print("❌ Error in location event: $e");
            print("Stack trace: $stackTrace");
            
            // Handle timeout specifically
            if (e.toString().contains('TimeoutException')) {
                print("⏰ GPS timeout - device may be indoors or GPS is warming up");
            }
        }
    }

    Future<void> _sendToServer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('user_data');
    
    if (userDataJson == null) {
      print('Background: No user data found');
      return;
    }
    
    Map<String, dynamic> userData = json.decode(userDataJson);
    String userId = userData['user_id'] ?? '';
    
    // Get or create trip ID
    String? tripId = prefs.getString('current_trip_id');
    if (tripId == null || tripId.isEmpty) {
      print('Background: No active trip ID found');
      return;
    }
    
    // Get batch number from stored counter
    int batchNumber = prefs.getInt('batch_counter') ?? 0;
    batchNumber++;
    await prefs.setInt('batch_counter', batchNumber);
    
    // Transform delta points to match backend format
    List<Map<String, dynamic>> deltas = [];
    for (int i = 0; i < _deltaPoints.length; i++) {
      var point = _deltaPoints[i];
      
      deltas.add({
        'delta_lat': point['dlat'],        // Already in fixed-point integer
        'delta_long': point['dlon'],       // Already in fixed-point integer
        'delta_time': point['dt'].toDouble(), // Convert to double for backend
        'timestamp': point['t'],
        'sequence': point['p'],
        'speed_mph': point['speed_mph'],
        'speed_confidence': point['gps_speed'] != null ? 0.9 : 0.6,
        'gps_accuracy': point['accuracy'] ?? 5.0,
        'is_stationary': point['speed_mph'] < 2.0,
        'data_quality': 'high',
        'raw_speed_ms': point['gps_speed']
      });
    }
    
    // Prepare batch data matching your backend format
    Map<String, dynamic> data = {
      'user_id': userId,
      'trip_id': tripId,
      'batch_number': batchNumber,
      'batch_size': deltas.length,
      'first_point_timestamp': _deltaPoints.isNotEmpty ? _deltaPoints.last['t'] : DateTime.now().toIso8601String(),
      'last_point_timestamp': _deltaPoints.isNotEmpty ? _deltaPoints.first['t'] : DateTime.now().toIso8601String(),
      'deltas': deltas,
      'quality_metrics': {
        'valid_points': deltas.length,
        'rejected_points': 0,
        'average_accuracy': 5.0,
        'speed_data_quality': 0.5,
        'gps_quality_score': 0.8,
      }
    };
    
    print('🚀 Background: Sending batch #$batchNumber with ${deltas.length} deltas');
    
    try {
      final response = await http.post(
        Uri.parse('https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/store-trajectory-batch'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );
      
      if (response.statusCode == 200) {
        print('Background: Batch uploaded successfully');
      } else {
        print('Background: Batch upload failed: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Background: Batch upload error: $e');
    }
}

    @override
    Future<void> onDestroy(DateTime timestamp) async {
        _timer?.cancel();
        print('Background service destroyed');
    }

    @override
        void onButtonPressed(String id) {}

    @override
        void onNotificationPressed() {
            FlutterForegroundTask.launchApp();
        }
}

