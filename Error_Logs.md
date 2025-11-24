# store-trajectory-batch.py cloudwatch logs:

2025-11-24T22:06:46.128Z
INIT_START Runtime Version: python:3.9.v119	Runtime Version ARN: arn:aws:lambda:us-west-1::runtime:d69887c3244bd3892359f0e26a6dfe5087759a31f0d95d0a873fd63b4695bb36

INIT_START Runtime Version: python:3.9.v119 Runtime Version ARN: arn:aws:lambda:us-west-1::runtime:d69887c3244bd3892359f0e26a6dfe5087759a31f0d95d0a873fd63b4695bb36
2025-11-24T22:06:46.599Z
START RequestId: 9597f54b-e82b-4f3e-8400-ad173f3379cc Version: $LATEST
2025-11-24T22:06:46.599Z
🚀 BULLETPROOF PROCESSING - Headers: {'accept-encoding': 'gzip', 'content-length': '6737', 'content-type': 'application/json; charset=utf-8', 'host': 'm9yn8bsm3k.execute-api.us-west-1.amazonaws.com', 'user-agent': 'Dart/3.9 (dart:io)', 'x-amzn-trace-id': 'Root=1-6924d6f5-6da4e6a615894deb210a49c1', 'x-forwarded-for': '172.6.85.148', 'x-forwarded-port': '443', 'x-forwarded-proto': 'https'}
2025-11-24T22:06:46.599Z
📊 Body size: 6737 characters
2025-11-24T22:06:46.599Z
🚀 PROCESSING BATCH: Trip trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861, Batch #1, 25 deltas
2025-11-24T22:06:46.599Z
👤 User: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:06:46.599Z
📊 SAMPLE DELTAS (first 3):
2025-11-24T22:06:46.599Z
Delta 0: {'delta_lat': 25563, 'delta_long': 71519, 'delta_time': 2000.0, 'timestamp': '2025-11-24T14:05:57.894638', 'sequence': 1, 'speed_mph': 0.0, 'speed_source': 'gps', 'speed_confidence': 0.95, 'gps_accuracy': 11.63174898951305, 'is_stationary': True, 'data_quality': 'medium'}
2025-11-24T22:06:46.599Z
Delta 1: {'delta_lat': 25468, 'delta_long': 71515, 'delta_time': 2000.0, 'timestamp': '2025-11-24T14:05:59.882459', 'sequence': 2, 'speed_mph': 0.0, 'speed_source': 'gps', 'speed_confidence': 0.95, 'gps_accuracy': 12.376895266464842, 'is_stationary': True, 'data_quality': 'medium'}
2025-11-24T22:06:46.599Z
Delta 2: {'delta_lat': 25468, 'delta_long': 71515, 'delta_time': 2000.0, 'timestamp': '2025-11-24T14:06:01.881097', 'sequence': 3, 'speed_mph': 0.0, 'speed_source': 'gps', 'speed_confidence': 0.95, 'gps_accuracy': 12.376895266464842, 'is_stationary': True, 'data_quality': 'medium'}
2025-11-24T22:06:46.599Z
🔍 ULTRA LENIENT VALIDATION: 25 deltas...
2025-11-24T22:06:46.600Z
⚠️ Delta 0: Large coordinate change - lat: 25563.00000000, lon: 71519.00000000
2025-11-24T22:06:46.600Z
✅ Delta 0: lat=25563.00000000, lon=71519.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.600Z
⚠️ Delta 1: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.600Z
✅ Delta 1: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.600Z
⚠️ Delta 2: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.600Z
✅ Delta 2: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.600Z
⚠️ Delta 3: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.600Z
✅ Delta 3: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.600Z
⚠️ Delta 4: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.600Z
✅ Delta 4: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.600Z
⚠️ Delta 5: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.600Z
✅ Delta 5: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.600Z
⚠️ Delta 6: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.600Z
✅ Delta 6: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.600Z
⚠️ Delta 7: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.600Z
✅ Delta 7: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.600Z
⚠️ Delta 8: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.600Z
✅ Delta 8: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.600Z
⚠️ Delta 9: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.600Z
✅ Delta 9: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.600Z
⚠️ Delta 10: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.600Z
✅ Delta 10: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.600Z
⚠️ Delta 11: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.600Z
✅ Delta 11: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.600Z
⚠️ Delta 12: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.600Z
✅ Delta 12: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.600Z
⚠️ Delta 13: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.607Z
✅ Delta 13: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.607Z
⚠️ Delta 14: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.607Z
✅ Delta 14: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.607Z
⚠️ Delta 15: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.607Z
✅ Delta 15: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.607Z
⚠️ Delta 16: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.607Z
✅ Delta 16: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.607Z
⚠️ Delta 17: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.607Z
✅ Delta 17: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.607Z
⚠️ Delta 18: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.607Z
✅ Delta 18: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.607Z
⚠️ Delta 19: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.607Z
✅ Delta 19: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.607Z
⚠️ Delta 20: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.607Z
✅ Delta 20: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.607Z
⚠️ Delta 21: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.607Z
✅ Delta 21: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.607Z
⚠️ Delta 22: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.607Z
✅ Delta 22: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.607Z
⚠️ Delta 23: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.607Z
✅ Delta 23: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.607Z
⚠️ Delta 24: Large coordinate change - lat: 25468.00000000, lon: 71515.00000000
2025-11-24T22:06:46.607Z
✅ Delta 24: lat=25468.00000000, lon=71515.00000000, time=2000.0s, enhancement=1.00
2025-11-24T22:06:46.607Z
📊 ULTRA LENIENT VALIDATION COMPLETE: 25/25 deltas accepted (100.0%)
2025-11-24T22:06:46.607Z
⚠️ Quality issues found: 25
2025-11-24T22:06:46.607Z
- Delta 0: Large coordinate change (lat: 25563.00000000, lon: 71519.00000000)
2025-11-24T22:06:46.607Z
- Delta 1: Large coordinate change (lat: 25468.00000000, lon: 71515.00000000)
2025-11-24T22:06:46.607Z
- Delta 2: Large coordinate change (lat: 25468.00000000, lon: 71515.00000000)
2025-11-24T22:06:46.607Z
- Delta 3: Large coordinate change (lat: 25468.00000000, lon: 71515.00000000)
2025-11-24T22:06:46.607Z
- Delta 4: Large coordinate change (lat: 25468.00000000, lon: 71515.00000000)
2025-11-24T22:06:46.917Z
✅ NEW TRIP CREATED: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861 starting at 2025-11-24T14:06:45.883719
2025-11-24T22:06:46.927Z
💾 BULLETPROOF CONVERSION - Converting all data to safe DynamoDB format...
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.927Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.928Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.928Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.928Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.928Z
⚠️ Int conversion error for True: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.928Z
⚠️ Int conversion error for False: [<class 'decimal.ConversionSyntax'>], using 0
2025-11-24T22:06:46.928Z
✅ Safe conversion completed successfully
2025-11-24T22:06:46.928Z
💾 STORING BATCH: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861_batch_1
2025-11-24T22:06:47.060Z
✅ BATCH STORED SUCCESSFULLY: trip_0c5df6f7-73de-4259-b2c6-aa0ef703a430_1764021955861_batch_1
2025-11-24T22:06:47.060Z
📊 Final batch stats: {'total_deltas': 25, 'enhanced_deltas': 25, 'average_speed': 0.0, 'average_confidence': 0.9499999999999996, 'average_gps_accuracy': 12.347089415386764, 'stationary_points': 25, 'high_quality_points': 0, 'movement_points': 0}
2025-11-24T22:06:47.060Z
🔢 Delta summary: 25 valid deltas from 25 originals
2025-11-24T22:06:47.068Z
END RequestId: 9597f54b-e82b-4f3e-8400-ad173f3379cc
2025-11-24T22:06:47.068Z
REPORT RequestId: 9597f54b-e82b-4f3e-8400-ad173f3379cc Duration: 468.81 ms Billed Duration: 937 ms Memory Size: 128 MB Max Memory Used: 82 MB Init Duration: 467.43 ms

