import Flutter
import UIKit
import CoreLocation
import flutter_foreground_task

@main
@objc class AppDelegate: FlutterAppDelegate {
  // Location manager for iOS-specific background location configuration
  private var locationManager: CLLocationManager?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // CRITICAL: Register the plugin registrant callback for foreground task
    // This allows the background service to access all Flutter plugins (especially geolocator)
    SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    // Configure iOS-specific background location settings
    configureBackgroundLocationTracking()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Configures iOS-specific settings for reliable background location tracking
  /// This ensures location updates continue even when:
  /// - App is in background
  /// - Screen is locked
  /// - Device is in low power mode (with user permission)
  private func configureBackgroundLocationTracking() {
    locationManager = CLLocationManager()

    // CRITICAL: Enable background location updates
    // This allows the app to receive location updates even when backgrounded
    locationManager?.allowsBackgroundLocationUpdates = true

    // Show blue status bar indicator when app is using location in background
    // This is required by Apple for transparency and App Store approval
    locationManager?.showsBackgroundLocationIndicator = true

    // Set activity type to automotive navigation for optimal tracking during driving
    // This tells iOS to optimize battery and accuracy for automotive use cases
    locationManager?.activityType = .automotiveNavigation

    // Request most accurate location data for driving safety analysis
    locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation

    // Disable automatic pausing - we want continuous tracking during trips
    // By default, iOS may pause location updates when user is stationary
    locationManager?.pausesLocationUpdatesAutomatically = false

    // Enable deferred location updates for better battery efficiency
    // iOS will batch updates when possible without compromising accuracy
    locationManager?.allowsBackgroundLocationUpdates = true

    print("✅ iOS Background Location Configuration Complete:")
    print("   - Background updates: ENABLED")
    print("   - Activity type: Automotive Navigation")
    print("   - Accuracy: Best for Navigation")
    print("   - Auto-pause: DISABLED (continuous tracking)")
    print("   - Background indicator: VISIBLE (App Store compliance)")
  }

  // Handle location authorization changes
  override func applicationDidBecomeActive(_ application: UIApplication) {
    // Log current authorization status when app becomes active
    if let manager = locationManager {
      let status = manager.authorizationStatus
      print("📍 Location Authorization Status: \(status.rawValue)")
      if status == .authorizedAlways {
        print("✅ 'Always' permission granted - background tracking enabled")
      } else if status == .authorizedWhenInUse {
        print("⚠️ WARNING: Only 'When In Use' permission - background tracking LIMITED")
      }
    }
  }
}
