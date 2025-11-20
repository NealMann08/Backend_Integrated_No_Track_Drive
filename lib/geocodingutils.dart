// lib/geocoding_utils.dart
// Dart port of TypeScript geocoding utility for Zippopotam API

import 'dart:convert';
import 'package:http/http.dart' as http;

/// City coordinates returned from geocoding
class CityCoordinates {
  final double latitude;
  final double longitude;
  final String city;
  final String state;
  final String zipcode;
  final String source;

  CityCoordinates({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.state,
    required this.zipcode,
    required this.source,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'source': source,
    };
  }

  factory CityCoordinates.fromJson(Map<String, dynamic> json) {
    return CityCoordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      city: json['city'] as String,
      state: json['state'] as String,
      zipcode: json['zipcode'] as String,
      source: json['source'] as String,
    );
  }
}

/// Ultimate fallback coordinates (Beijing)
final CityCoordinates FALLBACK_COORDINATES = CityCoordinates(
  latitude: 39.913818,
  longitude: 116.363625,
  city: 'Beijing',
  state: 'CN',
  zipcode: '',
  source: 'fallback',
);

/// Validate US zipcode format (5 digits or 5+4 format)
bool validateZipcode(String zipcode) {
  final cleanZip = zipcode.trim();
  return RegExp(r'^\d{5}(-\d{4})?$').hasMatch(cleanZip);
}

/// Clean and normalize zipcode (remove +4 extension)
String normalizeZipcode(String zipcode) {
  return zipcode.trim().split('-')[0];
}

/// Geocode using Zippopotam.us API
Future<CityCoordinates?> _geocodeWithZippopotam(String zipcode) async {
  try {
    final normalizedZip = normalizeZipcode(zipcode);
    final url = 'http://api.zippopotam.us/us/$normalizedZip';
    
    print('🌐 Calling Zippopotam API for $zipcode');
    print('🌐 URL: $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    );

    print('🌐 Response status: ${response.statusCode}');

    if (response.statusCode != 200) {
      print('❌ API error: ${response.statusCode}');
      return null;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    print('📍 Raw API response: ${json.encode(data)}');
    
    if (data['places'] != null && (data['places'] as List).isNotEmpty) {
      final place = (data['places'] as List)[0] as Map<String, dynamic>;
      
      final result = CityCoordinates(
        latitude: double.parse(place['latitude'].toString()),
        longitude: double.parse(place['longitude'].toString()),
        city: place['place name'] as String,
        state: place['state abbreviation'] as String,
        zipcode: normalizedZip,
        source: 'zippopotam',
      );

      print('✅ Geocoding successful: ${result.city}, ${result.state}');
      return result;
    }

    print('❌ No places found for $zipcode');
    return null;

  } catch (error) {
    print('❌ Geocoding error for $zipcode: $error');
    return null;
  }
}

/// Main function: Get exact city center coordinates from zipcode
Future<CityCoordinates> getCityCoordinatesFromZipcode(String zipcode) async {
  print('\n🎯 ===== GETTING COORDINATES FOR ZIPCODE: $zipcode =====');

  // Step 1: Validate zipcode format
  if (!validateZipcode(zipcode)) {
    print('❌ Invalid zipcode format: $zipcode');
    return CityCoordinates(
      latitude: FALLBACK_COORDINATES.latitude,
      longitude: FALLBACK_COORDINATES.longitude,
      city: FALLBACK_COORDINATES.city,
      state: FALLBACK_COORDINATES.state,
      zipcode: zipcode,
      source: 'fallback',
    );
  }

  final normalizedZip = normalizeZipcode(zipcode);

  // Step 2: Get exact coordinates from Zippopotam API
  print('🔄 Looking up exact city center for $normalizedZip...');
  CityCoordinates? coordinates = await _geocodeWithZippopotam(normalizedZip);

  // Step 3: Use fallback if API fails
  if (coordinates == null) {
    print('⚠️ Could not find coordinates for zipcode $zipcode');
    print('🔄 Using Beijing fallback as last resort');
    coordinates = CityCoordinates(
      latitude: FALLBACK_COORDINATES.latitude,
      longitude: FALLBACK_COORDINATES.longitude,
      city: FALLBACK_COORDINATES.city,
      state: FALLBACK_COORDINATES.state,
      zipcode: normalizedZip,
      source: 'fallback',
    );
  }

  // PRIVACY: Do not log base coordinates
  print('✅ Final base point: ${coordinates.city}, ${coordinates.state}');
  return coordinates;
}

/// Calculate delta coordinates from actual GPS position and base point
/// Returns a map with delta_lat and delta_long as fixed-point integers (multiplied by 1,000,000)
Map<String, int> calculateDeltaCoordinates({
  required double actualLatitude,
  required double actualLongitude,
  required double baseLatitude,
  required double baseLongitude,
}) {
  // Calculate deltas and multiply by 1,000,000 for fixed-point precision
  int deltaLat = ((actualLatitude - baseLatitude) * 1000000).round();
  int deltaLong = ((actualLongitude - baseLongitude) * 1000000).round();

  return {
    'delta_lat': deltaLat,
    'delta_long': deltaLong,
  };
}

/// Reconstruct actual coordinates from delta coordinates and base point
/// Deltas should be fixed-point integers (multiplied by 1,000,000)
Map<String, double> reconstructCoordinates({
  required int deltaLat,
  required int deltaLong,
  required double baseLatitude,
  required double baseLongitude,
}) {
  // Divide by 1,000,000 to convert from fixed-point integers to decimals
  double actualLat = baseLatitude + (deltaLat / 1000000);
  double actualLong = baseLongitude + (deltaLong / 1000000);

  return {
    'latitude': actualLat,
    'longitude': actualLong,
  };
}

/// Format delta coordinates for display (privacy-safe)
String formatDeltaCoordinates(int deltaLat, int deltaLong) {
  return 'Δ(${deltaLat}, ${deltaLong})';
}