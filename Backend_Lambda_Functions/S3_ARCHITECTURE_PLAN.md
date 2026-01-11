# S3-Based Trip Analysis Architecture

## Overview

This document outlines the future architecture using S3 for storing pre-computed trip analyses. This approach provides:

1. **Instant analytics loading** - No re-computation on each request
2. **Unlimited storage** - S3 scales infinitely
3. **Lower costs** - S3 is cheaper than DynamoDB for large data
4. **Better performance** - Analyses computed once at trip end

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           NEW S3 ARCHITECTURE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  TRIP RECORDING FLOW (unchanged):                                           │
│  ┌─────────┐    ┌──────────────────┐    ┌────────────────────┐             │
│  │ Flutter │───▶│ store-trajectory │───▶│ TrajectoryBatches  │             │
│  │  App    │    │     Lambda       │    │     DynamoDB       │             │
│  └─────────┘    └──────────────────┘    └────────────────────┘             │
│                                                                              │
│  TRIP FINALIZATION FLOW (modified):                                         │
│  ┌─────────┐    ┌──────────────────┐    ┌────────────────────┐             │
│  │ Flutter │───▶│  finalize-trip   │───▶│    Trips-Neal      │             │
│  │  App    │    │     Lambda       │    │     DynamoDB       │             │
│  └─────────┘    └───────┬──────────┘    └────────────────────┘             │
│                         │                                                    │
│                         │ 🆕 NEW: Run analysis immediately                  │
│                         ▼                                                    │
│                 ┌──────────────────┐                                        │
│                 │ Analyze trip     │                                        │
│                 │ (same algorithm) │                                        │
│                 └───────┬──────────┘                                        │
│                         │                                                    │
│                         │ 🆕 Store result in S3 (gzip compressed)          │
│                         ▼                                                    │
│                 ┌──────────────────────────────────────────────┐            │
│                 │  S3 Bucket: driveguard-analyses              │            │
│                 │                                               │            │
│                 │  Structure:                                   │            │
│                 │  /users/{user_id}/                           │            │
│                 │      /trips/{trip_id}_{timestamp}.json.gz    │            │
│                 │      /summary.json.gz (aggregated stats)     │            │
│                 └──────────────────────────────────────────────┘            │
│                                                                              │
│  ANALYTICS REQUEST FLOW (modified):                                         │
│  ┌─────────┐    ┌──────────────────┐    ┌────────────────────┐             │
│  │ Flutter │───▶│  analyze-driver  │───▶│  S3: List & Read   │             │
│  │  App    │    │     Lambda       │    │  Pre-computed JSON │             │
│  └─────────┘    └──────────────────┘    └────────────────────┘             │
│                                                                              │
│                 ✅ No heavy computation - just read files!                  │
│                 ✅ Response in 1-3 seconds for ANY number of trips          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## S3 Structure

```
s3://driveguard-analyses/
├── users/
│   ├── {user_id_1}/
│   │   ├── summary.json.gz          # Aggregated user stats
│   │   └── trips/
│   │       ├── trip_abc_1702345678000.json.gz
│   │       ├── trip_def_1702456789000.json.gz
│   │       └── trip_ghi_1702567890000.json.gz
│   │
│   ├── {user_id_2}/
│   │   ├── summary.json.gz
│   │   └── trips/
│   │       └── ...
│   └── ...
```

### File Naming Convention

```
{trip_id}_{end_timestamp_ms}.json.gz
```

Example: `trip_2bf09af3-af4e-4a22-bf62-26165e4a1341_1765325392829.json.gz`

This ensures:
- Unique file names per trip
- Chronological sorting by timestamp
- Easy identification of trip

---

## Implementation Steps

### Step 1: Create S3 Bucket

```bash
aws s3 mb s3://driveguard-analyses --region us-west-1
```

Enable versioning (for data recovery):
```bash
aws s3api put-bucket-versioning \
    --bucket driveguard-analyses \
    --versioning-configuration Status=Enabled
```

### Step 2: Update finalize-trip Lambda

Add IAM permissions:
```json
{
    "Effect": "Allow",
    "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
    ],
    "Resource": [
        "arn:aws:s3:::driveguard-analyses",
        "arn:aws:s3:::driveguard-analyses/*"
    ]
}
```

### Step 3: Modify finalize-trip.py

Add this code after trip finalization:

```python
import boto3
import gzip
import json

s3_client = boto3.client('s3')
ANALYSIS_BUCKET = 'driveguard-analyses'

def store_trip_analysis_s3(user_id: str, trip_id: str, analysis: Dict, end_timestamp_ms: int):
    """Store trip analysis in S3 with gzip compression"""
    try:
        # Create S3 key
        s3_key = f"users/{user_id}/trips/{trip_id}_{end_timestamp_ms}.json.gz"

        # Gzip compress the JSON
        json_bytes = json.dumps(analysis).encode('utf-8')
        compressed = gzip.compress(json_bytes)

        # Upload to S3
        s3_client.put_object(
            Bucket=ANALYSIS_BUCKET,
            Key=s3_key,
            Body=compressed,
            ContentType='application/json',
            ContentEncoding='gzip',
            Metadata={
                'trip_id': trip_id,
                'user_id': user_id,
                'behavior_score': str(analysis.get('behavior_score', 0))
            }
        )

        print(f"✅ Stored analysis in S3: {s3_key}")
        print(f"   Original size: {len(json_bytes)} bytes")
        print(f"   Compressed size: {len(compressed)} bytes ({len(compressed)/len(json_bytes)*100:.1f}%)")

        return True
    except Exception as e:
        print(f"❌ S3 storage error: {e}")
        return False
```

