/*
 * Data Manager
 *
 * Handles caching of driver analytics data to reduce API calls and improve
 * app performance. This was a big optimization because the analytics endpoint
 * takes a while to respond, and we don't want users waiting every time they
 * switch screens.
 *
 * Important security note: The cache is tied to a specific user ID to prevent
 * data leakage when switching accounts on a shared device.
 */

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DataManager {
  // In-memory cache for quick access
  static Map<String, dynamic>? _cachedAnalytics;
  static DateTime? _lastFetchTime;
  static String? _cachedUserId;

  // How long to keep cached data before refreshing
  static const Duration _cacheValidity = Duration(hours: 1);

  /// Fetches driver analytics from the backend, using cache when possible
  /// Set forceRefresh to true to bypass cache and get fresh data
  static Future<Map<String, dynamic>?> getDriverAnalytics({bool forceRefresh = false}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataJson = prefs.getString('user_data');

      if (userDataJson == null) return null;

      Map<String, dynamic> userData = json.decode(userDataJson);
      String userEmail = userData['email'] ?? '';
      String userId = userData['user_id'] ?? '';

      if (userEmail.isEmpty) return null;

      // Security check: make sure cached data belongs to current user
      // This prevents showing another user's data if someone logs out/in
      if (_cachedUserId != null && _cachedUserId != userId) {
        clearCache();
      }

      // Use cache if it's still valid and belongs to current user
      if (!forceRefresh &&
          _cachedAnalytics != null &&
          _lastFetchTime != null &&
          _cachedUserId == userId &&
          DateTime.now().difference(_lastFetchTime!) < _cacheValidity) {
        return _cachedAnalytics;
      }

      // Fetch fresh data from the API
      final response = await http.get(
        Uri.parse('https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/analyze-driver?email=$userEmail'),
      );

      if (response.statusCode == 200) {
        _cachedAnalytics = json.decode(response.body);
        _lastFetchTime = DateTime.now();
        _cachedUserId = userId;

        // Save to persistent storage so it survives app restarts
        await prefs.setString('cached_analytics', json.encode(_cachedAnalytics));
        await prefs.setString('analytics_cache_time', _lastFetchTime!.toIso8601String());
        await prefs.setString('analytics_cache_user_id', userId);

        return _cachedAnalytics;
      }
    } catch (e) {
      // If network fails, try to use persistent cache as fallback
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cached = prefs.getString('cached_analytics');
      String? cachedUserId = prefs.getString('analytics_cache_user_id');
      String? userDataJson = prefs.getString('user_data');

      // Only use fallback cache if it belongs to current user
      if (cached != null && userDataJson != null) {
        Map<String, dynamic> userData = json.decode(userDataJson);
        String currentUserId = userData['user_id'] ?? '';

        if (cachedUserId == currentUserId) {
          _cachedAnalytics = json.decode(cached);
          _cachedUserId = currentUserId;
          return _cachedAnalytics;
        }
      }
    }

    return null;
  }

  /// Preloads data right after login so screens load faster
  static Future<void> preloadData() async {
    await getDriverAnalytics(forceRefresh: true);
  }

  /// Clears all cached data - call this on logout
  static void clearCache() {
    _cachedAnalytics = null;
    _lastFetchTime = null;
    _cachedUserId = null;
  }
}

