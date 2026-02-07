Drive Guard - Comprehensive Application Documentation
Application Overview
Core Purpose
Drive Guard is a privacy-focused driver behavior tracking application designed to generate safety scores for insurance companies while protecting user privacy. The app serves as an intermediary between drivers and insurance providers, collecting driving behavior data without compromising the driver's location privacy through innovative delta coordinate technology.
Three-Tiered User System

Drivers (End Users): Individuals whose driving behavior is being monitored and scored
Service Providers (Insurance Companies): Organizations that receive driving analyses and safety scores to make insurance decisions
Admins: System moderators who oversee and manage the platform

Privacy Innovation
The cornerstone of Drive Guard's privacy protection is its delta coordinate system. Instead of storing absolute GPS coordinates, the app:

Uses the user's zipcode to calculate a central base point
Converts all GPS coordinates to relative deltas from this base point
Multiplies deltas by 1,000,000 for fixed-point precision storage
Transmits only these relative coordinates to the backend, making it impossible to determine absolute location without knowing the user's base point


Technical Architecture
Frontend

Framework: Flutter (transitioned from Ionic-React)
Platforms: iOS (deployed via TestFlight), Android, and Web
Key Packages:

flutter_foreground_task (v9.1.0) - Background location tracking
geolocator (v14.0.2) - GPS coordinate acquisition
Platform-specific location tracking implementations



Backend

Infrastructure: AWS Lambda serverless functions
Database: DynamoDB for data persistence
API Endpoints: RESTful Lambda functions with specific data format requirements


File Structure and Purpose
Core Application Files
main.dart

Application entry point
Initializes Flutter app and routing
Sets up global state management
Configures background task handling
Establishes initial app permissions

login_page.dart

User authentication interface
Communicates with auth_user-Neal.py Lambda function
Validates credentials and establishes user session
Routes users to appropriate home page based on role (driver/admin/insurance)

user_home_page.dart

Primary interface for driver users
Displays current safety score
Shows trip history summary
Provides access to start new trips
Navigation hub to other driver features

admin_home_page.dart

Dashboard for system administrators
User management interface
System-wide statistics and monitoring
Access to moderation tools

insurance_home_page.dart

Interface for insurance provider users
Driver lookup and analysis tools
Bulk score retrieval capabilities
Integration with insurance workflows

current_trip_page.dart

Real-time trip monitoring interface
Displays live data during active trips:

Current speed
Maximum speed reached
Distance traveled
Number of data points collected
Trip duration


Controls to end trip
Visual feedback of tracking status

previous_trips_page.dart

Historical trip data viewer
Lists all completed trips with:

Date and time
Distance traveled
Duration
Safety metrics


Detailed trip analysis view

score_page.dart

Displays user's overall safety score
Score breakdown by category
Historical score trends
Comparison metrics

graph_Score_Page.dart

Visual representation of safety scores
Trend analysis charts
Performance metrics over time
Category-specific visualizations

user_score_page.dart (Admin/Insurance view)

Lookup interface for viewing other users' scores
Comprehensive driver analysis
Risk assessment metrics

user_trips_page.dart (Admin/Insurance view)

Detailed view of specific user's trip history
Trip-by-trip analysis
Pattern recognition data

settings_page.dart

User preferences configuration
Account settings hub
Navigation to sub-settings pages

account_settings_page.dart

Profile information management
Email and contact details
User role information

appearance_page.dart

UI customization options
Theme preferences
Display settings

notifications_page.dart

Notification preferences
Alert configuration
Push notification settings

privacySecurity_page.dart

Privacy policy access
Security settings hub
Data management options

privacy_page.dart

Detailed privacy policy display
Data usage explanation
Rights and controls information

changePassword_page.dart

Password update interface
Security verification
Password strength validation

helpSupport_page.dart

User support resources
FAQ access
Contact support functionality

about_page.dart

App version information
Developer credits
Terms of service access

account_page.dart

Comprehensive account management
Subscription information (if applicable)
Account deletion options

Utility Files
custom_app_bar.dart

Reusable app bar component
Consistent navigation across app
Standardized UI element

data_manager.dart

Local data persistence layer
Caches user data and preferences
Manages session information
Handles data synchronization with backend

geocodingutils.dart

Zipcode to coordinate conversion
Base point calculation from zipcode
Delta coordinate computation
Coordinate transformation utilities
Multiplies deltas by 1,000,000 for backend storage

location_foreground_task.dart

Background location tracking service
Manages continuous GPS data collection
Handles location permissions
Platform-specific tracking implementations
Ensures tracking continues when app is closed or phone is locked

