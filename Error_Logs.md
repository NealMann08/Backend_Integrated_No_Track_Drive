# AWS CLOUDWATCH LOGS

2025-11-24T04:45:01.234Z
INIT_START Runtime Version: python:3.9.v125 Runtime Version ARN: arn:aws:lambda:us-west-1::runtime:48c0f790371a08d913f94f05bbcb8cb1641dee331fe7924e60fd40126a861f01
2025-11-24T04:45:01.732Z
START RequestId: a1c8f0a6-b7df-4565-a7be-057ba8741d7b Version: $LATEST
2025-11-24T04:45:01.733Z
🚗 INDUSTRY STANDARD ANALYSIS for identifier: isp@gmail.com
2025-11-24T04:45:01.733Z
🔍 Looking up user by identifier: isp@gmail.com
2025-11-24T04:45:01.733Z
📧 Searching by email: isp@gmail.com
2025-11-24T04:45:01.979Z
✅ Found user by email: isp@gmail.com (ID: 8f9bbb25-4623-4e5b-bdca-3b68a6a9fd1b)
2025-11-24T04:45:01.979Z
✅ Found user: isp@gmail.com -> analyzing trips for ID: 8f9bbb25-4623-4e5b-bdca-3b68a6a9fd1b
2025-11-24T04:45:01.979Z
🔍 Getting base point for user: 8f9bbb25-4623-4e5b-bdca-3b68a6a9fd1b
2025-11-24T04:45:02.034Z
✅ Found user data for 8f9bbb25-4623-4e5b-bdca-3b68a6a9fd1b
2025-11-24T04:45:02.034Z
⚠️ No custom base point found for 8f9bbb25-4623-4e5b-bdca-3b68a6a9fd1b, using fallback
2025-11-24T04:45:02.034Z
🔍 Getting trips for user: 8f9bbb25-4623-4e5b-bdca-3b68a6a9fd1b
2025-11-24T04:45:02.114Z
✅ Found 0 trips for user 8f9bbb25-4623-4e5b-bdca-3b68a6a9fd1b
2025-11-24T04:45:02.134Z
END RequestId: a1c8f0a6-b7df-4565-a7be-057ba8741d7b
2025-11-24T04:45:02.134Z
REPORT RequestId: a1c8f0a6-b7df-4565-a7be-057ba8741d7b Duration: 400.95 ms Billed Duration: 896 ms Memory Size: 128 MB Max Memory Used: 83 MB Init Duration: 494.48 ms
2025-11-24T04:45:07.053Z
START RequestId: 36baace4-65e7-4b8f-8a38-35d7ea4d32da Version: $LATEST
2025-11-24T04:45:07.054Z
🚗 INDUSTRY STANDARD ANALYSIS for identifier: nov21@gmail.com
2025-11-24T04:45:07.054Z
🔍 Looking up user by identifier: nov21@gmail.com
2025-11-24T04:45:07.054Z
📧 Searching by email: nov21@gmail.com
2025-11-24T04:45:07.074Z
✅ Found user by email: nov21@gmail.com (ID: a690d93c-a03a-4856-bd4e-487d8c1d58a1)
2025-11-24T04:45:07.074Z
✅ Found user: nov21@gmail.com -> analyzing trips for ID: a690d93c-a03a-4856-bd4e-487d8c1d58a1
2025-11-24T04:45:07.074Z
🔍 Getting base point for user: a690d93c-a03a-4856-bd4e-487d8c1d58a1
2025-11-24T04:45:07.114Z
✅ Found user data for a690d93c-a03a-4856-bd4e-487d8c1d58a1
2025-11-24T04:45:07.114Z
📍 Using user-specific base point: Dublin, CA
2025-11-24T04:45:07.114Z
🔍 Getting trips for user: a690d93c-a03a-4856-bd4e-487d8c1d58a1
2025-11-24T04:45:07.234Z
✅ Found 2 trips for user a690d93c-a03a-4856-bd4e-487d8c1d58a1
2025-11-24T04:45:07.234Z
📊 Analyzing 2 trips with INTELLIGENT CACHING
2025-11-24T04:45:07.274Z
✅ CACHE HIT: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763779419073
2025-11-24T04:45:07.334Z
✅ USING CACHE: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763779419073
2025-11-24T04:45:07.373Z
❌ CACHE MISS: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953
2025-11-24T04:45:07.373Z
🔄 ANALYZING new trip: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953
2025-11-24T04:45:07.373Z
🎯 ANALYZING TRIP: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953 for user: a690d93c-a03a-4856-bd4e-487d8c1d58a1
2025-11-24T04:45:07.373Z
📖 Reading trip data from Trips-Neal table for: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953
2025-11-24T04:45:07.414Z
📅 TIMESTAMPS FROM TRIPS-NEAL:
2025-11-24T04:45:07.414Z
start_timestamp: 2025-11-21T17:04:22.953152+00:00
2025-11-24T04:45:07.414Z
end_timestamp: 2025-11-21T17:05:16.110895+00:00
2025-11-24T04:45:07.414Z
Available keys in Trips-Neal: ['user_id', 'created_at', 'end_timestamp', 'start_timestamp', 'status', 'trip_id', 'total_batches', 'finalized_at', 'trip_quality']
2025-11-24T04:45:07.414Z
📱 Found FRONTEND VALUES for trip: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953
2025-11-24T04:45:07.414Z
Frontend Distance: 0.000 miles
2025-11-24T04:45:07.414Z
Frontend Duration: 0.9 minutes
2025-11-24T04:45:07.414Z
Frontend Max Speed: 0.0 mph
2025-11-24T04:45:07.414Z
🔍 Getting batches for user: a690d93c-a03a-4856-bd4e-487d8c1d58a1, trip: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953
2025-11-24T04:45:07.533Z
✅ Found 1 batches for user a690d93c-a03a-4856-bd4e-487d8c1d58a1, trip trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953
2025-11-24T04:45:07.533Z
📦 Processing 1 batches
2025-11-24T04:45:07.533Z
Batch 1: 25 deltas
2025-11-24T04:45:07.533Z
📊 Total deltas to process: 25
2025-11-24T04:45:07.533Z
🚗 Processing 25 deltas
2025-11-24T04:45:07.533Z
📍 Base point: Dublin, CA
2025-11-24T04:45:07.533Z
📱 Using EXACT FRONTEND VALUES
2025-11-24T04:45:07.533Z
📊 FRONTEND VALUES:
2025-11-24T04:45:07.533Z
Distance: 0.000 miles
2025-11-24T04:45:07.533Z
Duration: 1m
2025-11-24T04:45:07.533Z
Max Speed: 0.0 mph
2025-11-24T04:45:07.533Z
Avg Speed: 0.0 mph
2025-11-24T04:45:07.533Z
❌ Invalid distance calculated: 0.0
2025-11-24T04:45:07.533Z
❌ Failed to process trip: trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763773462953
2025-11-24T04:45:07.533Z
📈 CACHE PERFORMANCE:
2025-11-24T04:45:07.533Z
Total Trips: 2
2025-11-24T04:45:07.533Z
✅ Cache Hits: 1 (50.0%) - FAST!
2025-11-24T04:45:07.534Z
❌ Cache Misses: 0
2025-11-24T04:45:07.534Z
🔄 Stale: 0
2025-11-24T04:45:07.534Z
💾 Cached This Run: 0
2025-11-24T04:45:07.534Z
✅ Successfully processed 1 trips (🚀 1 from cache!)
2025-11-24T04:45:07.574Z
🕐 User a690d93c-a03a-4856-bd4e-487d8c1d58a1 timezone: America/Los_Angeles (zipcode: 94568)
2025-11-24T04:45:07.574Z
🕐 Adding local time display fields for America/Los_Angeles
2025-11-24T04:45:07.574Z
📅 TIMESTAMP DEBUG - BEFORE PROCESSING:
2025-11-24T04:45:07.574Z
Trip 1/1 - trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763779419073
2025-11-24T04:45:07.574Z
start_timestamp:
2025-11-24T04:45:07.574Z
end_timestamp: 2025-11-23T02:18:48.786506
2025-11-24T04:45:07.574Z
✅ Added 'Z' to end_timestamp: 2025-11-23T02:18:48.786506Z
2025-11-24T04:45:07.593Z
📅 TIMESTAMP DEBUG - AFTER PROCESSING (FINAL):
2025-11-24T04:45:07.593Z
Trip 1/1 - trip_a690d93c-a03a-4856-bd4e-487d8c1d58a1_1763779419073
2025-11-24T04:45:07.593Z
start_timestamp:
2025-11-24T04:45:07.593Z
end_timestamp: 2025-11-23T02:18:48.786506Z
2025-11-24T04:45:07.593Z
🏆 ANALYSIS Complete:
2025-11-24T04:45:07.593Z
User: a690d93c-a03a-4856-bd4e-487d8c1d58a1
2025-11-24T04:45:07.593Z
Email: nov21@gmail.com
2025-11-24T04:45:07.593Z
Trips Analyzed: 1
2025-11-24T04:45:07.593Z
Total Distance: 0.30 miles
2025-11-24T04:45:07.593Z
Dominant Context: mixed (100.0% of distance)
2025-11-24T04:45:07.593Z
Overall Score: 88.5 (Excellent)
2025-11-24T04:45:07.593Z
Industry Rating: Exceptional
2025-11-24T04:45:07.593Z
Risk Level: Very Low Risk
2025-11-24T04:45:07.593Z
Moving Average Speed: 0.0 mph
2025-11-24T04:45:07.593Z
Overall Average Speed: 36.0 mph
2025-11-24T04:45:07.593Z
Time Moving: 0.0%
2025-11-24T04:45:07.593Z
Events per 100 miles: 0.00
2025-11-24T04:45:07.593Z
Privacy Protection: 100.0%
2025-11-24T04:45:07.593Z
✅ OPTIMIZED ANALYSIS COMPLETE - PRODUCTION READY
2025-11-24T04:45:07.593Z
🚀 Cache Performance: 50.0% hit rate (1/2 trips cached)
2025-11-24T04:45:07.595Z
END RequestId: 36baace4-65e7-4b8f-8a38-35d7ea4d32da
2025-11-24T04:45:07.595Z
REPORT RequestId: 36baace4-65e7-4b8f-8a38-35d7ea4d32da Duration: 541.33 ms Billed Duration: 542 ms Memory Size: 128 MB Max Memory Used: 84 MB