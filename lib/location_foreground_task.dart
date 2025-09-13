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
                if (_deltaPoints.length >= 6) {
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
        final token = prefs.getString('access_token');
        final String url = '${AppConfig.server}/points';

        Map<String, dynamic> data = {
            'isStart': false,
            'start_time': DateTime.now().toIso8601String(),
            'elapsed_time': 0,
            'delta_points': _deltaPoints,
            'isEnd': false,
        };

        await http.post(
                Uri.parse(url),
                headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
                },
body: json.encode(data),
);
    }

    @override
        Future<void> onDestroy(DateTime timestamp, bool thing) async {
            _timer?.cancel();
        }

    @override
        void onButtonPressed(String id) {}

    @override
        void onNotificationPressed() {
            FlutterForegroundTask.launchApp();
        }
}