trip_helper.dart

Trip management utilities
Trip state management
Data batching logic (groups points into batches of 25)
Trip calculation helpers (distance, duration, etc.)

ipconfig.dart

API endpoint configuration
Backend URL management
Environment-specific settings

user_lookup.dart

User search functionality
Driver information retrieval
Cross-reference utilities

InsuranceLookup.dart

Insurance-specific lookup tools
Driver analysis interfaces
Bulk query capabilities

Backend Lambda Functions
auth_user-Neal.py

User authentication
Credential validation
Session token generation
Role-based access control

store-trajectory-batch.py

Receives batches of exactly 25 delta coordinate points
Validates data format (deltas must be multiplied by 1,000,000)
Stores trajectory data in DynamoDB
Associates data with active trip ID

finalize-trip_py.py

Called when user ends trip
Aggregates all trajectory data for the trip
Calculates trip statistics
Triggers driver analysis

analyze_driver_py.py

Processes complete trip data
Applies safety scoring algorithms
Calculates metrics:

Speed violations
Harsh braking events
Rapid acceleration
Cornering behavior
Overall safety score


Updates user's aggregate safety score

update_user_zipcode.py

Updates user's base zipcode
Recalculates base coordinate point
Maintains privacy by updating delta reference point


Complete Application Flow - Perfect Use Case
Phase 1: User Registration and Setup

Initial Launch

User opens Drive Guard app
App initializes main.dart
Background task services initialize via location_foreground_task.dart
App checks for existing session in data_manager.dart


Authentication

User navigates to login_page.dart
Enters credentials (email/password)
App sends authentication request to auth_user-Neal.py Lambda function
Backend validates credentials against DynamoDB
Lambda returns session token and user role
data_manager.dart stores session information locally


Zipcode Configuration

New user is prompted to enter zipcode
App sends zipcode to update_user_zipcode.py Lambda
geocodingutils.dart calculates base coordinate point from zipcode
Base point stored in DynamoDB associated with user account
This base point becomes the reference for all future delta calculations


Home Screen Display

Based on user role, app routes to appropriate home:

Driver → user_home_page.dart
Admin → admin_home_page.dart
Insurance → insurance_home_page.dart


Driver sees current safety score (initially 0 or default)
Trip history shows empty (no trips yet)



Phase 2: Starting a Trip

Trip Initiation

Driver taps "Start Trip" button on user_home_page.dart
App requests location permissions (if not already granted)
Permissions dialog appears (handled by platform-specific code)
User grants "Always Allow" location permission (required for background tracking)


Background Service Activation

location_foreground_task.dart starts foreground service
iOS: Creates notification showing "Drive Guard is tracking your trip"
Android: Creates persistent foreground service notification
Background task begins continuous GPS polling (every 1-5 seconds based on movement)


Trip Session Creation

App generates unique trip ID (UUID)
trip_helper.dart initializes new trip object:

Trip ID
User ID
Start timestamp
Initial location (as delta coordinates)
Empty trajectory array


Trip state saved to data_manager.dart


Navigation to Active Trip

App automatically navigates to current_trip_page.dart
UI displays:

Trip timer starting at 00:00:00
Current speed: 0 mph
Max speed: 0 mph
Distance: 0.00 miles
Points collected: 0


"End Trip" button is active



Phase 3: Active Trip Tracking

Continuous Location Collection

Background service polls GPS every 1-5 seconds
For each GPS reading:

Latitude and longitude received from device
geocodingutils.dart retrieves user's base coordinate point
Calculate delta: deltaLat = (currentLat - baseLat) * 1,000,000
Calculate delta: deltaLon = (currentLon - baseLon) * 1,000,000
Create data point object:





       {
         "timestamp": ISO_8601_timestamp,
         "delta_lat": integer_delta_latitude,
         "delta_lon": integer_delta_longitude,
         "speed": current_speed_mph,
         "accuracy": gps_accuracy_meters
       }

Real-Time UI Updates (if app is open)

current_trip_page.dart updates every second:

Trip duration increments
Current speed updates from latest GPS reading
Max speed updates if current speed exceeds previous max
Distance calculates using Haversine formula on delta coordinates
Points collected counter increments


All updates happen smoothly without flickering


Data Batching Logic

trip_helper.dart accumulates data points in memory
When exactly 25 points collected:

