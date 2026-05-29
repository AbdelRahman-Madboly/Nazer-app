# NAZER Mobile App

Flutter mobile application for the NAZER speed monitoring system.

## Overview

Connects to the NAZER ESP32 device via Bluetooth Low Energy (BLE) and provides:
- Live speed monitoring with animated gauge
- Speed violation alerts and history
- Driver score tracking
- Fine payment flow
- Device configuration

## Tech Stack

| Concern | Package |
|---------|---------|
| BLE | `flutter_blue_plus` |
| State | `provider` |
| Navigation | `go_router` |
| Local DB | `hive` |
| Notifications | `flutter_local_notifications` |
| Maps | `flutter_map` + OpenStreetMap |
| HTTP | `dio` |
| Charts | `fl_chart` |

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on connected Android device
flutter run

# Build release APK
flutter build apk --release
```

## Project Structure

```
lib/
├── main.dart             # Entry point
├── app.dart              # MaterialApp + GoRouter
├── theme/                # Colors, text styles
├── models/               # Data models (Telemetry, Violation, DeviceState)
├── services/             # BLE + Hive storage
├── providers/            # State management
├── screens/              # All app screens
└── widgets/              # Reusable components
```

## BLE Device

- **Device Name:** `NAZER-EFD0`
- **Service UUID:** `4fafc201-1fb5-459e-8fcc-c5c9c331914b`
- **Platform:** Android (iOS support planned)

## Development Phases

| Phase | Description | Status |
|-------|-------------|--------|
| 6A | Project setup + design system + navigation skeleton | ✅ In Progress |
| 6B | BLE connection layer | ⬜ |
| 6C | Home + Live Monitor screens | ⬜ |
| 6D | Violations + storage + notifications | ⬜ |
| 6E | Driver Score + Settings | ⬜ |
| 6F | Payment flow | ⬜ |
| 6G | Real ESP32 integration | ⬜ |
| 6H | Polish + production build | ⬜ |

## Requirements

- Flutter SDK ≥ 3.0.0
- Android API 29+ (Android 10+)
- BLE-capable Android device (no emulator for BLE)
