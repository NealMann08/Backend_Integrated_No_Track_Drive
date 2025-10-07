import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DataManager {
  static Map<String, dynamic>? _cachedAnalytics;
  static DateTime? _lastFetchTime;
  static const Duration _cacheValidity = Duration(hours: 1); // Cache for 1 hour
  
  static Future<Map<String, dynamic>?> getDriverAnalytics({bool forceRefresh = false}) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && 
        _cachedAnalytics != null && 
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheValidity) {
      return _cachedAnalytics;
    }
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataJson = prefs.getString('user_data');
      
      if (userDataJson == null) return null;
      
      Map<String, dynamic> userData = json.decode(userDataJson);
      String userEmail = userData['email'] ?? '';
      
      if (userEmail.isEmpty) return null;
      
      final response = await http.get(
        Uri.parse('https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/analyze-driver?email=$userEmail'),
      );
      
      if (response.statusCode == 200) {
        _cachedAnalytics = json.decode(response.body);
        _lastFetchTime = DateTime.now();
        
        // Also save to SharedPreferences for persistence
        await prefs.setString('cached_analytics', json.encode(_cachedAnalytics));
        await prefs.setString('analytics_cache_time', _lastFetchTime!.toIso8601String());
        
        return _cachedAnalytics;
      }
    } catch (e) {
      print('Error fetching analytics: $e');
      
      // Try to load from persistent cache if network fails
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cached = prefs.getString('cached_analytics');
      if (cached != null) {
        _cachedAnalytics = json.decode(cached);
        return _cachedAnalytics;
      }
    }
    
    return null;
  }
  
  // Preload data when user logs in
  static Future<void> preloadData() async {
    await getDriverAnalytics(forceRefresh: true);
  }
  
  // Clear cache on logout
  static void clearCache() {
    _cachedAnalytics = null;
    _lastFetchTime = null;
  }
}