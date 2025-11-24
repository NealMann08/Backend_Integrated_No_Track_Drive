# Timezone Fix - Trip Timestamps

## 🐛 Issues Fixed

### Issue #1: All timestamps were in UTC
**Problem:** Trip dates and times displayed in UTC (AWS server time) instead of user's local timezone

**Root Cause:** No timezone conversion logic existed

**Fix:** Added automatic timezone conversion based on user's zipcode

---

### Issue #2: DrivingSummaries-Neal had wrong timestamps
**Problem:** Cached trip analyses showed the date/time when the analysis was fetched, not when the trip actually occurred

**Example:**
- Trip completed: November 18, 2024 at 3:30 PM
- Analysis fetched: November 22, 2024 at 10:00 AM
- DrivingSummaries showed: November 22 (WRONG!)
- Should show: November 18 (CORRECT!)

**Root Cause:** Line 281 in cache function used `datetime.utcnow()` as fallback instead of actual trip timestamp

**Fix:** Changed to use `trip_analysis.get('end_timestamp', '')` to preserve actual trip time

---

## ✅ Changes Made

### 1. Added Timezone Conversion Functions (Lines 24-138)

```python
# US Zipcode prefix to timezone mapping
ZIPCODE_TIMEZONE_MAP = {
    '0': 'America/New_York',    # New England
    '1': 'America/New_York',    # NY, PA
    '2': 'America/New_York',    # DC, MD, VA
    '3': 'America/New_York',    # AL, FL, GA, MS, TN, NC, SC
    '4': 'America/Chicago',     # IN, KY, MI, OH
    '5': 'America/Chicago',     # IA, MN, MT, ND, SD, WI
    '6': 'America/Chicago',     # IL, KS, MO, NE
    '7': 'America/Chicago',     # AR, LA, OK, TX
    '8': 'America/Denver',      # AZ, CO, ID, NM, NV, UT, WY
    '9': 'America/Los_Angeles', # CA, OR, WA, AK, HI
}

def get_user_timezone(user_id: str) -> str:
    """Get user's timezone based on zipcode"""

def convert_utc_to_local(utc_timestamp_str: str, timezone_str: str) -> str:
    """Convert UTC timestamp to local timezone"""

def format_timestamp_with_timezone(utc_timestamp_str: str, timezone_str: str) -> Dict:
    """Format timestamp with both UTC and local time"""
```

### 2. Fixed Cache Function to Use Actual Trip Timestamp (Lines 280-287)

**BEFORE (WRONG):**
```python
'timestamp': trip_analysis.get('end_timestamp', datetime.utcnow().isoformat()),
'cached_at': datetime.utcnow().isoformat()
```

**AFTER (CORRECT):**
```python
'end_timestamp': trip_analysis.get('end_timestamp', ''),  # ACTUAL trip end time
'timestamp': trip_analysis.get('end_timestamp', ''),      # Use trip time, NOT current time
'analysis_cached_at': datetime.utcnow().isoformat()       # When analysis was cached (metadata)
```

### 3. Added Timezone Conversion in Lambda Handler (Lines 1952-1969)

```python
# Get user's timezone from their zipcode
user_timezone = get_user_timezone(user_id)

# Convert all trip timestamps to local time
for trip in trip_analyses:
    if trip.get('start_timestamp'):
        trip['start_timestamp_utc'] = trip['start_timestamp']  # Preserve UTC
        trip['start_timestamp'] = convert_utc_to_local(trip['start_timestamp'], user_timezone)
        trip['start_time_formatted'] = format_timestamp_with_timezone(...)

    if trip.get('end_timestamp'):
        trip['end_timestamp_utc'] = trip['end_timestamp']  # Preserve UTC
        trip['end_timestamp'] = convert_utc_to_local(trip['end_timestamp'], user_timezone)
        trip['end_time_formatted'] = format_timestamp_with_timezone(...)

    trip['timezone'] = user_timezone
```

