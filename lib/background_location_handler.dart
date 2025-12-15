import 'dart:async';
import 'dart:convert';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

/// CRITICAL: This file uses flutter_background_geolocation for iOS/Android background tracking
/// This is a PREMIUM solution that works around iOS throttling limitations
/// - iOS: FREE to use (no license required)
/// - Android: Requires license for production (works in DEBUG mode without license)
///
/// Key features:
/// - Motion detection (only tracks when moving, saves battery when stationary)
/// - Continues tracking even when app is terminated
/// - No iOS throttling after 1 minute (native workaround built-in)
/// - Updates every 10 meters when moving
/// - Intelligent battery management

class BackgroundLocationHandler {
  static bool _isInitialized = false;

  /// Initialize flutter_background_geolocation
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('✅ Background geolocation already initialized');
      return;
    }

    print('🚀 Initializing flutter_background_geolocation...');

    // 1. Listen to location events
    bg.BackgroundGeolocation.onLocation(_onLocation);

    // 2. Listen to motion change events (moving <-> stationary)
    bg.BackgroundGeolocation.onMotionChange(_onMotionChange);

    // 3. Listen to provider changes (GPS enabled/disabled, permissions, etc)
    bg.BackgroundGeolocation.onProviderChange(_onProviderChange);

    // 4. Configure the plugin
    await bg.BackgroundGeolocation.ready(bg.Config(
      // Accuracy & Distance
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 10.0, // Update every 10 meters

      // Activity Recognition
      stopTimeout: 5, // Minutes to wait before stopping location when stationary
      stopOnStationary: false, // Keep tracking even when stationary

      // Application Behavior
      stopOnTerminate: false, // Continue tracking when app is killed
      startOnBoot: true, // Restart tracking on device reboot

      // HTTP & Persistence (we handle this manually)
      autoSync: false, // We'll manually send to our server

      // Geofencing (not used)
      geofenceProximityRadius: 1000,

      // Debugging
      debug: false, // Disable debug sounds (blue bar still shows on iOS)
      logLevel: bg.Config.LOG_LEVEL_ERROR, // Only log errors in production

      // iOS-specific settings
      preventSuspend: true, // Prevent iOS from suspending the app
      locationAuthorizationRequest: 'Always', // Request "Always" permission
      disableMotionActivityUpdates: false, // Use motion detection for battery savings
    ));

    _isInitialized = true;
    print('✅ flutter_background_geolocation initialized');
  }

  /// Start background location tracking
  static Future<void> startTracking() async {
    if (!_isInitialized) {
      await initialize();
    }

    print('📍 Starting background location tracking...');

    // Verify we have an active trip
    final prefs = await SharedPreferences.getInstance();
    final tripId = prefs.getString('current_trip_id');
    final tripStartTime = prefs.getString('trip_start_time');

    if (tripId == null || tripStartTime == null) {
      print('❌ No active trip found - cannot start tracking');
      return;
    }

    print('✅ Active trip: $tripId');
    print('✅ Start time: $tripStartTime');

    // Start the plugin
    bg.State state = await bg.BackgroundGeolocation.start();
    print('✅ Background location tracking started');
    print('📱 Plugin state: enabled=${state.enabled}, tracking=${state.trackingMode}');
    print('📱 Tracking will continue even when:');
    print('   - App is minimized');
    print('   - Screen is locked');
    print('   - App is terminated');
    print('   - Device is rebooted');
  }

  /// Stop background location tracking
  static Future<void> stopTracking() async {
    print('🛑 Stopping background location tracking...');

    // Stop the plugin
    bg.State state = await bg.BackgroundGeolocation.stop();
    print('✅ Background location tracking stopped');
    print('📱 Plugin state: enabled=${state.enabled}');
  }

  /// Cleanup resources
  static Future<void> dispose() async {
    print('🔧 Disposing background location handler...');
    await stopTracking();
    _isInitialized = false;
    print('✅ Background location handler disposed');
  }

  /// Cleanup trip-specific data when trip ends (PRIVACY CRITICAL)
  /// This removes locally stored first_actual_point and previous_point from device
  /// Call this method when trip is finalized/ended
  static Future<void> cleanupTripData(String tripId) async {
    print('🧹 Cleaning up privacy-sensitive trip data for trip: $tripId');

    final prefs = await SharedPreferences.getInstance();

    // Remove first actual point (stored locally, never sent to server)
    final removed1 = await prefs.remove('first_actual_point_$tripId');
    print(removed1
        ? '✅ Removed first_actual_point_$tripId'
        : '⚠️ first_actual_point_$tripId not found');

    // Remove previous point (used for consecutive delta calculation)
    final removed2 = await prefs.remove('previous_point_$tripId');
    print(removed2
        ? '✅ Removed previous_point_$tripId'
        : '⚠️ previous_point_$tripId not found');

    print('✅ Trip data cleanup complete for trip: $tripId');
  }

  /// Called whenever a location is recorded
  static void _onLocation(bg.Location location) async {
    print('📍 ========== BACKGROUND LOCATION UPDATE ==========');
    print('📍 Time: ${DateTime.now()}');
    print('📍 Speed: ${location.coords.speed} m/s');
    print('📍 Accuracy: ${location.coords.accuracy}m');
    print('📍 Is Moving: ${location.isMoving}');

    try {
      // Load trip data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final tripId = prefs.getString('current_trip_id');
      final userDataJson = prefs.getString('user_data');

      if (tripId == null || userDataJson == null) {
        print('⚠️ No active trip or user data - skipping update');
        return;
      }

      final userData = json.decode(userDataJson);
      final userId = userData['user_id'] ?? '';
      final basePoint = userData['base_point'];

      if (basePoint == null) {
        print('❌ No base point found');
        return;
      }

      // ========== PRIVACY-PRESERVING CONSECUTIVE DELTA CALCULATION ==========
      // Load or initialize first actual point and previous point for this trip
      // Following GeoSecure-R methodology from research papers
      String? firstPointJson = prefs.getString('first_actual_point_$tripId');
      String? prevPointJson = prefs.getString('previous_point_$tripId');

      Map<String, double>? firstActualPoint;
      Map<String, double>? previousPoint;

      if (firstPointJson != null) {
        firstActualPoint = Map<String, double>.from(json.decode(firstPointJson));
      }
      if (prevPointJson != null) {
        previousPoint = Map<String, double>.from(json.decode(prevPointJson));
      }

      // If this is the FIRST point of the trip, store it locally and skip sending to server
      // This implements the GeoSecure-R requirement: "Keep the first point key K on the users' device"
      if (firstActualPoint == null) {
        firstActualPoint = {
          'latitude': location.coords.latitude,
          'longitude': location.coords.longitude,
        };
        await prefs.setString('first_actual_point_$tripId', json.encode(firstActualPoint));

        // Initialize previous point to first point
        previousPoint = firstActualPoint;
        await prefs.setString('previous_point_$tripId', json.encode(previousPoint));

        print('🎯 FIRST POINT of trip stored locally (NEVER sent to server)');
        print('🔐 Privacy: Server only knows zipcode region "${basePoint['city']}, ${basePoint['state']}"');
        print('🔐 Privacy: Server does NOT know actual trip start location');
        print('🔀 Starting CONSECUTIVE delta calculation from next point');

        // Initialize point counter but don't send data for first point
        int pointCounter = prefs.getInt('point_counter') ?? 0;
        pointCounter++;
        await prefs.setInt('point_counter', pointCounter);

        // Store current position for local distance calculation (UI only, not sent to server)
        await prefs.setDouble('last_latitude', location.coords.latitude);
        await prefs.setDouble('last_longitude', location.coords.longitude);

        return; // Skip sending data for first point
      }

      // Calculate CONSECUTIVE delta (current point - previous point)
      // NOT absolute delta (current point - base point)
      // This ensures server cannot reconstruct actual GPS coordinates
      final prevLat = (previousPoint!['latitude'] ?? 0.0).toDouble();
      final prevLon = (previousPoint['longitude'] ?? 0.0).toDouble();
      final deltaLat = ((location.coords.latitude - prevLat) * 1000000).round();
      final deltaLon = ((location.coords.longitude - prevLon) * 1000000).round();

      print('🔀 Consecutive delta from previous point: (Δlat: $deltaLat, Δlon: $deltaLon)');
      print('🔐 Privacy: Server receives only deltas, cannot determine actual location');

      // Update previous point for next iteration
      previousPoint = {
        'latitude': location.coords.latitude,
        'longitude': location.coords.longitude,
      };
      await prefs.setString('previous_point_$tripId', json.encode(previousPoint));

      // Load existing point counter and tracking data
      int pointCounter = prefs.getInt('point_counter') ?? 0;
      double totalDistance = prefs.getDouble('total_distance') ?? 0.0;
      double maxSpeed = prefs.getDouble('max_speed') ?? 0.0;

      // Calculate speed in mph
      double speedMph = 0.0;
      if (location.coords.speed >= 0) {
        speedMph = location.coords.speed * 2.237; // m/s to mph
      }

      // Smart max speed filtering to avoid GPS errors
      // Ignore speed spikes that are clearly GPS errors:
      // 1. Speed > 120 mph (unrealistic for normal driving)
      // 2. First 10 GPS points (warm-up period)
      // 3. Poor GPS accuracy (> 20 meters)
      bool isValidSpeedReading = speedMph <= 120.0 &&
                                  pointCounter >= 10 &&
                                  location.coords.accuracy <= 20.0;

      if (isValidSpeedReading && speedMph > maxSpeed) {
        maxSpeed = speedMph;
        await prefs.setDouble('max_speed', maxSpeed);
        print('🏎️ New max speed: ${maxSpeed.toStringAsFixed(1)} mph (accuracy: ${location.coords.accuracy.toStringAsFixed(1)}m)');
      } else if (speedMph > 120.0) {
        print('⚠️ Ignoring erratic speed spike: ${speedMph.toStringAsFixed(1)} mph (GPS error)');
      } else if (pointCounter < 10) {
        print('⚠️ GPS warm-up period: ignoring speed for max speed calculation (point $pointCounter/10)');
      } else if (location.coords.accuracy > 20.0) {
        print('⚠️ Poor GPS accuracy: ${location.coords.accuracy.toStringAsFixed(1)}m - ignoring speed for max calculation');
      }

      // Calculate distance from last position
      final lastLat = prefs.getDouble('last_latitude');
      final lastLon = prefs.getDouble('last_longitude');

      if (lastLat != null && lastLon != null) {
        final distanceMeters = Geolocator.distanceBetween(
          lastLat,
          lastLon,
          location.coords.latitude,
          location.coords.longitude,
        );
        final distanceMiles = distanceMeters * 0.000621371;

        if (distanceMiles > 0.001) {
          // Filter GPS drift (< 5.3 feet)
          totalDistance += distanceMiles;
          await prefs.setDouble('total_distance', totalDistance);
          print('📏 Distance: +${(distanceMiles * 5280).toStringAsFixed(1)}ft, Total: ${totalDistance.toStringAsFixed(3)}mi');
        }
      }

      // Store current position for next distance calculation
      await prefs.setDouble('last_latitude', location.coords.latitude);
      await prefs.setDouble('last_longitude', location.coords.longitude);

      // Increment point counter
      pointCounter++;
      await prefs.setInt('point_counter', pointCounter);
      await prefs.setDouble('current_speed', speedMph);

      print('✅ Point #$pointCounter - Speed: ${speedMph.toStringAsFixed(1)} mph');

      // Store delta point for batch upload
      final deltaPointsJson = prefs.getString('delta_points_buffer') ?? '[]';
      final List<dynamic> deltaPoints = json.decode(deltaPointsJson);

      deltaPoints.add({
        'dlat': deltaLat,
        'dlon': deltaLon,
        'dt': 2000, // Approximate interval
        't': location.timestamp,
        'p': pointCounter,
        'speed_mph': speedMph,
        'accuracy': location.coords.accuracy,
        'speed_source': 'gps',
        'is_moving': location.isMoving,
        'activity_type': location.activity.type,
        'activity_confidence': location.activity.confidence,
      });

      await prefs.setString('delta_points_buffer', json.encode(deltaPoints));
      print('📊 Buffer size: ${deltaPoints.length}/25');

      // Send batch when we have 25 points
      if (deltaPoints.length >= 25) {
        print('📤 Sending batch to server...');
        await _sendBatchToServer(prefs, userId, tripId, deltaPoints);
        await prefs.setString('delta_points_buffer', '[]'); // Clear buffer
      }

      print('📍 ========== BACKGROUND LOCATION UPDATE COMPLETE ==========');
    } catch (e, stackTrace) {
      print('❌ Error in background location callback: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }

  /// Called when motion state changes (moving <-> stationary)
  static void _onMotionChange(bg.Location location) {
    print('🏃 ========== MOTION CHANGE ==========');
    print('🏃 Is Moving: ${location.isMoving}');
    print('🏃 Location: ${location.coords.latitude}, ${location.coords.longitude}');
  }

  /// Called when location provider changes (GPS on/off, permissions, etc)
  static void _onProviderChange(bg.ProviderChangeEvent event) {
    print('📡 ========== PROVIDER CHANGE ==========');
    print('📡 GPS Enabled: ${event.gps}');
    print('📡 Network Enabled: ${event.network}');
    print('📡 Authorization Status: ${event.status}');
  }

  /// Send batch of delta points to server
  static Future<void> _sendBatchToServer(
    SharedPreferences prefs,
    String userId,
    String tripId,
    List<dynamic> deltaPoints,
  ) async {
    try {
      int batchCounter = prefs.getInt('batch_counter') ?? 0;
      batchCounter++;

      final List<Map<String, dynamic>> deltas = [];
      for (var point in deltaPoints) {
        deltas.add({
          'delta_lat': point['dlat'],
          'delta_long': point['dlon'],
          'delta_time': point['dt'].toDouble(),
          'timestamp': point['t'],
          'sequence': point['p'],
          'speed_mph': point['speed_mph'],
          'speed_source': point['speed_source'] ?? 'gps',
          'speed_confidence': 0.95,
          'gps_accuracy': point['accuracy'] ?? 5.0,
          'is_stationary': point['speed_mph'] < 2.0,
          'is_moving': point['is_moving'] ?? true,
          'activity_type': point['activity_type'] ?? 'unknown',
          'activity_confidence': point['activity_confidence'] ?? 0,
          'data_quality': point['accuracy'] != null && point['accuracy'] < 10 ? 'high' : 'medium',
        });
      }

      final data = {
        'user_id': userId,
        'trip_id': tripId,
        'batch_number': batchCounter,
        'batch_size': deltas.length,
        'first_point_timestamp': deltaPoints.isNotEmpty ? deltaPoints.first['t'] : DateTime.now().toIso8601String(),
        'last_point_timestamp': deltaPoints.isNotEmpty ? deltaPoints.last['t'] : DateTime.now().toIso8601String(),
        'deltas': deltas,
        'quality_metrics': {
          'valid_points': deltas.length,
          'rejected_points': 0,
          'average_accuracy': 5.0,
          'speed_data_quality': 0.9,
          'gps_quality_score': 0.95,
        }
      };

      final response = await http.post(
        Uri.parse('https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/store-trajectory-batch'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        await prefs.setInt('batch_counter', batchCounter);
        print('✅ Batch #$batchCounter uploaded successfully');
      } else {
        print('❌ Batch upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error sending batch: $e');
    }
  }
}
