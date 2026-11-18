# HydroShield – Smart Water Management System (Flutter Prototype)

HydroShield is a Flutter-based smart water management prototype for residential/rental properties. It provides role-based **Property Owner** and **Tenant** interfaces with mock IoT data/services to demonstrate tank monitoring, usage/billing, cleaning/maintenance, leakage detection, and remote supply control flows.

[![OpenCode](https://img.shields.io/badge/OpenCode-Compatible-000000?style=flat&logo=terminal&logoColor=white)](https://opencode.ai)
[![Docs](https://img.shields.io/badge/docs-latest-blue.svg)](./docs)
[![GitHub last commit](https://img.shields.io/github/last-commit/OWNER/REPO)](https://github.com/OWNER/REPO/commits/main)
[![GitHub issues](https://img.shields.io/github/issues/OWNER/REPO)](https://github.com/OWNER/REPO/issues)

> **Status:** Prototype/demo build. Core UI flows and role-based access are implemented with **mock data/services**. Real Firebase auth/database/messaging, ESP32/MQTT hardware communication, backend sync, and payment gateway integrations are **not fully integrated** yet.

## What’s included in this build

### Authentication & roles (demo)
- Login/Register screens with role selection: **Owner** or **Tenant**
- Role-based navigation and dashboard access
- Demo login: select a role and tap **Login** (credentials are not validated against a backend in this build)
- Logout and switch roles from Settings/Profile

### Owner dashboard
- **Tank monitoring:** Animated water tank, current level (%), remaining litres, tank state (Full/Normal/Low/Critical), last updated time, online/offline indicator (simulated)
- **Usage overview:** Daily/weekly/monthly property consumption summaries
- **Quick status:** Leakage monitoring, cleaning/maintenance status, billing/payment highlights
- **Notifications/alerts panel:** Example alerts for leakage, low level, billing, cleaning, and supply events

### Usage & billing
- Daily/weekly/monthly consumption charts and summaries (`fl_chart`)
- **Owner:** Set water price per litre (rental), configure tenant count, view government tariff as reference (separate), calculated total charges, tenant consumption/payment records (mock)
- **Tenant:** View own consumption and charges, applicable unit price, amount payable, payment status, and historical records (mock/read-only for pricing/config)

### Tank cleaning & maintenance
- Estimated maintenance recommendation based on configured intervals/mock data (**not** presented as direct dirt measurement without sensors)
- Last cleaning date, days since cleaning, maintenance history
- Current cleaning system status (ON/OFF/Cleaning)
- **Owner-only manual activation** with confirmation and simulated command/status feedback

### Leakage detection & remote valve control (owner)
- Live flow-rate readings (mock), configurable threshold and detection criteria
- Leak status and alert history
- Remote **Turn OFF / Turn ON** main water supply (solenoid valve) with confirmation and simulated device-confirmation feedback

### Payments & settings
- **Owner:** Enter/update payment details shown to tenants, tenant management/config, notification preferences, system/integration info
- **Tenant:** View owner payment details, payment status/records, online payment action shown as demo (gateway not integrated)

### Tenant dashboard
- Property tank view and status
- Own consumption (today/week/month) and charge summary
- Access to Charges and Payments tabs; no access to modify pricing, thresholds, or hardware controls

## Important limitations (vs full production spec)
- **IoT/ESP32 integration:** Ultrasonic level, flow sensor, solenoid valve, and cleaning mechanism communication is **mocked** (service interfaces/placeholders included for future MQTT/REST integration).
- **Backend & data:** Firebase (Auth/Firestore/Messaging), persistent history, multi-property/tenant account linking, and sync are **not fully wired** in this build.
- **Payments:** No live payment gateway; payment UI is demonstrative.
- **Notifications:** In-app/demo alerts shown; push notification delivery not fully configured.
- **Security/hardware safety:** Role checks and confirmations are implemented in UI; production deployments must enforce authorization and device-confirmed control on backend/hardware.

## Project structure
```
lib/
  core/                 # constants, theme, routing, session, utilities
  data/services/        # DeviceService abstraction, mock + MQTT placeholder
  features/
    auth/               # login, register
    cleaning/           # cleaning & maintenance
    leak_detection/     # leak alerts & valve control
    settings/           # owner settings & management
    tank_level/         # animated tank widget, owner/renter dashboards
    usage_billing/      # usage charts, billing, records
android/                # Android project (Flutter)
windows/                # Windows desktop scaffold
```

## Getting started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable)
- Android SDK / platform-tools (for Android builds & USB install)
- A connected Android device with **USB debugging** enabled (for device install)

### Install dependencies
```bash
flutter pub get
```

### Run (development)
```bash
# list devices
flutter devices

# run on Android device/emulator
flutter run -d android

# run on web (if enabled)
flutter run -d chrome
```

### Build Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Install via USB debugging (ADB)
```bash
adb devices
adb install -r build/app/outputs/flutter-apk/app-release.apk
# or, with a specific device id:
adb -s <DEVICE_ID> install -r build/app/outputs/flutter-apk/app-release.apk
```

## How to log in (demo)
1. Open **HydroShield**.
2. Select role: **Owner** or **Tenant**.
3. Tap **Login** (email/password can be any value in this demo), or use **Create account** to register and enter.
4. To switch roles, use **Logout** from Settings/Profile and sign in with the other role.

## Branches (repository organization)
This repository is organized into multiple branches for important areas of work (e.g. application prototype, documentation, and platform/setup). See `git branch -a` for the full list.

## Notes
- Previous in-progress implementation snapshots may be preserved in dedicated branches/history.
- When integrating real services, add Firebase config files (`android/app/google-services.json`, etc.) and configure MQTT/backend endpoints securely (do not commit secrets).

## References
- [Flutter](https://docs.flutter.dev/)
- [go_router](https://pub.dev/packages/go_router)
- [fl_chart](https://pub.dev/packages/fl_chart)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
