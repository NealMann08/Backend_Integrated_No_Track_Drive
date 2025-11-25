# Insurance Provider Logout Functionality Error:
errors.dart:274 Uncaught (in promise) Error: Could not find a generator for route RouteSettings("/login", null) in the _WidgetsAppState.
Make sure your root app widget has provided a way to generate
this route.
Generators for routes are searched for in the following order:
 1. For the "/" route, the "home" property, if non-null, is used.
 2. Otherwise, the "routes" table is used, if it has an entry for the route.
 3. Otherwise, onGenerateRoute is called. It should return a non-null value for any valid route not handled by "home" and "routes".
 4. Finally if all else fails onUnknownRoute is called.
Unfortunately, onUnknownRoute was not set.
    at Object.throw_ [as throw] (errors.dart:274:3)
    at app.dart:1570:9
    at [_onUnknownRoute] (app.dart:1584:14)
    at tear (operations.dart:118:77)
    at [_routeNamed] (navigator.dart:4664:22)
    at navigator.NavigatorState.new.pushReplacementNamed (navigator.dart:4781:7)
    at Navigator.pushReplacementNamed (navigator.dart:2023:14)
    at insurance_home_page.dart:270:17
    at async_patch.dart:623:19
    at async_patch.dart:648:23
    at async_patch.dart:594:19
    at _RootZone.runUnary (zone.dart:1849:54)
    at dartDevEmbedder.defineLibrary.async._FutureListener.thenAwait.handleValue (future_impl.dart:222:18)
    at handleValueCallback (future_impl.dart:948:44)
    at _Future._propagateToListeners (future_impl.dart:977:13)
    at [_completeWithValue] (future_impl.dart:720:5)
    at future_impl.dart:804:7
    at Object._microtaskLoop (schedule_microtask.dart:40:34)
    at Object._startMicrotaskLoop (schedule_microtask.dart:49:5)
    at tear (operations.dart:118:77)
    at async_patch.dart:188:69


# AWS Lambda Cloudwatch logs for analyze_driver.py:

