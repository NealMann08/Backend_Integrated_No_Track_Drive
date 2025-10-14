import 'dart:async';
import 'dart:convert';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'ipconfig.dart';
import 'dart:isolate';


class LocationTaskHandler extends TaskHandler {

    Timer? _timer;
    int? _prevLat, _prevLon;
    int _counter = 0;
    final List<Map<String, dynamic>> _deltaPoints = [];

    @override
    Future<void> onStart(DateTime timestamp, TaskStarter task) async {
        print("event in onstart");
    }

    @override 
    void onRepeatEvent(DateTime timestamp) async {
        await onEvent(timestamp, null);
    }

    @override
        Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
            print("event triggered");
            Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high);

            int lat = (position.latitude * 1000000).toInt();
            int lon = (position.longitude * 1000000).toInt();

            if (_prevLat != null && _prevLon != null) {
                _deltaPoints.insert(0, {
                        'dlat': lat - _prevLat!,
                        'dlon': lon - _prevLon!,
                        't': DateTime.now().toIso8601String(),
                        'p': _counter++,
                        });

                // Send to server every 30 seconds
                if (_deltaPoints.length >= 24) {
                    print("sending data to server");
                    await _sendToServer();
                    _deltaPoints.clear();
                }
            }

            _prevLat = lat;
            _prevLon = lon;
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
    
    // Transform delta points to match your backend format
    List<Map<String, dynamic>> deltas = _deltaPoints.map((point) {
      return {
        'delta_lat': point['dlat'],
        'delta_long': point['dlon'],
        'delta_time': 5.0, // 5.0 seconds (float)
        'timestamp': point['t'],
        'sequence': point['p'],
        'speed_mph': 0.0, // Background doesn't have speed tracking
        'speed_confidence': 0.5,
        'gps_accuracy': 5.0,
        'is_stationary': false,
        'data_quality': 'medium'
      };
    }).toList();
    
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
    }

    @override
        void onButtonPressed(String id) {}

    @override
        void onNotificationPressed() {
            FlutterForegroundTask.launchApp();
        }
}

