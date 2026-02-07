# Xcode Build & TestFlight Distribution Guide

Complete reference guide for building and distributing Drive Guard iOS app to TestFlight.

---

## Quick Reference Commands

```bash
# Full clean rebuild (run from project root)
cd "C:\Users\nealm\OneDrive\Desktop\No_Track_drive_APP\notrackdriveapp"
flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter build ios --release

# Open in Xcode (ALWAYS use .xcworkspace)
open ios/Runner.xcworkspace
```

**In Xcode:** Product → Archive → Distribute App → App Store Connect → Upload

---

## Complete Step-by-Step Process

### STEP 1: Clean and Rebuild Flutter Dependencies

Run these commands from your project root directory:

```bash
# Navigate to project directory
cd "C:\Users\nealm\OneDrive\Desktop\No_Track_drive_APP\notrackdriveapp"

# Clean Flutter build cache
flutter clean

# Get all Flutter dependencies
flutter pub get

# Navigate to iOS directory
cd ios

# Remove old Pods (ensures fresh CocoaPods installation)
rm -rf Pods
rm -rf Podfile.lock

# Install/update CocoaPods dependencies
pod install

# Return to project root
cd ..
```

**What this does:**
- Removes cached build files
- Downloads latest Flutter package dependencies
- Reinstalls iOS native dependencies (CocoaPods)
- Ensures all plugins are properly linked

---

### STEP 2: Build for iOS Release

```bash
# Build iOS release version
flutter build ios --release
```

**What this does:**
- Compiles Dart code to native ARM code
- Generates iOS framework
- Updates all plugin registrations
- Creates optimized release build in `ios/build/ios/iphoneos/`

**Expected output:**
```
Building com.example.driveguard for device (ios-release)...
Running pod install...
Running Xcode build...
└─Compiling, linking and signing...
Built build/ios/iphoneos/Runner.app
```

---

### STEP 3: Open in Xcode

```bash
# Open the WORKSPACE file (not .xcodeproj)
open ios/Runner.xcworkspace
```

**CRITICAL WARNING:**
- ✅ Always open `Runner.xcworkspace`
- ❌ Never open `Runner.xcodeproj` directly

**Why?** The workspace includes both your app and all CocoaPods dependencies. Opening the .xcodeproj alone will cause build failures.

---

### STEP 4: Configure Signing & Capabilities

1. **Select Runner** in the Project Navigator (left sidebar)
2. **Select Runner target** under TARGETS (not the project)
3. Click **Signing & Capabilities** tab

#### Signing Configuration:
- **Automatically manage signing:** ✅ (recommended) or configure manually
- **Team:** Select your Apple Developer Team
- **Bundle Identifier:** Should be pre-set (e.g., `com.yourcompany.driveguard`)
- **Signing Certificate:** "Apple Distribution" for TestFlight/App Store

#### Verify Capabilities:
Ensure these capabilities are present (should already be configured):

- ✅ **Background Modes**
  - Location updates
  - Background fetch
  - Background processing

**Info.plist Permissions** (should already be set):
- NSLocationWhenInUseUsageDescription
- NSLocationAlwaysAndWhenInUseUsageDescription
- NSLocationAlwaysUsageDescription
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription

---

### STEP 5: Set Build Configuration to Release

1. Go to **Product** menu → **Scheme** → **Edit Scheme...**
2. In the left sidebar, select **Run**
3. Under **Info** tab → **Build Configuration:** Select **Release**
4. In the left sidebar, select **Archive**
5. Under **Info** tab → **Build Configuration:** Ensure it's **Release**
6. Click **Close**

**Why this matters:** Release mode optimizes the app, removes debug symbols, and creates a production-ready build.

---

### STEP 6: Select Device Target

1. In Xcode toolbar (top), click the **device selector** (next to Run/Stop buttons)
2. Select **Any iOS Device (arm64)**

**Do NOT select:**
- ❌ iPhone Simulator
- ❌ Specific device (unless testing)

**Why "Any iOS Device"?** Creates a universal build compatible with all iOS devices (iPhone and iPad).

---

### STEP 7: Archive the App

1. Go to **Product** menu → **Archive**
2. Wait for the build process to complete (2-5 minutes)
3. Xcode Organizer window will automatically open when done

**What's happening:**
- Building app in Release mode
- Code signing with your distribution certificate
- Creating .xcarchive file
- Preparing for distribution

**Troubleshooting:**
- If Archive is greyed out → ensure you selected "Any iOS Device" (not simulator)
- If build fails → check signing configuration and certificates

---

### STEP 8: Distribute to TestFlight

When the **Organizer** window opens:

1. **Select your archive** (the one at the top, most recent)
2. Click **Distribute App** button (right side)
3. Select **App Store Connect**
4. Click **Next**

#### Distribution Method:
5. Select **Upload** (not Export)
6. Click **Next**

#### Distribution Options:
7. Configure these options:
   - **Include bitcode:** NO (Apple deprecated this)
   - **Upload your app's symbols:** YES (enables crash reports)
   - **Manage version and build number:** YES (recommended)
8. Click **Next**

#### Signing:
9. Select **Automatically manage signing** (recommended)
   - Or choose manual if you have specific certificates
10. Click **Next**

#### Review and Upload:
11. **Review** the summary page
    - Verify app name, version, bundle ID
    - Check signing certificate is valid
12. Click **Upload**

#### Upload Progress:
13. Wait for upload to complete (1-3 minutes depending on connection)
14. You'll see "Upload Successful" when done
15. Click **Done**

---

### STEP 9: Wait for App Store Connect Processing

1. Go to **App Store Connect**: https://appstoreconnect.apple.com
2. Sign in with your Apple Developer account
3. Navigate to **My Apps** → **Drive Guard** → **TestFlight**
4. Your build will show as "Processing"

