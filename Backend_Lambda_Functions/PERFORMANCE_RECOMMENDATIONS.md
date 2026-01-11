# Performance Optimization Recommendations for Drive Guard

## Immediate AWS Configuration Changes

### 1. Increase Lambda Memory (CRITICAL)

**Current**: 128 MB (max used: 107 MB = 83% - dangerously close)
**Recommended**: 512 MB or 1024 MB

**Why**: AWS Lambda allocates CPU proportionally to memory. More memory = more CPU = faster execution.

**How to change**:
1. Go to AWS Lambda Console
2. Select `analyze-driver` function
3. Configuration → General configuration → Edit
4. Change Memory to 512 MB (or 1024 MB for large datasets)
5. Save

**Expected improvement**: 2-4x faster execution

### 2. Increase Lambda Timeout

**Current**: 30 seconds (likely hitting timeout for 503 errors)
**Recommended**: 60 seconds

**How to change**:
1. AWS Lambda Console → `analyze-driver` function
2. Configuration → General configuration → Edit
3. Change Timeout to 60 seconds
4. Save

### 3. Create DynamoDB GSI (Optional, for further optimization)

If you want even better performance, create this index on `TrajectoryBatches-Neal`:

**Index Name**: `trip_id-batch_number-index`
**Partition Key**: `trip_id` (String)
**Sort Key**: `batch_number` (Number)

This enables direct queries by trip_id without scanning user's entire batch history.

---

## Code Changes Summary (Already Applied)

### 1. DynamoDB Query Optimization
- Added `FilterExpression` to filter batches server-side
- Prevents loading ALL user batches into Lambda memory

### 2. Cache Invalidation Fix
- Fixed bug comparing `end_timestamp` with itself
- Now uses `analysis_cached_at` for proper cache validation
- Expected cache hit rate: 90%+ for unchanged trips

### 3. Trips Query Optimization
- Query `Trips-Neal` directly instead of `TrajectoryBatches-Neal`
- Uses `user_id-timestamp-index` GSI
- Much faster: 1 record per trip vs many batch records

### 4. Pagination Support
- All queries now handle `LastEvaluatedKey`
- Supports unlimited trips without truncation

---

## Expected Performance After Changes

| Metric | Before | After |
|--------|--------|-------|
| Response time (4 trips) | 42 seconds | 3-8 seconds |
| Cache hit rate | 0% | 80-95% |
| Memory usage | 107/128 MB | ~60/512 MB |
| Timeout errors | Frequent | Rare |

---

## Future: S3-Based Architecture

For long-term scalability with thousands of trips, implement the S3 architecture:

### Phase 1: Analyze at Trip End (finalize-trip)
1. When trip ends, run full analysis immediately
2. Store result in S3: `s3://your-bucket/users/{user_id}/trips/{trip_id}-{timestamp}.json.gz`
3. Compress with gzip (70-90% size reduction)

### Phase 2: Fast Analytics Retrieval (analyze-driver)
1. List all S3 objects for user: `s3://bucket/users/{user_id}/trips/`
2. Read pre-computed JSON files (already analyzed)
3. Aggregate scores (simple math, no heavy computation)

### Benefits:
- Analytics load instantly (no re-computation)
- Unlimited trip storage (S3 is cheaper than DynamoDB)
- Each trip analyzed only ONCE (at finalization)
- Gzip compression reduces storage costs 70-90%

See `S3_ARCHITECTURE_PLAN.md` for detailed implementation guide.