### Step 4: Create New analyze-driver Lambda

```python
import boto3
import gzip
import json
from typing import List, Dict

s3_client = boto3.client('s3')
ANALYSIS_BUCKET = 'driveguard-analyses'

def get_user_analyses_from_s3(user_id: str) -> List[Dict]:
    """Retrieve all pre-computed analyses for a user from S3"""
    try:
        # List all trip files for user
        prefix = f"users/{user_id}/trips/"

        response = s3_client.list_objects_v2(
            Bucket=ANALYSIS_BUCKET,
            Prefix=prefix
        )

        if 'Contents' not in response:
            return []

        analyses = []

        for obj in response['Contents']:
            key = obj['Key']

            # Download and decompress
            s3_response = s3_client.get_object(Bucket=ANALYSIS_BUCKET, Key=key)
            compressed_body = s3_response['Body'].read()
            json_bytes = gzip.decompress(compressed_body)
            analysis = json.loads(json_bytes.decode('utf-8'))

            analyses.append(analysis)

        # Sort by timestamp (newest first)
        analyses.sort(key=lambda x: x.get('end_timestamp', ''), reverse=True)

        print(f"✅ Retrieved {len(analyses)} analyses from S3 for user {user_id}")
        return analyses

    except Exception as e:
        print(f"❌ S3 retrieval error: {e}")
        return []


def lambda_handler(event, context):
    """New analyze-driver using S3 pre-computed analyses"""

    # Get user identifier from request
    query_params = event.get('queryStringParameters', {})
    user_email = query_params.get('email')

    # Look up user_id from email
    user_data = lookup_user_by_email(user_email)
    user_id = user_data['user_id']

    # 🚀 FAST: Just read pre-computed analyses from S3
    trip_analyses = get_user_analyses_from_s3(user_id)

    if not trip_analyses:
        return error_response(404, 'No trips found')

    # Aggregate statistics (simple math, very fast)
    total_trips = len(trip_analyses)
    total_distance = sum(t.get('total_distance_miles', 0) for t in trip_analyses)

    # Weighted average score
    if total_distance > 0:
        weighted_score = sum(
            t.get('behavior_score', 0) * t.get('total_distance_miles', 0)
            for t in trip_analyses
        ) / total_distance
    else:
        weighted_score = sum(t.get('behavior_score', 0) for t in trip_analyses) / total_trips

    return {
        'statusCode': 200,
        'body': json.dumps({
            'user_id': user_id,
            'total_trips': total_trips,
            'total_distance_miles': total_distance,
            'overall_behavior_score': round(weighted_score, 1),
            'trips': trip_analyses  # Already analyzed!
        })
    }
```

---

## Migration Plan

### Phase 1: Parallel Write (Week 1-2)
1. Deploy updated `finalize-trip` that writes to BOTH DynamoDB AND S3
2. Monitor S3 writes for errors
3. Verify data consistency

### Phase 2: Gradual Rollout (Week 3-4)
1. Deploy new `analyze-driver-s3` Lambda
2. Route 10% of traffic to new Lambda
3. Monitor performance and errors
4. Gradually increase to 100%

### Phase 3: Cleanup (Week 5+)
1. Archive old `DrivingSummaries-Neal` data
2. Remove DynamoDB analysis code
3. Update documentation

---

## Cost Comparison

### Current (DynamoDB-based)
| Resource | Monthly Cost |
|----------|--------------|
| DynamoDB reads | ~$15-30 |
| DynamoDB writes | ~$5-10 |
| Lambda compute | ~$20-50 |
| **Total** | **~$40-90/month** |

### S3-based Architecture
| Resource | Monthly Cost |
|----------|--------------|
| S3 storage | ~$1-5 (gzip compressed) |
| S3 GET requests | ~$0.50-2 |
| Lambda compute | ~$5-15 (much less) |
| **Total** | **~$7-22/month** |

**Estimated savings: 60-80%**

---

## Performance Expectations

| Metric | Current | With S3 |
|--------|---------|---------|
| Response time (4 trips) | 3-8 sec | 0.5-2 sec |
| Response time (100 trips) | 30-60 sec | 2-5 sec |
| Response time (500 trips) | Timeout | 5-10 sec |
| Memory usage | High | Low |
| Scalability | Limited | Unlimited |

---

## Rollback Plan

If issues occur:
1. Revert Lambda alias to previous version
2. S3 data is preserved (versioned)
3. DynamoDB still has original data during parallel write phase

---

## Questions to Resolve

1. **Retention policy**: How long to keep old trip analyses? (30 days? Forever?)
2. **Access patterns**: Do insurance users need different data than drivers?
3. **Real-time requirements**: Is 1-2 second delay acceptable for analytics?

---

## Next Steps

1. ✅ Apply quick fixes (done)
2. ⬜ Update Lambda memory (AWS Console)
3. ⬜ Deploy and test quick fixes
4. ⬜ Create S3 bucket
5. ⬜ Implement Phase 1 (parallel write)
6. ⬜ Test thoroughly
7. ⬜ Roll out Phase 2-3