**Processing Time:** 10-30 minutes (sometimes up to 1 hour)

**What's happening:**
- Apple is scanning for malware
- Validating app signatures
- Processing symbols
- Preparing for distribution

**When processing completes:**
- Status changes from "Processing" to "Ready to Test"
- You'll receive an email notification
- Build becomes available to distribute to testers

---

### STEP 10: Distribute to Testers

Once processing is complete:

#### Internal Testing:
1. In **TestFlight** tab, find your build
2. Click on the build number
3. Under **Internal Testing**, add testers or groups
4. Testers receive email/notification to install via TestFlight app

#### External Testing (Optional):
1. Create an External Test group
2. Add testers (up to 10,000)
3. Submit for Beta App Review (first time only)
4. Once approved, testers can install

---

## Post-Build Testing Checklist

After installing on iPhone via TestFlight, verify:

### Test Sequence:
1. ✅ **Login** with test account
2. ✅ **Grant "Always" location permission** when prompted
3. ✅ **Start a trip** - tap "Start Tracking"
4. ✅ **Check initial state:**
   - Service starts successfully
   - Points counter begins at 0
5. ✅ **Wait 10-20 seconds stationary:**
   - Points should start increasing (5-10 points)
   - Speed should show 0.0 mph
6. ✅ **Move around (drive or walk):**
   - Points continue increasing
   - Speed updates to actual speed
   - Max speed updates when you go faster
7. ✅ **Lock phone screen:**
   - Tracking continues in background
   - Blue location indicator appears in status bar
8. ✅ **Background the app:**
   - Tracking continues
   - Check notification shows "Location Tracking" active
9. ✅ **Wait for 25+ points:**
   - Verify batch upload occurs (every 25 points)
10. ✅ **Stop trip:**
    - Final batch uploads
    - Trip finalizes successfully
11. ✅ **Check backend:**
    - Trip appears in user history
    - Points and distance calculated
    - Score generated

### Expected Behavior:
- **Web platform:** Points accumulate immediately (timer-based)
- **iOS platform:** Points accumulate after fix (foreground service)
- **Batch size:** 25 points per upload
- **Polling interval:** Every 2 seconds

---

## Troubleshooting Common Issues

### Issue: "Archive" is greyed out
**Solution:** Select "Any iOS Device (arm64)" instead of a simulator

### Issue: Code signing error
**Solution:**
1. Check Xcode → Preferences → Accounts → Your Apple ID is signed in
2. Verify your team has valid certificates
3. Try automatic signing instead of manual

### Issue: "No profiles for 'com.yourapp' were found"
**Solution:**
1. Go to developer.apple.com
2. Certificates, Identifiers & Profiles
3. Create App ID if missing
4. Create Distribution provisioning profile
5. Download and install in Xcode

### Issue: Build fails with CocoaPods error
**Solution:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod install
cd ..
flutter clean
flutter build ios --release
```

### Issue: "Runner.xcworkspace doesn't exist"
**Solution:**
```bash
cd ios
pod install
cd ..
```

### Issue: Points stay at 0 on iOS
**Solution:** Ensure AppDelegate.swift has the plugin registrant callback (fixed in latest version)

### Issue: Upload to App Store Connect fails
**Solution:**
1. Check your Apple Developer Program membership is active
2. Verify app bundle ID matches App Store Connect
3. Ensure version/build number is higher than previous uploads

---

## Version Management

### Incrementing Version Numbers

#### For minor updates (bug fixes):
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Change to 1.0.0+2 (increment build number)
```

#### For feature updates:
```yaml
version: 1.0.0+1  # Change to 1.1.0+1 (increment minor version, reset build)
```

#### For major updates:
```yaml
version: 1.0.0+1  # Change to 2.0.0+1 (increment major version)
```

**Or use command line:**
```bash
# Increment build number
flutter build ios --release --build-number=2

# Set version and build
flutter build ios --release --build-name=1.1.0 --build-number=1
```

---

## Important Notes

### Always Remember:
1. ✅ Clean before major builds: `flutter clean`
2. ✅ Use `.xcworkspace` not `.xcodeproj`
3. ✅ Build configuration must be **Release** for Archive
4. ✅ Select "Any iOS Device" before archiving
5. ✅ Upload symbols for crash reporting
6. ✅ Test on real device via TestFlight before production release

### File Locations:
- **Archive location:** `~/Library/Developer/Xcode/Archives/`
- **Derived Data:** `~/Library/Developer/Xcode/DerivedData/`
- **Provisioning Profiles:** `~/Library/MobileDevice/Provisioning Profiles/`

### Best Practices:
- Keep old archives for rollback capability
- Test each build thoroughly before promoting to production
- Increment build numbers for each upload
- Keep release notes updated in App Store Connect
- Monitor crash reports in App Store Connect

---

## Emergency: Revert to Previous Build

If new build has critical issues:

1. Go to **App Store Connect** → **TestFlight**
2. Find previous working build
3. Select it and distribute to testers
4. Fix issues in code
5. Follow this guide to build and upload fixed version

---

## Automation (Optional - Advanced)

### Fastlane Setup

For automated builds, consider using Fastlane:

```bash
# Install fastlane
sudo gem install fastlane

# Initialize in project
cd ios
fastlane init
```

This guide covers manual process. Automation can be added later as needed.

---

## Support Resources

- **Flutter iOS Deployment:** https://docs.flutter.dev/deployment/ios
- **App Store Connect:** https://appstoreconnect.apple.com
- **TestFlight Help:** https://developer.apple.com/testflight/
- **Xcode Documentation:** https://developer.apple.com/documentation/xcode

---

**Last Updated:** November 20, 2024
**App:** Drive Guard
**Platform:** iOS
**Distribution:** TestFlight / App Store
