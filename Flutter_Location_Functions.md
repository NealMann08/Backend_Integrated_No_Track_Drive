Based on my research, here's a comprehensive breakdown of the necessary plugins and implementation requirements for your Drive Guard app's location tracking with speed data on iOS:
Required Flutter Packages
1. geolocator (you already have v14.0.2)

Purpose: Core location tracking - provides GPS coordinates, speed, altitude, heading, accuracy
Key Features:

getCurrentPosition() - get single location update
getPositionStream() - continuous location updates
Position object includes:

latitude, longitude
speed (in meters/second)
accuracy, altitude, heading
timestamp


Permission management
Location accuracy control



2. flutter_foreground_task (you already have v9.1.0)

Purpose: Keeps the app running in the background on iOS
Critical for iOS: iOS will suspend apps in background unless a foreground service is active
Provides: Persistent notification and background execution context


iOS-Specific Configuration Requirements
Info.plist Settings (ios/Runner/Info.plist)
You need ALL THREE of these keys for iOS 11+:
<key>NSLocationWhenInUseUsageDescription</key>
<string>Drive Guard needs your location to track your driving behavior and provide safety scores.</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>Drive Guard needs continuous location access to track your trips even when the app is in the background.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Drive Guard requires continuous location access to track your driving trips and calculate safety scores, even when the app is not actively open.</string>
Background Modes (Required for background location)
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>fetch</string>
    <string>processing</string>
</array>
In Xcode (Signing & Capabilities)

Go to your project target → Signing & Capabilities
Add Background Modes capability
Check Location updates


Critical iOS Permission Flow
iOS requires a two-step permission process: you must first request "When In Use" permission, and only after that's granted can you request "Always" permission. The "Always" option won't appear in the initial permission dialog. Stack OverflowGitHub
Implementation Flow:

First request LocationPermission.whileInUse
User grants "Allow While Using App"
Later (after app demonstrates value), request LocationPermission.always
iOS will then show option to change to "Always Allow" in settings


Getting Speed Data
The geolocator package provides speed directly in the Position object:
Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.bestForNavigation
);

// Speed is in meters per second
double speedMps = position.speed ?? 0.0;

// Convert to MPH
double speedMph = speedMps * 2.23694;

// Convert to KPH
double speedKph = speedMps * 3.6;
Important Notes:

Speed accuracy depends on the LocationAccuracy setting - higher accuracy = better speed data but more battery drain Pub.dev
Speed can be null if GPS doesn't have good signal
When stationary, speed may show small non-zero values due to GPS drift (typically < 0.5 m/s) GitHub
For best speed accuracy, use LocationAccuracy.bestForNavigation

Background Location Implementation for iOS
1. Location Settings Configuration
// For iOS background tracking
final locationSettings = AppleSettings(
  accuracy: LocationAccuracy.bestForNavigation,
  activityType: ActivityType.automotiveNavigation, // Optimized for driving
  distanceFilter: 0, // Get all updates
  pauseLocationUpdatesAutomatically: false, // Don't pause
  showBackgroundLocationIndicator: true, // Blue bar indicator
  allowBackgroundLocationUpdates: true, // CRITICAL for background
);
2. Foreground Task Integration
Your current implementation with flutter_foreground_task is correct. Key points:
// Initialize foreground task
FlutterForegroundTask.init(
  iosNotificationOptions: const IOSNotificationOptions(
    showNotification: true,
    playSound: false,
  ),
  foregroundTaskOptions: ForegroundTaskOptions(
    eventAction: ForegroundTaskEventAction.repeat(5000), // Every 5 seconds
    allowWakeLock: true,
  ),
);
3. Background Location Updates
In your LocationTaskHandler:
@override
Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
  // Get location with high accuracy
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.bestForNavigation
  );
  
  // Speed is directly available
  double speedMps = position.speed ?? 0.0;
  double speedMph = speedMps * 2.23694;
  
  // Store for UI updates
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('current_speed', speedMph);
  
  // Your existing delta calculation logic...
}
Debugging Your Current Issue
Based on your code and the issue you're experiencing (zero speed/GPS count), check:

Verify location settings include speed:

final locationSettings = AppleSettings(
  accuracy: LocationAccuracy.bestForNavigation, // Best for speed
  allowBackgroundLocationUpdates: true,
);

Confirm position.speed is not null:

double speedMph = (position.speed != null && position.speed! >= 0) 
    ? position.speed! * 2.23694 
    : 0.0;

Check Info.plist has all three location keys + UIBackgroundModes
Verify Background Modes enabled in Xcode capabilities
Test with real movement - GPS speed is only accurate when actually moving (walking/driving)

Summary Checklist
✅ Packages: geolocator (14.0.2) + flutter_foreground_task (9.1.0)
✅ Info.plist: All 3 NSLocation keys + UIBackgroundModes
✅ Xcode: Background Modes capability with Location updates checked
✅ Permissions: Request whileInUse first, then always
✅ Location Settings: Use AppleSettings with allowBackgroundLocationUpdates: true
✅ Speed: Available directly from position.speed (m/s)
✅ Foreground Service: Required for iOS background execution
Your current architecture is on the right track - the issue is likely in the configuration details or how you're reading/displaying the speed data rather than missing plugins.