Create batch payload:





        {
          "trip_id": "uuid",
          "user_id": "user_id",
          "batch_number": integer,
          "points": [array_of_25_delta_coordinate_objects]
        }
  - Send POST request to `store-trajectory-batch.py` Lambda
  - Lambda validates:
    - Exactly 25 points present
    - All delta values are integers (already multiplied by 1,000,000)
    - Trip ID exists and is active
    - User ID matches authenticated user
  - Lambda stores batch in DynamoDB
  - Lambda returns success confirmation
  - Local batch cleared, counter resets to 0
12. Background Persistence
- User locks phone or switches apps
- Background service continues uninterrupted
- iOS: Foreground service notification keeps app alive
- Android: Foreground service prevents system termination
- GPS polling continues at same rate
- Data points continue accumulating
- Batches continue sending every 25 points
- No data loss occurs
Phase 4: Trip Completion

Ending the Trip

User returns to app
Opens current_trip_page.dart (or notification brings them there)
Taps "End Trip" button
Confirmation dialog appears: "Are you sure you want to end this trip?"
User confirms


Final Data Transmission

trip_helper.dart checks for remaining points (< 25)
If points exist:

Creates final batch with remaining points (even if less than 25)
Marks batch as "final_batch": true
Sends to store-trajectory-batch.py


Background location service stops
Foreground service notification dismissed


Trip Finalization

App sends request to finalize-trip_py.py with trip ID
Lambda function:

Retrieves all batches for trip ID from DynamoDB
Aggregates all data points
Calculates comprehensive trip statistics:

Total distance (sum of distances between consecutive points)
Total duration (end timestamp - start timestamp)
Average speed (total distance / total duration)
Maximum speed (highest speed value in all points)
Number of data points


Stores finalized trip summary in DynamoDB
Marks trip as "completed"
Returns trip summary to app




Driver Analysis Trigger

finalize-trip_py.py automatically invokes analyze_driver_py.py
Or analyze_driver_py.py called separately after finalization
Analysis Lambda:

Retrieves all trip data (entire trajectory)
Converts delta coordinates back to relative coordinates for analysis
Applies safety algorithms:
Speed Analysis:

Identifies speed limit violations (if speed limit data available)
Counts percentage of time spent speeding
Weights excessive speeding (>15 mph over) heavily

Acceleration Analysis:

Calculates acceleration between consecutive points
Identifies harsh acceleration events (> 8 mph/s)
Counts rapid acceleration occurrences

Braking Analysis:

Calculates deceleration between consecutive points
Identifies harsh braking events (> -8 mph/s)
Counts hard stops

Cornering Analysis:

Calculates direction changes between points
Identifies sharp turns at speed
Evaluates cornering smoothness

Overall Score Calculation:

Weighted algorithm combines all metrics
Generates score from 0-100
Higher score = safer driver
Formula applies penalties for unsafe behaviors


Stores trip score in DynamoDB
Updates user's aggregate safety score (rolling average of recent trips)
Returns analysis results




UI Update and Feedback

App receives trip summary and analysis
current_trip_page.dart transitions to summary view showing:

Trip distance
Trip duration
Average speed
Max speed
Safety score for this trip


"View Details" button navigates to full trip analysis
User can return to user_home_page.dart



Phase 5: Viewing History and Scores

Home Screen Update

user_home_page.dart refreshes
Updated overall safety score displays
Trip history now shows completed trip
Score visualization updates in real-time


Previous Trips View

User taps "Trip History" button
Navigates to previous_trips_page.dart
App requests trip list from backend
DynamoDB query retrieves all user's completed trips
Trips display in reverse chronological order:

Date and time
Duration
Distance
Score badge (color-coded by safety level)


User can tap any trip for details


Detailed Trip Analysis

User selects specific trip
App requests full trip data from backend
Detailed view displays:

All trip statistics
Breakdown of safety metrics
List of flagged events (harsh braking, speeding, etc.)
Score explanation
Map visualization possible (using delta coordinates)




Score Dashboard

User navigates to score_page.dart
Displays comprehensive safety profile:

Overall safety score (large, prominent)
Score trend (improving/declining)
Category breakdown:

Speeding score
Acceleration score
Braking score
Cornering score


Percentile ranking (compared to all drivers)
Recommendations for improvement




Score Visualization

User navigates to graph_Score_Page.dart
Interactive charts display:

Score over time (line graph)
Category comparison (radar chart)
Trip-by-trip scores (bar graph)
Improvement trends


User can filter by date range
Export options available



Phase 6: Insurance Provider Access

Insurance Login

Insurance provider logs in via login_page.dart
auth_user-Neal.py validates insurance credentials
User routed to insurance_home_page.dart


Driver Lookup