### 4. Added Timezone Info to Response (Lines 2146-2148)

```python
'user_timezone': user_timezone,
'timezone_note': 'All trip timestamps are displayed in user\'s local timezone based on zipcode',
```

---

## 📊 Response Format Changes

### Before (UTC Only)
```json
{
  "trips": [
    {
      "trip_id": "trip-123",
      "start_timestamp": "2024-11-18T19:30:00",  // UTC (confusing!)
      "end_timestamp": "2024-11-18T20:15:00"     // UTC
    }
  ]
}
```

### After (Local Time + Formatted)
```json
{
  "user_timezone": "America/Los_Angeles",
  "timezone_note": "All trip timestamps are displayed in user's local timezone based on zipcode",
  "trips": [
    {
      "trip_id": "trip-123",
      "start_timestamp": "2024-11-18T11:30:00",  // Pacific Time (8 hours behind UTC)
      "start_timestamp_utc": "2024-11-18T19:30:00",  // Original UTC preserved
      "start_time_formatted": {
        "utc": "2024-11-18T19:30:00",
        "local": "2024-11-18T11:30:00",
        "formatted": "2024-11-18 11:30:00 AM",
        "date": "2024-11-18",
        "time": "11:30:00 AM",
        "timezone": "America/Los_Angeles"
      },
      "end_timestamp": "2024-11-18T12:15:00",  // Pacific Time
      "end_timestamp_utc": "2024-11-18T20:15:00",
      "end_time_formatted": {
        "utc": "2024-11-18T20:15:00",
        "local": "2024-11-18T12:15:00",
        "formatted": "2024-11-18 12:15:00 PM",
        "date": "2024-11-18",
        "time": "12:15:00 PM",
        "timezone": "America/Los_Angeles"
      },
      "timezone": "America/Los_Angeles"
    }
  ]
}
```

---

## 🕐 Timezone Mapping by Zipcode

| Zipcode Prefix | Timezone | States |
|----------------|----------|---------|
| 0 | Eastern (America/New_York) | CT, MA, ME, NH, NJ, RI, VT |
| 1 | Eastern (America/New_York) | DE, NY, PA |
| 2 | Eastern (America/New_York) | DC, MD, NC, SC, VA, WV |
| 3 | Eastern (America/New_York) | AL, FL, GA, MS, TN |
| 4 | Central (America/Chicago) | IN, KY, MI, OH |
| 5 | Central (America/Chicago) | IA, MN, MT, ND, SD, WI |
| 6 | Central (America/Chicago) | IL, KS, MO, NE |
| 7 | Central (America/Chicago) | AR, LA, OK, TX |
| 8 | Mountain (America/Denver) | AZ, CO, ID, NM, NV, UT, WY |
| 9 | Pacific (America/Los_Angeles) | AK, CA, HI, OR, WA |

**Note:** Some states span multiple timezones. The mapping uses the most common timezone for each zipcode prefix.

---

## 🔍 Testing After Deployment

### Test 1: Verify Timezone Detection
```python
# Check user's timezone is detected correctly
response = analyze_driver("nov21@gmail.com")
print(response['user_timezone'])
# Should show: "America/Los_Angeles" (if zipcode starts with 9)
# Or: "America/New_York" (if zipcode starts with 0-3)
# Or: "America/Chicago" (if zipcode starts with 4-7)
# Or: "America/Denver" (if zipcode starts with 8)
```

### Test 2: Verify Timestamps are Converted
```python
# Check trip timestamps are in local time
response = analyze_driver("nov21@gmail.com")
trip = response['trips'][0]

print("Start Time (Local):", trip['start_timestamp'])
print("Start Time (UTC):", trip['start_timestamp_utc'])
print("Formatted:", trip['start_time_formatted']['formatted'])

# Example output:
# Start Time (Local): 2024-11-18T11:30:00
# Start Time (UTC): 2024-11-18T19:30:00
# Formatted: 2024-11-18 11:30:00 AM
```

