/*
 * Geocoding Utilities
 *
 * Converts US zip codes to latitude/longitude coordinates using the
 * free Zippopotam.us API. This is needed for the "base point" feature
 * which allows us to store GPS data as deltas from a reference point
 * for privacy (we never store the actual coordinates, just offsets).
 */

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Represents coordinates for a city/location
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

/// Default fallback coordinates if geocoding fails
final CityCoordinates FALLBACK_COORDINATES = CityCoordinates(
  latitude: 39.913818,
  longitude: 116.363625,
  city: 'Unknown',
  state: 'US',
  zipcode: '',
  source: 'fallback',
);

/// Validates that a string is a valid US zipcode format
bool validateZipcode(String zipcode) {
  final cleanZip = zipcode.trim();
  // Matches 5 digits or 5+4 format (12345 or 12345-6789)
  return RegExp(r'^\d{5}(-\d{4})?$').hasMatch(cleanZip);
}

/// Removes the +4 extension from a zipcode if present
String normalizeZipcode(String zipcode) {
  return zipcode.trim().split('-')[0];
}

/// Internal: Calls the Zippopotam API to get coordinates
Future<CityCoordinates?> _geocodeWithZippopotam(String zipcode) async {
  try {
    final normalizedZip = normalizeZipcode(zipcode);
    final url = 'http://api.zippopotam.us/us/$normalizedZip';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;

    if (data['places'] != null && (data['places'] as List).isNotEmpty) {
      final place = (data['places'] as List)[0] as Map<String, dynamic>;

      return CityCoordinates(
        latitude: double.parse(place['latitude'].toString()),
        longitude: double.parse(place['longitude'].toString()),
        city: place['place name'] as String,
        state: place['state abbreviation'] as String,
        zipcode: normalizedZip,
        source: 'zippopotam',
      );
    }

    return null;

  } catch (error) {
    return null;
  }
}

/// Main function: Gets coordinates for a US zipcode
/// Returns fallback coordinates if the API call fails
Future<CityCoordinates> getCityCoordinatesFromZipcode(String zipcode) async {
  // Validate format first
  if (!validateZipcode(zipcode)) {
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

  // Try the API
  CityCoordinates? coordinates = await _geocodeWithZippopotam(normalizedZip);

  // Use fallback if API fails
  if (coordinates == null) {
    coordinates = CityCoordinates(
      latitude: FALLBACK_COORDINATES.latitude,
      longitude: FALLBACK_COORDINATES.longitude,
      city: FALLBACK_COORDINATES.city,
      state: FALLBACK_COORDINATES.state,
      zipcode: normalizedZip,
      source: 'fallback',
    );
  }

  return coordinates;
}

/// Calculates delta (offset) coordinates from an actual position and base point
/// Returns integers multiplied by 1,000,000 for precision without floating point issues
Map<String, int> calculateDeltaCoordinates({
  required double actualLatitude,
  required double actualLongitude,
  required double baseLatitude,
  required double baseLongitude,
}) {
  int deltaLat = ((actualLatitude - baseLatitude) * 1000000).round();
  int deltaLong = ((actualLongitude - baseLongitude) * 1000000).round();

  return {
    'delta_lat': deltaLat,
    'delta_long': deltaLong,
  };
}

/// Reconstructs actual coordinates from delta values and a base point
Map<String, double> reconstructCoordinates({
  required int deltaLat,
  required int deltaLong,
  required double baseLatitude,
  required double baseLongitude,
}) {
  double actualLat = baseLatitude + (deltaLat / 1000000);
  double actualLong = baseLongitude + (deltaLong / 1000000);

  return {
    'latitude': actualLat,
    'longitude': actualLong,
  };
}

/// Formats delta coordinates for display (privacy-safe)
String formatDeltaCoordinates(int deltaLat, int deltaLong) {
  return 'Δ($deltaLat, $deltaLong)';
}
