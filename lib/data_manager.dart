import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DataManager {
  static Map<String, dynamic>? _cachedAnalytics;
  static DateTime? _lastFetchTime;
  static String? _cachedUserId; // 🔐 SECURITY FIX: Track which user's data is cached
  static const Duration _cacheValidity = Duration(hours: 1); // Cache for 1 hour

  static Future<Map<String, dynamic>?> getDriverAnalytics({bool forceRefresh = false}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataJson = prefs.getString('user_data');

      if (userDataJson == null) return null;

      Map<String, dynamic> userData = json.decode(userDataJson);
      String userEmail = userData['email'] ?? '';
      String userId = userData['user_id'] ?? '';

      if (userEmail.isEmpty) return null;

      // 🔐 CRITICAL FIX: Check if cached data belongs to current user
      // If user changed, clear cache immediately to prevent data leakage
      if (_cachedUserId != null && _cachedUserId != userId) {
        print('⚠️ User changed (cached: $_cachedUserId, current: $userId) - clearing cache');
        clearCache();
      }

      // Return cached data if valid and not forcing refresh AND same user
      if (!forceRefresh &&
          _cachedAnalytics != null &&
          _lastFetchTime != null &&
          _cachedUserId == userId &&
          DateTime.now().difference(_lastFetchTime!) < _cacheValidity) {
        print('📦 Using cached analytics for user: $userId');
        return _cachedAnalytics;
      }
      
      print('🌐 Fetching analytics for user: $userId');
      final response = await http.get(
        Uri.parse('https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/analyze-driver?email=$userEmail'),
      );

      if (response.statusCode == 200) {
        _cachedAnalytics = json.decode(response.body);
        _lastFetchTime = DateTime.now();
        _cachedUserId = userId; // 🔐 SECURITY FIX: Store which user this cache belongs to

        // Also save to SharedPreferences for persistence
        await prefs.setString('cached_analytics', json.encode(_cachedAnalytics));
        await prefs.setString('analytics_cache_time', _lastFetchTime!.toIso8601String());
        await prefs.setString('analytics_cache_user_id', userId); // 🔐 Save user_id with cache

        print('✅ Analytics cached for user: $userId');
        return _cachedAnalytics;
      } else {
        print('❌ Failed to fetch analytics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching analytics: $e');

      // Try to load from persistent cache if network fails
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cached = prefs.getString('cached_analytics');
      String? cachedUserId = prefs.getString('analytics_cache_user_id');
      String? userDataJson = prefs.getString('user_data');

      // 🔐 SECURITY FIX: Validate cached data belongs to current user
      if (cached != null && userDataJson != null) {
        Map<String, dynamic> userData = json.decode(userDataJson);
        String currentUserId = userData['user_id'] ?? '';

        if (cachedUserId == currentUserId) {
          print('📦 Using persistent cache for user: $currentUserId');
          _cachedAnalytics = json.decode(cached);
          _cachedUserId = currentUserId;
          return _cachedAnalytics;
        } else {
          print('⚠️ Persistent cache belongs to different user - ignoring');
        }
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
    print('🧹 Clearing DataManager cache');
    _cachedAnalytics = null;
    _lastFetchTime = null;
    _cachedUserId = null; // 🔐 SECURITY FIX: Clear cached user ID
  }
}