### Test 3: Verify DrivingSummaries Uses Actual Trip Time
```bash
# Complete a trip on Nov 18
# Fetch analysis on Nov 22
# Check DynamoDB DrivingSummaries-Neal table

aws dynamodb get-item \
  --table-name DrivingSummaries-Neal \
  --key '{"trip_id": {"S": "your-trip-id"}}' \
  --region us-west-1

# Check fields:
# - timestamp: Should be Nov 18 (trip end time) ✅
# - analysis_cached_at: Nov 22 (when analyzed) ✅
```

---

## 🚨 Important Notes

### Python Version Requirement
This fix uses `zoneinfo` module which requires **Python 3.9+**

**Lambda Configuration:**
```
Runtime: Python 3.9 or higher
```

If your Lambda is on Python 3.8 or lower, you'll get:
```
ModuleNotFoundError: No module named 'zoneinfo'
```

**Fix:** Update Lambda runtime to Python 3.9, 3.10, 3.11, or 3.12

### Default Timezone
If user has no zipcode or zipcode is invalid:
- **Default:** `America/New_York` (Eastern Time)
- Logs will show: `⚠️ No zipcode for user X, defaulting to America/New_York`

### UTC Timestamps Preserved
The fix preserves original UTC timestamps in:
- `start_timestamp_utc`
- `end_timestamp_utc`

This ensures you can still:
- Sort trips chronologically across timezones
- Perform calculations in UTC
- Display in any timezone later

---

## 📝 Deployment Checklist

- [ ] Lambda runtime is Python 3.9 or higher
- [ ] Updated code deployed to Lambda
- [ ] Test timezone detection works
- [ ] Test timestamps show in local time
- [ ] Verify DrivingSummaries uses actual trip time (not analysis time)
- [ ] Check CloudWatch logs for timezone conversion messages
- [ ] Confirm insurance dashboard shows correct dates/times

---

## 🔧 Troubleshooting

### Error: "No module named 'zoneinfo'"
**Cause:** Lambda runtime is Python 3.8 or lower

**Fix:**
1. AWS Console → Lambda → Configuration → General configuration
2. Change Runtime to: Python 3.9 (or 3.10, 3.11, 3.12)
3. Save

### Timestamps Still Showing UTC
**Cause:** Old cached data in DrivingSummaries-Neal from before fix

**Fix:**
```bash
# Clear cache for specific user's trips
aws dynamodb scan --table-name DrivingSummaries-Neal \
  --filter-expression "user_id = :uid" \
  --expression-attribute-values '{":uid":{"S":"user-id-here"}}' \
  --region us-west-1 \
  | jq -r '.Items[].trip_id.S' \
  | xargs -I {} aws dynamodb delete-item \
      --table-name DrivingSummaries-Neal \
      --key '{"trip_id": {"S": "{}"}}' \
      --region us-west-1
```

Next request will rebuild cache with correct timezones.

### Wrong Timezone Detected
**Cause:** Zipcode prefix doesn't match expected timezone

**Examples:**
- Indiana (zipcode 46xxx) shows Central but should be Eastern
- Arizona (zipcode 85xxx) shows Mountain but doesn't use DST

**Fix:** Update `ZIPCODE_TIMEZONE_MAP` for specific edge cases, or add more granular zipcode ranges.

---

## ✅ Summary

**Two bugs fixed:**
1. ✅ Timestamps converted from UTC to user's local timezone based on zipcode
2. ✅ DrivingSummaries-Neal now stores actual trip timestamp (not analysis fetch time)

**Benefits:**
- 🕐 Drivers see trips in their local time
- 📅 Correct dates regardless of when analysis is fetched
- 🌎 Timezone detected automatically from zipcode
- 📊 Both UTC and local times available in response

**Deploy the updated `analyze-driver-OPTIMIZED.py` and test!**
