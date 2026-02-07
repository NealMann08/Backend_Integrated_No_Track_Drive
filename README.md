# DriveGuard - Safe Driving Analytics Platform

A cross-platform mobile application that tracks driving behavior, calculates safety scores, and provides detailed analytics to help drivers improve their habits. Built with Flutter for the frontend and AWS Lambda for the backend.

## Project Overview

DriveGuard was created to solve a real problem: helping drivers understand and improve their driving habits while potentially qualifying for lower insurance rates. The app records trips using GPS and accelerometer data, analyzes driving patterns on the backend, and presents actionable insights through an intuitive interface.

### Key Features

- **Trip Recording**: Real-time GPS tracking with accelerometer data to detect sudden braking, acceleration, and turns
- **Safety Scoring**: Algorithmic analysis of driving behavior resulting in a 0-100 safety score
- **Trip History**: View past trips with detailed breakdowns of events and scores
- **Multi-Role Support**: Different interfaces for regular drivers, insurance providers, and administrators
- **PDF Reports**: Generate and share detailed driving reports
- **Cross-Platform**: Works on iOS, Android, and web browsers

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter Frontend                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │   Driver    │  │  Insurance  │  │    Admin    │              │
│  │  Dashboard  │  │  Dashboard  │  │  Dashboard  │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     AWS API Gateway                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Lambda Functions                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │  auth-user  │  │ trip-handler│  │analyze-driver│             │
│  │   (Login)   │  │  (Record)   │  │  (Scoring)  │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        DynamoDB                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │    Users    │  │    Trips    │  │   Analytics │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
lib/
├── main.dart                   # App entry point
├── login_page.dart             # Authentication UI
├── home_page.dart              # Main router (routes to appropriate dashboard)
│
├── User Pages
│   ├── user_home_page.dart     # Driver's main dashboard
│   ├── current_trip_page.dart  # Active trip recording screen
│   ├── previous_trips_page.dart# Trip history list
│   └── score_page.dart         # Safety score and full report
│
├── Insurance Provider Pages
│   └── insurance_home_page.dart# Insurance dashboard with user lookup
│
├── Admin Pages
│   └── admin_home_page.dart    # Admin dashboard
│
├── Settings
│   ├── settings_page.dart      # Main settings screen
│   ├── changePassword_page.dart# Password change functionality
│   ├── helpSupport_page.dart   # Contact support
│   ├── notifications_page.dart # Notification preferences
│   └── privacySecurity_page.dart # Privacy settings
│
├── Utilities
│   ├── custom_app_bar.dart     # Navigation bar component
│   ├── data_manager.dart       # Caching layer for API data
│   ├── trip_helper.dart        # Trip-related utility functions
│   ├── geocodingutils.dart     # Zipcode to coordinates conversion
│   └── ipconfig.dart           # Server configuration
│
└── background_location_handler.dart # Background GPS tracking
```

## How It Works

### Trip Recording

1. User taps "Start Trip" on the home screen
2. App requests GPS permission and starts location updates
3. Location points are collected every few seconds along with accelerometer data
4. Data is batched and sent to the backend periodically (every ~20 points)
5. User taps "End Trip" to finalize and get their score

### Safety Score Calculation

The backend analyzes each trip based on several factors:

- **Speed Consistency**: How steady the driver maintains speed (fewer sudden changes = better)
- **Acceleration Patterns**: Smooth acceleration vs. aggressive pedal mashing
- **Braking Behavior**: Gradual stops vs. sudden hard braking
- **Turn Speed**: Taking turns at appropriate speeds

Each factor contributes to an overall behavior score from 0-100.

### Data Flow

```
Phone GPS → Location Stream → Batch Upload → Lambda Processing
                                                    │
                                              DynamoDB
                                                    │
Score Request ← analyze-driver ← Trip Data Analysis
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- iOS Simulator / Android Emulator or physical device
- AWS account (for backend)

### Installation

1. Clone the repository
```bash
git clone [repository-url]
cd Backend_Integrated_No_Track_Drive
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

### Configuration

The app connects to AWS API Gateway endpoints configured in `lib/ipconfig.dart`. The backend Lambda functions handle:

- `/auth-user` - User authentication and registration
- `/trip-handler` - Trip data upload and management
- `/analyze-driver` - Safety score calculation and analytics

## Technical Decisions

### Why Flutter?

I chose Flutter because it allowed me to build for iOS, Android, and web from a single codebase. This was important because I wanted the app to be accessible to as many users as possible without maintaining three separate codebases.

### Why AWS Lambda?

Serverless made sense for this project because:
- The workload is bursty (trips happen irregularly)
- Auto-scaling handles variable load without manual intervention
- Pay-per-use pricing keeps costs low during development

### Caching Strategy

The `DataManager` class implements a caching layer that:
- Stores analytics data in memory for quick access
- Persists to SharedPreferences for offline support
- Validates cache ownership to prevent data leakage between users
- Expires after 1 hour to keep data reasonably fresh

### Navigation Guard

A key feature is blocking navigation during active trips. This prevents users from accidentally leaving the trip screen and losing their data. The `CustomAppBar` checks for active trips before allowing navigation.

## Challenges and Solutions

### Challenge 1: Background Location Tracking

iOS and Android have strict rules about background location access. I had to implement careful battery management and use the `background_location` package to maintain GPS tracking when the app is backgrounded.

### Challenge 2: Data Batching

Sending every GPS point individually would be inefficient and could fail on poor connections. The solution was to batch points locally and send them in groups of 20, with retry logic for failed uploads.

### Challenge 3: Multi-User Data Security

Early versions had a bug where switching accounts could show cached data from the previous user. I fixed this by tying the cache to a specific user ID and clearing it on logout or account switch.

## Future Improvements

- Add offline trip recording with sync when back online
- Implement push notifications for driving tips
- Add social features to compare scores with friends
- Integration with actual insurance APIs

## Dependencies

Key packages used:

- `geolocator` - GPS location services
- `google_maps_flutter` - Map visualization
- `shared_preferences` - Local data persistence
- `http` - API requests
- `percent_indicator` - Score visualization
- `pdf` - Report generation
- `share_plus` - Sharing functionality

See `pubspec.yaml` for the complete list.

## Backend

The Lambda functions are located in `Backend_Lambda_Functions/`. Each function is documented with its purpose and API contract.

---

## Author

**Neal Mann**

### Acknowledgments

This project was developed independently with the aid of AI-assisted development tools. Specifically, [Claude](https://www.anthropic.com/claude) (Anthropic, 2025) was used as a coding assistant for debugging, code review, and clarifying technical questions during development. All architectural decisions, core logic implementation, and project design are my own work.

**AI Tools Used:**
- Claude (via Claude Code CLI) - Used for debugging assistance, answering technical questions about Flutter/Dart syntax, and code cleanup/refactoring suggestions

This acknowledgment follows emerging best practices for transparent disclosure of AI tool usage in software development, similar to acknowledging use of Stack Overflow, documentation, or other reference materials.
