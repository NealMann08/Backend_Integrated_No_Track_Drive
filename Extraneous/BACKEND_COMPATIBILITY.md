# Backend Compatibility Guide

## Overview
This document explains the data structures sent to your AWS Lambda backend and DynamoDB tables to ensure compatibility with the updated trip tracking system.

## API Endpoints

### 1. `/store-trajectory-batch` - Store Delta Coordinates

**Purpose:** Sends batches of 25 delta coordinate points during an active trip

**Frequency:** Every 25 points collected (approximately every 50 seconds at 2-second intervals)

**Request Body:**
```json
{
  "user_id": "string",           // User's unique ID
  "trip_id": "string",            // Format: "trip_{userId}_{timestamp}"
  "batch_number": 1,              // Incremental batch counter
  "batch_size": 25,               // Number of points in this batch
  "first_point_timestamp": "2025-01-18T10:30:00.000Z",
  "last_point_timestamp": "2025-01-18T10:31:00.000Z",
  "deltas": [
    {
      "delta_lat": 12345,         // Fixed-point integer (actual_lat - base_lat) * 1,000,000
      "delta_long": -67890,       // Fixed-point integer (actual_lon - base_lon) * 1,000,000
      "delta_time": 2000.0,       // Milliseconds since last point
      "timestamp": "2025-01-18T10:30:00.000Z",
      "sequence": 0,              // Point number in trip (0, 1, 2, ...)
      "speed_mph": 35.5,          // Speed in miles per hour
      "speed_source": "gps",      // NEW: "gps" or "calculated"
      "speed_confidence": 0.95,   // 0.95 for GPS, 0.7 for calculated
      "gps_accuracy": 5.0,        // GPS accuracy in meters
      "is_stationary": false,     // true if speed < 2 mph
      "data_quality": "high",     // "high" or "medium" based on GPS accuracy
      "raw_speed_ms": 15.87       // Raw GPS speed in m/s (null if unavailable)
    }
  ],
  "quality_metrics": {
    "valid_points": 25,
    "rejected_points": 0,
    "average_accuracy": 5.0,
    "speed_data_quality": 0.5,
    "gps_quality_score": 0.8
  }
}
```

### 2. `/finalize-trip` - Complete Trip

**Purpose:** Called when driver stops the trip to finalize and trigger analysis

**Request Body:**
```json
{
  "user_id": "string",
  "trip_id": "string",
  "start_timestamp": "2025-01-18T10:30:00.000Z",
  "end_timestamp": "2025-01-18T11:00:00.000Z",
  "trip_quality": {
    "use_gps_metrics": true,
    "gps_max_speed_mph": 65.2,        // Maximum speed during trip
    "actual_duration_minutes": 30.0,  // Total trip duration
    "actual_distance_miles": 15.5,    // Estimated distance (points * 0.1)
    "total_points": 150,              // Total coordinates collected
    "valid_points": 150,
    "rejected_points": 0,
    "average_accuracy": 5.0,
    "gps_quality_score": 0.9
  }
}
```

## Delta Coordinate System

### How Delta Encoding Works

Instead of storing absolute GPS coordinates, the app uses **delta encoding** for privacy:

1. **Base Point**: When user signs up, their zipcode is converted to coordinates and stored as `base_point`
2. **Delta Calculation**: Each GPS point is stored as an offset from the base point:
   - `delta_lat = (actual_latitude - base_latitude) * 1,000,000`
   - `delta_long = (actual_longitude - base_longitude) * 1,000,000`

3. **Reconstruction**: Backend can reconstruct the trip path:
   ```python
   actual_lat = base_lat + (delta_lat / 1,000,000)
   actual_lon = base_lon + (delta_long / 1,000,000)
   ```

### Fixed-Point Integer Format

Coordinates are multiplied by 1,000,000 to preserve precision while using integers:
- Original: `37.7749°` latitude
- Fixed-point: `37774900` (stored as integer)
- Precision: ~0.1 meters

## Changes Made to Speed Tracking

### New Field: `speed_source`

**What changed:** Added `speed_source` field to each delta point

**Values:**
- `"gps"` - Speed from device GPS sensor (more accurate)
- `"calculated"` - Speed calculated from distance between points

**Backward Compatibility:** ✅ This field is **optional** - your backend can ignore it if not needed

**Recommended Use:**
- Use GPS speeds when `speed_source === "gps"` for more accurate analysis
- Weight speeds by `speed_confidence` (0.95 for GPS, 0.7 for calculated)

## DynamoDB Table Recommendations

### Trips Table
```
partition_key: user_id (String)
sort_key: trip_id (String)

Attributes:
- start_timestamp (String, ISO8601)
- end_timestamp (String, ISO8601)
- duration_minutes (Number)
- max_speed_mph (Number)
- total_points (Number)
- trip_quality (Map)
```

### Trajectory Table
```
partition_key: trip_id (String)
sort_key: batch_number (Number)

Attributes:
- deltas (List of Maps) - Array of delta points
- first_point_timestamp (String)
- last_point_timestamp (String)
- batch_size (Number)
- quality_metrics (Map)
```

### User Base Points Table
```
partition_key: user_id (String)

Attributes:
- base_point (Map):
  - latitude (Number)
  - longitude (Number)
  - zipcode (String)
  - city (String)
  - state (String)
```

## Speed Calculation Methods

### Method 1: GPS Speed (Preferred)
```dart
if (position.speed != null && position.speed >= 0) {
  speed_mph = position.speed * 2.237  // m/s to mph
}
```

### Method 2: Distance-Based Calculation (Fallback)
```dart
distance_meters = haversine(prev_lat, prev_lon, curr_lat, curr_lon)
time_hours = delta_time_ms / 3600000.0
speed_mph = (distance_meters * 0.000621371) / time_hours
```

### Confidence Scores
- GPS speed: `0.95` confidence (device hardware)
- Calculated speed: `0.7` confidence (subject to GPS drift)

## Testing Backend Compatibility

1. **Test Data Sample:**
   ```bash
   # Start trip
   POST /store-trajectory-batch
   {
     "user_id": "test_user_123",
     "trip_id": "trip_test_user_123_1737202800000",
     "batch_number": 1,
     "deltas": [...]
   }

   # End trip
   POST /finalize-trip
   {
     "user_id": "test_user_123",
     "trip_id": "trip_test_user_123_1737202800000",
     ...
   }
   ```

2. **Verify Backend Handles:**
   - ✅ Delta coordinate integers (positive and negative)
   - ✅ Optional `speed_source` field
   - ✅ Batch sequence numbering
   - ✅ Trip quality metrics

3. **Backend Should Ignore:**
   - Unknown fields (forward compatibility)
   - Extra metadata in quality_metrics

## Summary of Changes

### What's New:
1. **`speed_source` field** - Tracks whether speed is from GPS or calculated
2. **Improved speed calculation** - Better fallback logic when GPS speed unavailable
3. **Better confidence scoring** - 0.95 for GPS, 0.7 for calculated

### Backward Compatible:
✅ All existing fields remain unchanged
✅ New fields are additive only
✅ Delta encoding format unchanged
✅ Endpoint URLs unchanged

### Testing Recommendations:
1. Monitor CloudWatch logs for any parsing errors
2. Verify DynamoDB writes include new `speed_source` field
3. Check that trip analysis handles both GPS and calculated speeds
4. Validate delta coordinate reconstruction produces valid GPS paths