# analyze_driver.py cloudwatch logs:
2025-11-24T22:01:10.143Z
Stationary Time: 0.1 minutes
2025-11-24T22:01:10.143Z
Moving Average Speed: 0.0 mph
2025-11-24T22:01:10.143Z
Time Moving: 0.0%
2025-11-24T22:01:10.143Z
🎯 ANALYZING: 2 acceleration segments with BALANCED GROUPING
2025-11-24T22:01:10.143Z
📊 THRESHOLDS (m/s²):
2025-11-24T22:01:10.143Z
Context: MIXED
2025-11-24T22:01:10.143Z
Harsh Acceleration: 3.2 m/s²
2025-11-24T22:01:10.143Z
Harsh Deceleration: -4.2 m/s²
2025-11-24T22:01:10.143Z
📈 Smoothing applied: 2 smoothed values
2025-11-24T22:01:10.143Z
✅ ANALYSIS Complete with BALANCED GROUPING:
2025-11-24T22:01:10.143Z
Context: MIXED (confidence: 0.0%)
2025-11-24T22:01:10.143Z
Total Events: 0
2025-11-24T22:01:10.143Z
Dangerous Events: 0
2025-11-24T22:01:10.143Z
Sudden Accelerations: 0
2025-11-24T22:01:10.144Z
Sudden Decelerations: 0
2025-11-24T22:01:10.144Z
Hard Stops (>15mph to <5mph in <3s): 0
2025-11-24T22:01:10.144Z
Smoothness Score: 95.0
2025-11-24T22:01:10.144Z
📈 FREQUENCY METRICS:
2025-11-24T22:01:10.144Z
Raw Events per 100 miles: 0.00
2025-11-24T22:01:10.144Z
Context Weight: 0.92
2025-11-24T22:01:10.144Z
Distance Weight: 0.50
2025-11-24T22:01:10.144Z
Weighted Events per 100 miles: 0.00
2025-11-24T22:01:10.144Z
Industry Rating: Exceptional
2025-11-24T22:01:10.144Z
Frequency Score: 95
2025-11-24T22:01:10.144Z
🏆 SCORING:
2025-11-24T22:01:10.144Z
Context: MIXED
2025-11-24T22:01:10.144Z
Harsh Frequency: 95.0/100 (weight: 0.35)
2025-11-24T22:01:10.144Z
Smoothness: 95.0/100 (weight: 0.25)
2025-11-24T22:01:10.144Z
Speed Consistency: 75.0/100 (weight: 0.25)
2025-11-24T22:01:10.144Z
Turn Safety: 85.0/100 (weight: 0.15)
2025-11-24T22:01:10.144Z
FINAL SCORE: 88.5/100
2025-11-24T22:01:10.144Z
✅ Analysis Complete:
2025-11-24T22:01:10.144Z
Context: MIXED
2025-11-24T22:01:10.144Z
Behavior Score: 88.5/100 (Excellent)
2025-11-24T22:01:10.144Z
Industry Rating: Exceptional
2025-11-24T22:01:10.144Z
Moving Avg Speed: 0.0 mph
2025-11-24T22:01:10.144Z
Time Moving: 0.0%
2025-11-24T22:01:10.144Z
✅ Trip analysis complete: 88.5/100 (Excellent)
2025-11-24T22:01:10.144Z
✅ Added start_timestamp from Trips-Neal: 2025-11-21T18:43:39.073000+00:00
2025-11-24T22:01:10.144Z
✅ Added end_timestamp from Trips-Neal: 2025-11-21T18:43:49.083000+00:00
2025-11-24T22:01:10.144Z
📤 RETURNING RESULT WITH TIMESTAMPS:
2025-11-24T22:01:10.144Z
start_timestamp: 2025-11-21T18:43:39.073000+00:00
2025-11-24T22:01:10.144Z
end_timestamp: 2025-11-21T18:43:49.083000+00:00
2025-11-24T22:01:10.203Z
❌ CACHE MISS: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953
2025-11-24T22:01:10.203Z
🔄 ANALYZING new trip: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953
2025-11-24T22:01:10.203Z
🎯 ANALYZING TRIP: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953 for user: a690d93c-a03a-4856-bd4e-487d8c1d58a1
2025-11-24T22:01:10.203Z
📖 Reading trip data from Trips-Neal table for: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953
2025-11-24T22:01:10.244Z
📅 TIMESTAMPS FROM TRIPS-NEAL:
2025-11-24T22:01:10.244Z
start_timestamp: 2025-11-21T17:04:22.953152+00:00
2025-11-24T22:01:10.244Z
end_timestamp: 2025-11-21T17:05:16.110895+00:00
2025-11-24T22:01:10.244Z
Available keys in Trips-Neal: ['user_id', 'created_at', 'end_timestamp', 'start_timestamp', 'status', 'trip_id', 'total_batches', 'finalized_at', 'trip_quality']
2025-11-24T22:01:10.244Z
📱 Found FRONTEND VALUES for trip: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953
2025-11-24T22:01:10.244Z
Frontend Distance: 0.000 miles
2025-11-24T22:01:10.244Z
Frontend Duration: 0.9 minutes
2025-11-24T22:01:10.244Z
Frontend Max Speed: 0.0 mph
2025-11-24T22:01:10.244Z
🔍 Getting batches for user: a690d93c-a03a-4856-bd4e-487d8c1d58a1, trip: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953
2025-11-24T22:01:10.343Z
✅ Found 1 batches for user a690d93c-a03a-4856-bd4e-487d8c1d58a1, trip trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953
2025-11-24T22:01:10.343Z
📦 Processing 1 batches
2025-11-24T22:01:10.343Z
Batch 1: 25 deltas
2025-11-24T22:01:10.343Z
📊 Total deltas to process: 25
2025-11-24T22:01:10.343Z
🚗 Processing 25 deltas
2025-11-24T22:01:10.343Z
📍 Base point: Dublin, CA
2025-11-24T22:01:10.343Z
📱 Using EXACT FRONTEND VALUES
2025-11-24T22:01:10.343Z
📊 FRONTEND VALUES:
2025-11-24T22:01:10.343Z
Distance: 0.000 miles
2025-11-24T22:01:10.343Z
Duration: 1m
2025-11-24T22:01:10.343Z
Max Speed: 0.0 mph
2025-11-24T22:01:10.343Z
Avg Speed: 0.0 mph
2025-11-24T22:01:10.343Z
❌ Invalid distance calculated: 0.0
2025-11-24T22:01:10.343Z
❌ Failed to process trip: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953
2025-11-24T22:01:10.344Z
💾 Caching 2 trips...
2025-11-24T22:01:10.344Z
💾 CACHING TRIP: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763959896652
2025-11-24T22:01:10.344Z
start_timestamp from analysis: 2025-11-23T20:51:36.652000+00:00
2025-11-24T22:01:10.344Z
end_timestamp from analysis: 2025-11-23T20:51:42.522000+00:00
2025-11-24T22:01:10.344Z
💾 WRITING TO DrivingSummaries-Neal:
2025-11-24T22:01:10.344Z
start_timestamp: 2025-11-23T20:51:36.652000+00:00
2025-11-24T22:01:10.344Z
end_timestamp: 2025-11-23T20:51:42.522000+00:00
2025-11-24T22:01:10.344Z
timestamp: 2025-11-23T20:51:42.522000+00:00
2025-11-24T22:01:10.407Z
✅ CACHED SUCCESSFULLY: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763959896652
2025-11-24T22:01:10.407Z
💾 CACHING TRIP: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763779419073
2025-11-24T22:01:10.407Z
start_timestamp from analysis: 2025-11-21T18:43:39.073000+00:00
2025-11-24T22:01:10.407Z
end_timestamp from analysis: 2025-11-21T18:43:49.083000+00:00
2025-11-24T22:01:10.407Z
💾 WRITING TO DrivingSummaries-Neal:
2025-11-24T22:01:10.407Z
start_timestamp: 2025-11-21T18:43:39.073000+00:00
2025-11-24T22:01:10.407Z
end_timestamp: 2025-11-21T18:43:49.083000+00:00
2025-11-24T22:01:10.407Z
timestamp: 2025-11-21T18:43:49.083000+00:00
2025-11-24T22:01:10.467Z
✅ CACHED SUCCESSFULLY: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763779419073
2025-11-24T22:01:10.467Z
📈 CACHE PERFORMANCE:
2025-11-24T22:01:10.467Z
Total Trips: 3
2025-11-24T22:01:10.467Z
✅ Cache Hits: 0 (0.0%) - FAST!
2025-11-24T22:01:10.467Z
❌ Cache Misses: 0
2025-11-24T22:01:10.467Z
🔄 Stale: 2
2025-11-24T22:01:10.467Z
💾 Cached This Run: 2
2025-11-24T22:01:10.467Z
✅ Successfully processed 2 trips (🚀 0 from cache!)
2025-11-24T22:01:10.503Z
🕐 User a690d93c-a03a-4856-bd4e-487d8c1d58a1 timezone: America/Los_Angeles (zipcode: 94568)
2025-11-24T22:01:10.503Z
🕐 Adding local time display fields for America/Los_Angeles
2025-11-24T22:01:10.503Z
📅 TIMESTAMP DEBUG - BEFORE PROCESSING:
2025-11-24T22:01:10.503Z
Trip 1/2 - trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763959896652
2025-11-24T22:01:10.503Z
start_timestamp: 2025-11-23T20:51:36.652000+00:00
2025-11-24T22:01:10.503Z
end_timestamp: 2025-11-23T20:51:42.522000+00:00
2025-11-24T22:01:10.503Z
Trip 2/2 - trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763779419073
2025-11-24T22:01:10.503Z
start_timestamp: 2025-11-21T18:43:39.073000+00:00
2025-11-24T22:01:10.503Z
end_timestamp: 2025-11-21T18:43:49.083000+00:00
2025-11-24T22:01:10.503Z
📅 TIMESTAMP DEBUG - AFTER PROCESSING (FINAL):
2025-11-24T22:01:10.503Z
Trip 1/2 - trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763959896652
2025-11-24T22:01:10.503Z
start_timestamp: 2025-11-23T20:51:36.652000+00:00
2025-11-24T22:01:10.503Z
end_timestamp: 2025-11-23T20:51:42.522000+00:00
2025-11-24T22:01:10.503Z
Trip 2/2 - trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763779419073
2025-11-24T22:01:10.503Z
start_timestamp: 2025-11-21T18:43:39.073000+00:00
2025-11-24T22:01:10.503Z
end_timestamp: 2025-11-21T18:43:49.083000+00:00
2025-11-24T22:01:10.503Z
🏆 ANALYSIS Complete:
2025-11-24T22:01:10.503Z
User: a690d93c-a03a-4856-bd4e-487d8c1d58a1
2025-11-24T22:01:10.503Z
Email: nov21@gmail.com
2025-11-24T22:01:10.503Z
Trips Analyzed: 2
2025-11-24T22:01:10.503Z
Total Distance: 0.50 miles
2025-11-24T22:01:10.503Z
Dominant Context: mixed (100.0% of distance)
2025-11-24T22:01:10.503Z
Overall Score: 88.5 (Excellent)
2025-11-24T22:01:10.503Z
Industry Rating: Exceptional
2025-11-24T22:01:10.503Z
Risk Level: Very Low Risk
2025-11-24T22:01:10.503Z
Moving Average Speed: 0.0 mph
2025-11-24T22:01:10.503Z
Overall Average Speed: 30.0 mph
2025-11-24T22:01:10.503Z
Time Moving: 0.0%
2025-11-24T22:01:10.503Z
Events per 100 miles: 0.00
2025-11-24T22:01:10.503Z
Privacy Protection: 100.0%
2025-11-24T22:01:10.503Z
✅ OPTIMIZED ANALYSIS COMPLETE - PRODUCTION READY
2025-11-24T22:01:10.503Z
🚀 Cache Performance: 0.0% hit rate (0/3 trips cached)
2025-11-24T22:01:10.543Z
END RequestId: e01c8c1c-a6dc-45af-850a-df3a64855382
2025-11-24T22:01:10.543Z
REPORT RequestId: e01c8c1c-a6dc-45af-850a-df3a64855382 Duration: 1052.37 ms Billed Duration: 1053 ms Memory Size: 128 MB Max Memory Used: 83 MB
2025-11-24T22:01:37.508Z
START RequestId: 133ecbcb-3ad5-4270-b9e3-2b476ccb9fda Version: $LATEST
2025-11-24T22:01:37.509Z
🚗 INDUSTRY STANDARD ANALYSIS for identifier: nov24@gmail.com
2025-11-24T22:01:37.509Z
🔍 Looking up user by identifier: nov24@gmail.com
2025-11-24T22:01:37.509Z
📧 Searching by email: nov24@gmail.com
2025-11-24T22:01:37.543Z
✅ Found user by email: nov24@gmail.com (ID: 0c5df6f7-73de-4259-b2c6-aa0ef703a430)
2025-11-24T22:01:37.543Z
✅ Found user: nov24@gmail.com -> analyzing trips for ID: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:01:37.543Z
🔍 Getting base point for user: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:01:37.603Z
✅ Found user data for 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:01:37.603Z
📍 Using user-specific base point: Dublin, CA
2025-11-24T22:01:37.603Z
🔍 Getting trips for user: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:01:37.643Z
✅ Found 0 trips for user 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:01:37.663Z
END RequestId: 133ecbcb-3ad5-4270-b9e3-2b476ccb9fda
2025-11-24T22:01:37.663Z
REPORT RequestId: 133ecbcb-3ad5-4270-b9e3-2b476ccb9fda Duration: 154.96 ms Billed Duration: 155 ms Memory Size: 128 MB Max Memory Used: 83 MB
2025-11-24T22:01:38.057Z
START RequestId: 9bbd8f37-4a70-4ed3-a9e5-ed7144cce2b9 Version: $LATEST
2025-11-24T22:01:38.057Z
🚗 INDUSTRY STANDARD ANALYSIS for identifier: nov24@gmail.com
2025-11-24T22:01:38.057Z
🔍 Looking up user by identifier: nov24@gmail.com
2025-11-24T22:01:38.057Z
📧 Searching by email: nov24@gmail.com
2025-11-24T22:01:38.071Z
✅ Found user by email: nov24@gmail.com (ID: 0c5df6f7-73de-4259-b2c6-aa0ef703a430)
2025-11-24T22:01:38.071Z
✅ Found user: nov24@gmail.com -> analyzing trips for ID: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:01:38.071Z
🔍 Getting base point for user: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:01:38.103Z
✅ Found user data for 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:01:38.103Z
📍 Using user-specific base point: Dublin, CA
2025-11-24T22:01:38.103Z
🔍 Getting trips for user: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:01:38.143Z
✅ Found 0 trips for user 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:01:38.163Z
END RequestId: 9bbd8f37-4a70-4ed3-a9e5-ed7144cce2b9
2025-11-24T22:01:38.163Z
REPORT RequestId: 9bbd8f37-4a70-4ed3-a9e5-ed7144cce2b9 Duration: 105.57 ms Billed Duration: 106 ms Memory Size: 128 MB Max Memory Used: 83 MB
2025-11-24T22:03:58.217Z
START RequestId: ce972696-c93d-4956-aba4-01fcf18d13bf Version: $LATEST
2025-11-24T22:03:58.222Z
🚗 INDUSTRY STANDARD ANALYSIS for identifier: isp@gmail.com
2025-11-24T22:03:58.222Z
🔍 Looking up user by identifier: isp@gmail.com
2025-11-24T22:03:58.222Z
📧 Searching by email: isp@gmail.com
2025-11-24T22:03:58.445Z
✅ Found user by email: isp@gmail.com (ID: 8f9bbb25-4623-4e5b-bdca-3b68a6a9fd1b)
2025-11-24T22:03:58.445Z
✅ Found user: isp@gmail.com -> analyzing trips for ID: 8f9bbb25-4623-4e5b-bdca-3b68a6a9fd1b
2025-11-24T22:03:58.445Z
🔍 Getting base point for user: 8f9bbb25-4623-4e5b-bdca-3b68a6a9fd1b
2025-11-24T22:03:58.482Z
✅ Found user data for 8f9bbb25-4623-4e5b-bdca-3b68a6a9fd1b
2025-11-24T22:03:58.482Z
⚠️ No custom base point found for 8f9bbb25-4623-4e5b-bdca-3b68a6a9fd1b, using fallback
2025-11-24T22:03:58.482Z
🔍 Getting trips for user: 8f9bbb25-4623-4e5b-bdca-3b68a6a9fd1b
2025-11-24T22:03:58.522Z
✅ Found 0 trips for user 8f9bbb25-4623-4e5b-bdca-3b68a6a9fd1b
2025-11-24T22:03:58.524Z
END RequestId: ce972696-c93d-4956-aba4-01fcf18d13bf
2025-11-24T22:03:58.524Z
REPORT RequestId: ce972696-c93d-4956-aba4-01fcf18d13bf Duration: 307.80 ms Billed Duration: 308 ms Memory Size: 128 MB Max Memory Used: 84 MB
2025-11-24T22:04:04.204Z
START RequestId: bdfa38c3-0e88-4c6d-8171-bc9b81188fe5 Version: $LATEST
2025-11-24T22:04:04.205Z
🚗 INDUSTRY STANDARD ANALYSIS for identifier: nov24@gmail.com
2025-11-24T22:04:04.205Z
🔍 Looking up user by identifier: nov24@gmail.com
2025-11-24T22:04:04.205Z
📧 Searching by email: nov24@gmail.com
2025-11-24T22:04:04.223Z
✅ Found user by email: nov24@gmail.com (ID: 0c5df6f7-73de-4259-b2c6-aa0ef703a430)
2025-11-24T22:04:04.223Z
✅ Found user: nov24@gmail.com -> analyzing trips for ID: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:04:04.223Z
🔍 Getting base point for user: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:04:04.263Z
✅ Found user data for 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:04:04.263Z
📍 Using user-specific base point: Dublin, CA
2025-11-24T22:04:04.263Z
🔍 Getting trips for user: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:04:04.322Z
✅ Found 0 trips for user 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:04:04.324Z
END RequestId: bdfa38c3-0e88-4c6d-8171-bc9b81188fe5
2025-11-24T22:04:04.324Z
REPORT RequestId: bdfa38c3-0e88-4c6d-8171-bc9b81188fe5 Duration: 119.32 ms Billed Duration: 120 ms Memory Size: 128 MB Max Memory Used: 84 MB
2025-11-24T22:05:37.468Z
START RequestId: e5787453-9312-4107-9e94-673ef8e3b50c Version: $LATEST
2025-11-24T22:05:37.482Z
🚗 INDUSTRY STANDARD ANALYSIS for identifier: nov24@gmail.co
2025-11-24T22:05:37.482Z
🔍 Looking up user by identifier: nov24@gmail.co
2025-11-24T22:05:37.482Z
📧 Searching by email: nov24@gmail.co
2025-11-24T22:05:37.522Z
❌ No user found with email: nov24@gmail.co
2025-11-24T22:05:37.543Z
END RequestId: e5787453-9312-4107-9e94-673ef8e3b50c
2025-11-24T22:05:37.543Z
REPORT RequestId: e5787453-9312-4107-9e94-673ef8e3b50c Duration: 74.03 ms Billed Duration: 75 ms Memory Size: 128 MB Max Memory Used: 84 MB
2025-11-24T22:05:51.566Z
START RequestId: 59bacbe1-3b80-49f0-a287-c729b2ca5249 Version: $LATEST
2025-11-24T22:05:51.566Z
🚗 INDUSTRY STANDARD ANALYSIS for identifier: nov24@gmail.com
2025-11-24T22:05:51.566Z
🔍 Looking up user by identifier: nov24@gmail.com
2025-11-24T22:05:51.566Z
📧 Searching by email: nov24@gmail.com
2025-11-24T22:05:51.582Z
✅ Found user by email: nov24@gmail.com (ID: 0c5df6f7-73de-4259-b2c6-aa0ef703a430)
2025-11-24T22:05:51.582Z
✅ Found user: nov24@gmail.com -> analyzing trips for ID: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:05:51.582Z
🔍 Getting base point for user: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:05:51.622Z
✅ Found user data for 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:05:51.622Z
📍 Using user-specific base point: Dublin, CA
2025-11-24T22:05:51.622Z
🔍 Getting trips for user: 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:05:51.682Z
✅ Found 0 trips for user 0c5df6f7-73de-4259-b2c6-aa0ef703a430
2025-11-24T22:05:51.684Z
END RequestId: 59bacbe1-3b80-49f0-a287-c729b2ca5249
2025-11-24T22:05:51.684Z
REPORT RequestId: 59bacbe1-3b80-49f0-a287-c729b2ca5249 Duration: 117.66 ms Billed Duration: 118 ms Memory Size: 128 MB Max Memory Used: 84 MB