Insurance user uses InsuranceLookup.dart interface
Searches for driver by:

Email
Driver ID
Name
Policy number


Backend queries DynamoDB for matching users
Results display with basic info and current score


Driver Analysis View

Insurance user selects specific driver
Navigates to user_score_page.dart
Comprehensive driver profile displays:

Overall safety score
Total trips recorded
Total miles driven
Risk assessment level
Detailed score breakdown
Recommendations for premium adjustment




Trip History Review

Insurance user navigates to user_trips_page.dart for selected driver
Views all driver's trips
Can drill down into individual trip details
Can export data for underwriting analysis
Privacy protected: absolute locations never revealed, only delta-based analytics



Phase 7: Admin Functions

Admin Dashboard

Admin logs in via login_page.dart
Routed to admin_home_page.dart
Dashboard shows:

Total users (drivers, insurance providers)
Total trips today/week/month
System health metrics
Recent user activity




User Management

Admin uses user_lookup.dart interface
Can search and view any user
Access to:

User details
Account status
Trip history
Safety scores


Can suspend or delete accounts
Can adjust user roles


System Monitoring

Admin reviews system-wide statistics
Monitors Lambda function performance
Checks for failed trips or data issues
Reviews user feedback and support requests



Phase 8: Settings and Account Management

User Settings

User navigates to settings_page.dart
Hub for all configuration options
Links to sub-pages for specific settings


Account Settings

account_settings_page.dart allows:

Email update
Name update
Zipcode update (triggers base point recalculation)
Profile picture upload




Appearance Customization

appearance_page.dart provides:

Light/dark mode toggle
Color theme selection
Font size adjustment
Language preference




Notification Preferences

notifications_page.dart manages:

Trip reminder notifications
Score update alerts
Achievement notifications
Push notification permissions




Privacy and Security

privacySecurity_page.dart hub links to:

Privacy policy (privacy_page.dart)
Data deletion requests
Export personal data
Two-factor authentication setup




Password Management

User accesses changePassword_page.dart
Enters current password for verification
Creates new password meeting requirements
Backend updates encrypted password in DynamoDB


Help and Support

helpSupport_page.dart provides:

FAQ access
Contact support form
Tutorial videos
Community forum link




About Information

about_page.dart displays:

App version
Terms of service
Open source licenses
Developer information






Data Flow Architecture
Coordinate Privacy Flow

User's zipcode → Base coordinate (lat, lon)
GPS reading → (current_lat, current_lon)
Delta calculation → (delta_lat * 1,000,000, delta_lon * 1,000,000)
Transmission → Only deltas sent to backend
Storage → Only deltas stored in DynamoDB
Privacy guarantee → Absolute location unknown without base coordinate

Trip Data Flow

Location data collected → Local buffer
Buffer reaches 25 points → Batch created
Batch sent → store-trajectory-batch.py
Backend validates → Stores in DynamoDB
Trip ends → finalize-trip_py.py aggregates
Analysis triggered → analyze_driver_py.py processes
Score calculated → Stored and returned
UI updates → User sees results

Authentication Flow

User enters credentials → login_page.dart
Request sent → auth_user-Neal.py
Lambda validates → Checks DynamoDB
Session token generated → Returned to app
Token stored → data_manager.dart
Token attached → All subsequent API requests
Backend validates token → Each request


Platform-Specific Considerations
iOS

Uses flutter_foreground_task for background tracking
Requires "Always Allow" location permission
Info.plist configured with location usage descriptions
CocoaPods dependency management
TestFlight deployment for testing

Android

Uses foreground service for background tracking
AndroidManifest.xml configured with location permissions
Persistent notification required for foreground service
Google Play Store deployment

Web

Background tracking not available
Uses alternative tracking when tab is active
Limited functionality compared to mobile
Focus on data viewing rather than collection


Error Handling and Edge Cases
Network Issues

Failed batch uploads queued locally
Automatic retry with exponential backoff
User notified if prolonged connectivity issues

Permission Denials

Clear messaging about required permissions
In-app guidance to system settings
Graceful degradation if permissions denied

Battery Optimization

Adjustable GPS polling rate
Battery-saving mode option
User control over tracking frequency

Trip Interruptions

Phone restart during trip → Trip auto-resumes
App crash → Trip recovers from last saved state
Force quit → User prompted to resume on next open


This comprehensive documentation represents Drive Guard in its ideal, fully functional state with all features working as designed, all data flowing correctly, and all privacy protections active. The app successfully balances comprehensive driving behavior analysis with industry-leading privacy protection through its innovative delta coordinate system.