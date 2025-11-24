# Backend Lambda Deployment Guide

## Problem Identified

The **insurance email search is failing with 500 errors** because the deployed Lambda function (`analyze-driver`) is **incomplete**.

### Root Cause:
- The file `analyze-driver-OPTIMIZED.py` is a template with missing functions
- Lines 339-361 say "copy ALL functions from original analyze-driver.py"
- Critical functions are missing:
  - `lookup_user_by_email_or_id()` - Called at line 405
  - `get_user_base_point()` - Called at line 423
  - `analyze_single_trip_with_frontend_values()` - Called multiple times
  - `get_user_trips_fixed()` - Called at line 269

### Error Evidence:
```
m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/analyze-driver?email=isp@gmail.com
Failed to load resource: the server responded with a status of 500 ()
```

---

## Solution: Deploy Complete Lambda Function

I've created **`analyze-driver-COMPLETE.py`** with all required functions.

---

## Deployment Steps

### Option 1: AWS Lambda Console (Easiest)

1. **Open AWS Lambda Console**
   - Go to: https://console.aws.amazon.com/lambda
   - Region: `us-west-1` (California)

2. **Find the Function**
   - Search for: `analyze-driver` or whatever your function is named

3. **Update Code**
   - Click on the function name
   - In the "Code" tab, click "Upload from" → ".zip file" OR
   - Copy/paste the entire contents of `analyze-driver-COMPLETE.py` into the inline editor

4. **Click "Deploy"**
   - Wait for deployment to complete (~10 seconds)

5. **Test**
   - Go to "Test" tab
   - Create test event:
   ```json
   {
     "queryStringParameters": {
       "email": "nov21@gmail.com"
     }
   }
   ```
   - Click "Test"
   - Should return 200 with driver analytics (or 404 if driver not found)

---

### Option 2: AWS CLI (Faster for updates)

1. **Package the function**
   ```bash
   cd Backend_Lambda_Functions
   zip analyze-driver.zip analyze-driver-COMPLETE.py
   ```

2. **Deploy to Lambda**
   ```bash
   aws lambda update-function-code \
     --function-name analyze-driver \
     --zip-file fileb://analyze-driver.zip \
     --region us-west-1
   ```

3. **Wait for update**
   ```bash
   aws lambda wait function-updated \
     --function-name analyze-driver \
     --region us-west-1
   ```

4. **Test**
   ```bash
   aws lambda invoke \
     --function-name analyze-driver \
     --region us-west-1 \
     --payload '{"queryStringParameters":{"email":"nov21@gmail.com"}}' \
     response.json

   cat response.json
   ```

---

### Option 3: Rename and Use Complete Version

If you want to keep the OPTIMIZED version for future reference:

1. **Rename files locally**
   ```bash
   cd Backend_Lambda_Functions
   mv analyze-driver.py analyze-driver-EMPTY.py
   mv analyze-driver-COMPLETE.py analyze-driver.py
   ```

2. **Deploy using your existing deployment script** (if you have one)

---

## Verify Deployment

### Test in Browser Console:
```javascript
fetch('https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/analyze-driver?email=nov21@gmail.com')
  .then(r => r.json())
  .then(data => console.log(data))
  .catch(err => console.error(err));
```

### Expected Success Response (200):
```json
{
  "user_id": "nov21-gmail-com",
  "email": "nov21@gmail.com",
  "name": "John Doe",
  "total_trips": 5,
  "total_distance_miles": 124.5,
  "avg_behavior_score": 87.3,
  "trips": [...]
}
```

### Expected Not Found Response (404):
```json
{
  "error": "Driver not found",
  "searched_for": "nonexistent@gmail.com"
}
```

### Should NO LONGER see (500):
```json
{
  "error": "Internal server error: name 'lookup_user_by_email_or_id' is not defined"
}
```

---

## DynamoDB Requirements

The Lambda function expects these tables in `us-west-1`:

1. **Users-Neal**
   - Primary Key: `user_id` (String)
   - Contains: email, base_point, name

2. **Trips-Neal**
   - Primary Key: `trip_id` (String)
   - GSI: `user_id-timestamp-index` (user_id, timestamp)

3. **TrajectoryBatches-Neal**
   - Primary Key: `trip_id` (String)
   - Contains: points (List of delta coordinates)

---

## Frontend Testing After Deployment

1. Login as insurance provider: `isp@gmail.com`
2. Go to Dashboard
3. Search for driver: `nov21@gmail.com` (or any driver email)
4. Should see:
   - ✅ Driver analytics with trip history
   - ✅ Behavior scores
   - ✅ Total distance and events

If driver doesn't exist:
   - ✅ "No driver found with email: nov21@gmail.com"

---

## Troubleshooting

### Still getting 500 errors?

1. **Check CloudWatch Logs:**
   - AWS Console → CloudWatch → Log Groups
   - Find: `/aws/lambda/analyze-driver`
   - Look at most recent log stream

2. **Common issues:**
   - Wrong DynamoDB table names
   - Missing IAM permissions for Lambda
   - Incorrect region (should be us-west-1)

3. **Lambda Configuration:**
   - Runtime: Python 3.9 or higher
   - Timeout: 30 seconds minimum (300 seconds recommended)
   - Memory: 512 MB minimum

### Getting 404 for valid drivers?

- Check that driver has completed trips
- Verify user exists in Users-Neal table
- Check user_id format matches

---

## Next Steps

1. ✅ Deploy `analyze-driver-COMPLETE.py` to AWS Lambda
2. ✅ Test in AWS Console first
3. ✅ Test from insurance dashboard
4. ✅ Verify error messages are specific (not generic 500s)

---

**Once deployed, the insurance provider dashboard should work correctly.**