2025-11-24T23:33:39.408Z
✅ CACHED SUCCESSFULLY: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861
2025-11-24T23:33:39.408Z
📈 CACHE PERFORMANCE:
2025-11-24T23:33:39.408Z
Total Trips: 2
2025-11-24T23:33:39.408Z
✅ Cache Hits: 0 (0.0%) - FAST!
2025-11-24T23:33:39.408Z
❌ Cache Misses: 0
2025-11-24T23:33:39.408Z
🔄 Stale: 1
2025-11-24T23:33:39.408Z
💾 Cached This Run: 1
2025-11-24T23:33:39.408Z
✅ Successfully processed 1 trips (🚀 0 from cache!)
2025-11-24T23:33:39.428Z
🕐 User 0c5df6f7-73de-4259-b2c6-aa0ef703a430 timezone: America/Los_Angeles (zipcode: 94568)
2025-11-24T23:33:39.428Z
🕐 Adding local time display fields for America/Los_Angeles
2025-11-24T23:33:39.428Z
📅 TIMESTAMP DEBUG - BEFORE PROCESSING:
2025-11-24T23:33:39.428Z
Trip 1/1 - trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861
2025-11-24T23:33:39.428Z
start_timestamp: 2025-11-24T14:05:55.861302+00:00
2025-11-24T23:33:39.428Z
end_timestamp: 2025-11-24T14:06:52.599378+00:00
2025-11-24T23:33:39.428Z
📅 TIMESTAMP DEBUG - AFTER PROCESSING (FINAL):
2025-11-24T23:33:39.428Z
Trip 1/1 - trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861
2025-11-24T23:33:39.428Z
start_timestamp: 2025-11-24T14:05:55.861302+00:00
2025-11-24T23:33:39.428Z
end_timestamp: 2025-11-24T14:06:52.599378+00:00
2025-11-24T23:33:39.447Z
🏆 ANALYSIS Complete:
2025-11-24T23:33:39.447Z
User: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T23:33:39.447Z
Email: nov24@gmail.com
2025-11-24T23:33:39.447Z
Trips Analyzed: 1
2025-11-24T23:33:39.447Z
Total Distance: 2.80 miles
2025-11-24T23:33:39.447Z
Dominant Context: city (100.0% of distance)
2025-11-24T23:33:39.447Z
Overall Score: 87.2 (Excellent)
2025-11-24T23:33:39.447Z
Industry Rating: Exceptional
2025-11-24T23:33:39.447Z
Risk Level: Very Low Risk
2025-11-24T23:33:39.447Z
Moving Average Speed: 0.0 mph
2025-11-24T23:33:39.447Z
Overall Average Speed: 180.0 mph
2025-11-24T23:33:39.447Z
Time Moving: 0.0%
2025-11-24T23:33:39.447Z
Events per 100 miles: 0.00
2025-11-24T23:33:39.447Z
Privacy Protection: 100.0%
2025-11-24T23:33:39.447Z
✅ OPTIMIZED ANALYSIS COMPLETE - PRODUCTION READY
2025-11-24T23:33:39.447Z
🚀 Cache Performance: 0.0% hit rate (0/2 trips cached)
2025-11-24T23:33:39.468Z
END RequestId: cccf45c8-0d06-4190-b2bb-af611c3f4e84
2025-11-24T23:33:39.468Z
REPORT RequestId: cccf45c8-0d06-4190-b2bb-af611c3f4e84 Duration: 796.13 ms Billed Duration: 797 ms Memory Size: 128 MB Max Memory Used: 84 MB
2025-11-24T23:34:07.378Z
START RequestId: 553a7067-5cea-4b22-a22b-9ac8db4926fc Version: $LATEST
2025-11-24T23:34:07.378Z
🚗 INDUSTRY STANDARD ANALYSIS for identifier: nov24@gmail.com
2025-11-24T23:34:07.378Z
🔍 Looking up user by identifier: nov24@gmail.com
2025-11-24T23:34:07.378Z
📧 Searching by email: nov24@gmail.com
2025-11-24T23:34:07.388Z
✅ Found user by email: nov24@gmail.com (ID: 0c5df6f7-73de-4259-b2c6-aa0ef703a430)
2025-11-24T23:34:07.388Z
✅ Found user: nov24@gmail.com -> analyzing trips for ID: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T23:34:07.388Z
🔍 Getting base point for user: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T23:34:07.428Z
✅ Found user data for 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T23:34:07.428Z
📍 Using user-specific base point: Dublin, CA
2025-11-24T23:34:07.428Z
🔍 Getting trips for user: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T23:34:07.530Z
✅ Found 2 trips for user 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T23:34:07.530Z
📊 Analyzing 2 trips with INTELLIGENT CACHING
2025-11-24T23:34:07.591Z
❌ CACHE MISS: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764027135560
2025-11-24T23:34:07.591Z
🔄 ANALYZING new trip: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764027135560
2025-11-24T23:34:07.591Z
🎯 ANALYZING TRIP: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764027135560 for user: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T23:34:07.591Z
📖 Reading trip data from Trips-Neal table for: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764027135560
2025-11-24T23:34:07.629Z
📅 TIMESTAMPS FROM TRIPS-NEAL:
2025-11-24T23:34:07.629Z
start_timestamp: 2025-11-24T15:32:15.560160+00:00
2025-11-24T23:34:07.629Z
end_timestamp: 2025-11-24T15:33:10.112454+00:00
2025-11-24T23:34:07.629Z
Available keys in Trips-Neal: ['user_id', 'created_at', 'end_timestamp', 'start_timestamp', 'status', 'trip_id', 'total_batches', 'finalized_at', 'trip_quality']
2025-11-24T23:34:07.629Z
📱 Found FRONTEND VALUES for trip: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764027135560
2025-11-24T23:34:07.629Z
Frontend Distance: 0.000 miles
2025-11-24T23:34:07.629Z
Frontend Duration: 0.9 minutes
2025-11-24T23:34:07.629Z
Frontend Max Speed: 0.0 mph
2025-11-24T23:34:07.629Z
🔍 Getting batches for user: 0c5df6f7-73de-4259-b2c6-aa0ef703a430, trip: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764027135560
2025-11-24T23:34:07.750Z
✅ Found 1 batches for user 0c5df6f7-73de-4259-b2c6-aa0ef703a430, trip trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764027135560
2025-11-24T23:34:07.750Z
📦 Processing 1 batches
2025-11-24T23:34:07.750Z
Batch 1: 25 deltas
2025-11-24T23:34:07.750Z
📊 Total deltas to process: 25
2025-11-24T23:34:07.750Z
🚗 Processing 25 deltas
2025-11-24T23:34:07.750Z
📍 Base point: Dublin, CA
2025-11-24T23:34:07.750Z
📱 Using EXACT FRONTEND VALUES
2025-11-24T23:34:07.750Z
📊 FRONTEND VALUES:
2025-11-24T23:34:07.750Z
Distance: 0.000 miles
2025-11-24T23:34:07.750Z
Duration: 1m
2025-11-24T23:34:07.750Z
Max Speed: 0.0 mph
2025-11-24T23:34:07.750Z
Avg Speed: 0.0 mph
2025-11-24T23:34:07.750Z
❌ Invalid distance calculated: 0.0
2025-11-24T23:34:07.750Z
❌ Failed to process trip: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764027135560
2025-11-24T23:34:07.808Z
✅ CACHE HIT: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861
2025-11-24T23:34:07.849Z
🔄 TRIP MODIFIED: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861
2025-11-24T23:34:07.849Z
🔄 RE-ANALYZING modified trip: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861
2025-11-24T23:34:07.849Z
🎯 ANALYZING TRIP: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861 for user: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T23:34:07.849Z
📖 Reading trip data from Trips-Neal table for: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861
2025-11-24T23:34:07.909Z
📅 TIMESTAMPS FROM TRIPS-NEAL:
2025-11-24T23:34:07.909Z
start_timestamp: 2025-11-24T14:05:55.861302+00:00
2025-11-24T23:34:07.909Z
end_timestamp: 2025-11-24T14:06:52.599378+00:00
2025-11-24T23:34:07.909Z
Available keys in Trips-Neal: ['user_id', 'created_at', 'end_timestamp', 'start_timestamp', 'status', 'trip_id', 'total_batches', 'finalized_at', 'trip_quality']
2025-11-24T23:34:07.909Z
📱 Found FRONTEND VALUES for trip: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861
2025-11-24T23:34:07.909Z
Frontend Distance: 2.800 miles
2025-11-24T23:34:07.909Z
Frontend Duration: 0.9 minutes
2025-11-24T23:34:07.909Z
Frontend Max Speed: 0.0 mph
2025-11-24T23:34:07.909Z
🔍 Getting batches for user: 0c5df6f7-73de-4259-b2c6-aa0ef703a430, trip: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861
2025-11-24T23:34:08.010Z
✅ Found 1 batches for user 0c5df6f7-73de-4259-b2c6-aa0ef703a430, trip trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861
2025-11-24T23:34:08.010Z
📦 Processing 1 batches
2025-11-24T23:34:08.010Z
Batch 1: 25 deltas
2025-11-24T23:34:08.010Z
📊 Total deltas to process: 25
2025-11-24T23:34:08.010Z
🚗 Processing 25 deltas
2025-11-24T23:34:08.010Z
📍 Base point: Dublin, CA
2025-11-24T23:34:08.010Z
📱 Using EXACT FRONTEND VALUES
2025-11-24T23:34:08.010Z
📊 FRONTEND VALUES:
2025-11-24T23:34:08.010Z
Distance: 2.800 miles
2025-11-24T23:34:08.010Z
Duration: 1m
2025-11-24T23:34:08.010Z
Max Speed: 0.0 mph
2025-11-24T23:34:08.010Z
Avg Speed: 0.0 mph
2025-11-24T23:34:08.010Z
📊 Extracted 25 speed readings (max: 0.0 mph)
2025-11-24T23:34:08.010Z
🚗 MOVING METRICS:
2025-11-24T23:34:08.010Z
Moving Time: 0.0 minutes
2025-11-24T23:34:08.010Z
Stationary Time: 0.8 minutes
2025-11-24T23:34:08.010Z
Moving Average Speed: 0.0 mph
2025-11-24T23:34:08.010Z
Time Moving: 0.0%
2025-11-24T23:34:08.010Z
🎯 ANALYZING: 24 acceleration segments with BALANCED GROUPING
2025-11-24T23:34:08.010Z
🔍 CONTEXT DETECTION:
2025-11-24T23:34:08.010Z
Average Speed: 0.0 mph
2025-11-24T23:34:08.010Z
Speed Variance: 0.0
2025-11-24T23:34:08.010Z
Stops per Mile: 8.9
2025-11-24T23:34:08.010Z
Turns per Mile: 0.0
2025-11-24T23:34:08.010Z
🎯 CONTEXT DETECTED: CITY (confidence: 76.0%)
2025-11-24T23:34:08.010Z
Harsh Accel Threshold: 3.5 m/s²
2025-11-24T23:34:08.010Z
Harsh Decel Threshold: -4.5 m/s²
2025-11-24T23:34:08.010Z
📊 THRESHOLDS (m/s²):
2025-11-24T23:34:08.010Z
Context: CITY
2025-11-24T23:34:08.010Z
Harsh Acceleration: 3.5 m/s²
2025-11-24T23:34:08.010Z
Harsh Deceleration: -4.5 m/s²
2025-11-24T23:34:08.010Z
📈 Smoothing applied: 24 smoothed values
2025-11-24T23:34:08.010Z
✅ ANALYSIS Complete with BALANCED GROUPING:
2025-11-24T23:34:08.010Z
Context: CITY (confidence: 76.0%)
2025-11-24T23:34:08.010Z
Total Events: 0
2025-11-24T23:34:08.011Z
Dangerous Events: 0
2025-11-24T23:34:08.011Z
Sudden Accelerations: 0
2025-11-24T23:34:08.011Z
Sudden Decelerations: 0
2025-11-24T23:34:08.011Z
Hard Stops (>15mph to <5mph in <3s): 0
2025-11-24T23:34:08.011Z
Smoothness Score: 95.0
2025-11-24T23:34:08.011Z
📊 Speed Consistency: 25 speeds in city context
2025-11-24T23:34:08.011Z
📈 FREQUENCY METRICS:
2025-11-24T23:34:08.011Z
Raw Events per 100 miles: 0.00
2025-11-24T23:34:08.011Z
Context Weight: 0.85
2025-11-24T23:34:08.011Z
Distance Weight: 1.00
2025-11-24T23:34:08.011Z
Weighted Events per 100 miles: 0.00
2025-11-24T23:34:08.011Z
Industry Rating: Exceptional
2025-11-24T23:34:08.011Z
Frequency Score: 95
2025-11-24T23:34:08.011Z
🏆 SCORING:
2025-11-24T23:34:08.011Z
Context: CITY
2025-11-24T23:34:08.011Z
Harsh Frequency: 95.0/100 (weight: 0.35)
2025-11-24T23:34:08.011Z
Smoothness: 95.0/100 (weight: 0.25)
2025-11-24T23:34:08.011Z
Speed Consistency: 70.0/100 (weight: 0.25)
2025-11-24T23:34:08.011Z
Turn Safety: 85.0/100 (weight: 0.15)
2025-11-24T23:34:08.011Z
FINAL SCORE: 87.2/100
2025-11-24T23:34:08.011Z
✅ Analysis Complete:
2025-11-24T23:34:08.011Z
Context: CITY
2025-11-24T23:34:08.011Z
Behavior Score: 87.2/100 (Excellent)
2025-11-24T23:34:08.011Z
Industry Rating: Exceptional
2025-11-24T23:34:08.011Z
Moving Avg Speed: 0.0 mph
2025-11-24T23:34:08.011Z
Time Moving: 0.0%
2025-11-24T23:34:08.011Z
✅ Trip analysis complete: 87.2/100 (Excellent)
2025-11-24T23:34:08.011Z
✅ Added start_timestamp from Trips-Neal: 2025-11-24T14:05:55.861302+00:00
2025-11-24T23:34:08.011Z
✅ Added end_timestamp from Trips-Neal: 2025-11-24T14:06:52.599378+00:00
2025-11-24T23:34:08.011Z
📤 RETURNING RESULT WITH TIMESTAMPS:
2025-11-24T23:34:08.011Z
start_timestamp: 2025-11-24T14:05:55.861302+00:00
2025-11-24T23:34:08.011Z
end_timestamp: 2025-11-24T14:06:52.599378+00:00
2025-11-24T23:34:08.011Z
💾 Caching 1 trips...
2025-11-24T23:34:08.011Z
💾 CACHING TRIP: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861
2025-11-24T23:34:08.011Z
start_timestamp from analysis: 2025-11-24T14:05:55.861302+00:00
2025-11-24T23:34:08.011Z
end_timestamp from analysis: 2025-11-24T14:06:52.599378+00:00
2025-11-24T23:34:08.011Z
💾 WRITING TO DrivingSummaries-Neal:
2025-11-24T23:34:08.011Z
start_timestamp: 2025-11-24T14:05:55.861302+00:00
2025-11-24T23:34:08.011Z
end_timestamp: 2025-11-24T14:06:52.599378+00:00
2025-11-24T23:34:08.011Z
timestamp: 2025-11-24T14:06:52.599378+00:00
2025-11-24T23:34:08.108Z
✅ CACHED SUCCESSFULLY: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861
2025-11-24T23:34:08.108Z
📈 CACHE PERFORMANCE:
2025-11-24T23:34:08.108Z
Total Trips: 2
2025-11-24T23:34:08.108Z
✅ Cache Hits: 0 (0.0%) - FAST!
2025-11-24T23:34:08.108Z
❌ Cache Misses: 0
2025-11-24T23:34:08.108Z
🔄 Stale: 1
2025-11-24T23:34:08.108Z
💾 Cached This Run: 1
2025-11-24T23:34:08.108Z
✅ Successfully processed 1 trips (🚀 0 from cache!)
2025-11-24T23:34:08.148Z
🕐 User 0c5df6f7-73de-4259-b2c6-aa0ef703a430 timezone: America/Los_Angeles (zipcode: 94568)
2025-11-24T23:34:08.148Z
🕐 Adding local time display fields for America/Los_Angeles
2025-11-24T23:34:08.148Z
📅 TIMESTAMP DEBUG - BEFORE PROCESSING:
2025-11-24T23:34:08.148Z
Trip 1/1 - trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861
2025-11-24T23:34:08.148Z
start_timestamp: 2025-11-24T14:05:55.861302+00:00
2025-11-24T23:34:08.148Z
end_timestamp: 2025-11-24T14:06:52.599378+00:00
2025-11-24T23:34:08.148Z
📅 TIMESTAMP DEBUG - AFTER PROCESSING (FINAL):
2025-11-24T23:34:08.148Z
Trip 1/1 - trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861
2025-11-24T23:34:08.148Z
start_timestamp: 2025-11-24T14:05:55.861302+00:00
2025-11-24T23:34:08.148Z
end_timestamp: 2025-11-24T14:06:52.599378+00:00
2025-11-24T23:34:08.148Z
🏆 ANALYSIS Complete:
2025-11-24T23:34:08.148Z
User: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T23:34:08.148Z
Email: nov24@gmail.com
2025-11-24T23:34:08.148Z
Trips Analyzed: 1
2025-11-24T23:34:08.148Z
Total Distance: 2.80 miles
2025-11-24T23:34:08.148Z
Dominant Context: city (100.0% of distance)
2025-11-24T23:34:08.148Z
Overall Score: 87.2 (Excellent)
2025-11-24T23:34:08.148Z
Industry Rating: Exceptional
2025-11-24T23:34:08.148Z
Risk Level: Very Low Risk
2025-11-24T23:34:08.148Z
Moving Average Speed: 0.0 mph
2025-11-24T23:34:08.148Z
Overall Average Speed: 180.0 mph
2025-11-24T23:34:08.148Z
Time Moving: 0.0%
2025-11-24T23:34:08.148Z
Events per 100 miles: 0.00
2025-11-24T23:34:08.148Z
Privacy Protection: 100.0%
2025-11-24T23:34:08.148Z
✅ OPTIMIZED ANALYSIS COMPLETE - PRODUCTION READY
2025-11-24T23:34:08.149Z
🚀 Cache Performance: 0.0% hit rate (0/2 trips cached)
2025-11-24T23:34:08.150Z
END RequestId: 553a7067-5cea-4b22-a22b-9ac8db4926fc
2025-11-24T23:34:08.150Z
REPORT RequestId: 553a7067-5cea-4b22-a22b-9ac8db4926fc Duration: 772.28 ms Billed Duration: 773 ms Memory Size: 128 MB Max Memory Used: 84 MB