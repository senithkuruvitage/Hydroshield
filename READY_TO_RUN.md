# HydroShield - Ready to Run Guide

## Prerequisites
1. **Flutter SDK**: Latest stable version (3.22+)
2. **Android Studio**: For Android development
3. **Xcode**: For iOS development (macOS required)
4. **Firebase Project**: Created at console.firebase.google.com

## Setup Steps

### 1. Install Dependencies
```bash
cd C:\hydroshield
flutter pub get
```

### 2. Firebase Configuration
#### For Android:
1. Go to Firebase Console
2. Add Android app: `com.example.hydroshield` (or your package name)
3. Download `google-services.json`
4. Place at: `C:\hydroshield\android\app\google-services.json`

#### For iOS (macOS required):
1. Go to Firebase Console
2. Add iOS app: `hydroshield`
3. Download `GoogleService-Info.plist`
4. Place at: `C:\hydroshield\ios\Runner\GoogleService-Info.plist`

### 3. Configure Firebase Settings
Edit `lib/data/services/device_service.dart` and `lib/data/services/mqtt_device_service.dart`:
- Set your Firebase project configuration
- Initialize Firebase Auth with email/password provider
- Set up Cloud Firestore rules
- Configure Firebase Cloud Messaging

### 4. Run the App

#### Android:
```bash
flutter devices          # List connected devices
flutter run -d android   # Run on Android
# or
flutter run              # Run on first available device
```

#### iOS (macOS):
```bash
flutter devices          # List available simulators
flutter run -d ios       # Run on iOS simulator
# or
flutter run              # Run on first available simulator
```

### 5. Initial Setup
On first run:
1. The app will show the Login screen
2. Select "Owner" or "Renter" role
3. For Owner: Create a property and invite renters
4. For Renter: Accept invitation and start using the app

### 6. Mock Hardware Testing
The app includes a **MockDeviceService** that simulates IoT hardware:
- Generates realistic fill/drain/idle cycles
- All animation states can be tested without physical devices
- Streams provide tank level, flow rate, valve state, cleaning status
- Override the service in `main.dart` to use real MQTT later

### 7. Key Commands
```bash
# Check for updates
flutter pub outdated

# Analyze code
flutter analyze

# Build release
flutter build apk       # Android
flutter build ios       # iOS

# Hot restart
flutter run -r          # Warm reload
flutter run -R          # Cold restart
```

## Project Structure
```
C:\hydroshield\
├── android/            # Android project files
├── ios/                # iOS project files
├── lib/
│   ├── core/           # theme, constants, utils, router
│   ├── data/           # models, repositories, services
│   ├── features/       # auth, tank_level, cleaning, etc.
│   └── shared/         # reusable widgets
├── test/               # Widget/tests (optional)
├── pubspec.yaml        # Dependencies
└── README.md           # Setup instructions
```

## Troubleshooting
- **White screen on launch**: Check Firebase config files
- **Authentication errors**: Verify Firebase Auth settings
- **Firestore errors**: Check Firestore rules and indexes
- **Notification issues**: Configure FCM in Firebase Console
- **Mock service not working**: Ensure `main.dart` uses `MockDeviceService()`

## File modifications for production
1. Update `lib/main.dart` with your package name
2. Configure Firebase options in each service file
3. Set up Firebase Cloud Messaging sender ID
4. Customize color schemes in `lib/core/theme/app_theme.dart`
5. Adjust tank capacity constants in `lib/features/tank_level/animated_water_tank.dart`

The app is designed to be modular - swap out MockDeviceService for MqttDeviceService when real hardware is available.