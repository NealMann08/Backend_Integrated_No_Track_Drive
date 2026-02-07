Below are only the iOS-specific plugins, permissions, Xcode settings, and setup steps required to enable continuous background location tracking in Flutter — tracking that continues when the app is minimized, screen is locked, or the app is killed after the user presses your "Start Tracking" button.

No coding examples — just the iOS setup you need.

✅ 1. Required Flutter Plugins

You need one of the following plugins that support background tracking on iOS:

Recommended (best for terminated-state tracking):
✔ background_locator_2
dependencies:
  background_locator_2: ^2.0.6

✅ 2. Xcode Capabilities Setup (REQUIRED)
Open your project:

ios/Runner.xcworkspace

In Xcode:

Runner → Signing & Capabilities → + Capability

Add the following capability:

✔ Background Modes

Enable:

Location updates

(Optional but recommended) Background fetch

Your screen should show:

[✓] Location updates  
[✓] Background fetch (optional)

✅ 3. Info.plist Required Keys

In ios/Runner/Info.plist, add these EXACT entries.

Permission texts
<key>NSLocationWhenInUseUsageDescription</key>
<string>Your location is used to provide tracking features.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Your location is used even in the background for tracking.</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>Your location is used even if the app is closed or not in use.</string>

Enable background location mode
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>

Optional (recommended): allow showing the blue bar indicator
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>processing</string>
</array>


⚠️ You must include the location background mode.
Without location in UIBackgroundModes, iOS will kill your tracking immediately.

✅ 4. Location Permissions That Must Be Granted on Device

Even though you request the permissions in Flutter, iOS requires manual user approval.

For continuous tracking, user must choose:

→ “Allow While Using App” first

→ then iOS will later prompt “Always Allow”

If user does not select “Always Allow”, background tracking will not continue.

⚠️ Best practice:
Prompt user with your in-app message telling them why Always Allow is required.

✅ 5. iOS Background Task Behavior (Important Notes)
🔹 iOS kills most background tasks

But location updates are exempt if:

UIBackgroundModes.location is enabled

User has granted Always Allow

You send location updates at least every ~15–30 seconds or when moving

🔹 App-terminated state

background_locator_2 supports:

continuing updates after app is terminated

restarting callbacks in an isolate

But this only works if:

Background location mode is enabled

Permission = Always Allow

The device detects actual movement

✅ 6. Additional iOS Configuration (recommended)
A. Enable "Prevent App from Being Suspended"

Xcode → Product → Scheme → Edit Scheme → Run → Options
✔ Check: Allow Location Simulation (for testing)
(Not required but helps debugging.)

B. Disable UIRequiredDeviceCapabilities (if present)

If Info.plist has this:

<key>UIRequiredDeviceCapabilities</key>
<array>
  <string>location-services</string>
</array>


→ Remove it. It causes App Store rejections.

C. Add Background Processing Task ID (optional)

For long-running processing:

<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
  <string>com.example.app.locationProcessing</string>
</array>


Only needed if you process large batches.