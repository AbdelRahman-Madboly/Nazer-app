# NAZER — Speed Monitoring Mobile App

NAZER is a Flutter mobile application for the NAZER IoT speed monitoring system. It connects to a NAZER ESP32 hardware device (`NAZER-EFD0`) over Bluetooth Low Energy (BLE) and provides real-time speed monitoring, violation tracking, driver scoring, and fine payment — all in a polished dark-first UI designed for in-vehicle use.

---

## Screenshots

> Screenshots coming soon.

---

## Features

- **Live Speed Gauge** — real-time speedometer with visual over-limit alert (pulsing red overlay)
- **BLE Connection** — auto-scan and connect to `NAZER-EFD0` device; reconnect banner on disconnect
- **Violation Detection** — violations pushed from device firmware; stored locally with Hive; push notifications via `flutter_local_notifications`
- **Violation History** — list + detail screens with map pin, speed badge, fine amount
- **Driver Score** — computed score based on violation history with trend chart
- **Fine Payment Flow** — card and digital wallet mock payment screens (PaymentMethod → PaymentForm → PaymentSuccess)
- **Settings** — BLE device info, theme toggle (dark/light), app info
- **Trip Info** — live distance (Haversine), max speed, and duration on the Monitor screen

---

## Tech Stack

| Layer | Package / Tool | Version |
|---|---|---|
| Framework | Flutter | ≥ 3.0.0 |
| BLE | flutter_blue_plus | ^1.32.3 |
| Permissions | permission_handler | ^11.3.1 |
| State | provider | ^6.1.2 |
| Navigation | go_router | ^14.2.0 |
| Local DB | hive + hive_flutter | ^2.2.3 |
| Preferences | shared_preferences | ^2.2.3 |
| Maps | flutter_map + latlong2 | ^7.0.2 |
| Charts | fl_chart | ^0.68.0 |
| Notifications | flutter_local_notifications | ^17.2.2 |
| Date formatting | intl | ^0.19.0 |
| App Icon | flutter_launcher_icons | ^0.14.1 |

---

## Setup

### Prerequisites

- Flutter SDK ≥ 3.0.0
- Android SDK ≥ 29
- A physical Android device (BLE does not work on emulator)

### Install

```bash
cd C:\Dan_WS\Nazer-app
flutter pub get
```

### Generate app icon (one-time after changing assets/icon/icon.png)

```bash
dart run flutter_launcher_icons
```

### Run (development)

```bash
flutter run -d R5CWC0M27EJ
```

Replace `R5CWC0M27EJ` with your device ID (`flutter devices` to list).

### Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

> **Signing:** The release build currently uses the debug signing config. Before publishing, generate a real keystore and update `android/app/build.gradle.kts`.

---

## BLE Device Reference

| Property | Value |
|---|---|
| Advertised name | `NAZER-EFD0` |
| MAC address | `F4:65:0B:49:EF:D2` |
| Device ID (JSON) | `NAZER_0B49EFD0` |
| Service UUID | `4fafc201-1fb5-459e-8fcc-c5c9c331914b` |
| Telemetry characteristic | `beb5483e-36e1-4688-b7f5-ea07361b26a8` (NOTIFY) |
| Violation characteristic | same as telemetry — distinguished by `violation_id` field |
| Command characteristic | `1c95d5e3-d8f7-413a-bf3d-7a2e5d7be87e` (WRITE) |
| Negotiated MTU | 247 bytes |
| Telemetry interval | every 10 seconds |

Chunked BLE frames use the format `"N/M|{json…}"` — `BleService` reassembles before parsing.

---

## Phase Status

| Phase | Description | Status |
|---|---|---|
| 6A | Project setup, design system, navigation skeleton | ✅ Done |
| 6B | BLE connection layer | ✅ Done |
| 6C | Home + Live Monitor screens | ✅ Done |
| 6D | Violations screens, local storage, notifications | ✅ Done |
| 6E | Driver Score + Settings screens | ✅ Done |
| 6F | Payment flow screens | ✅ Done |
| 6G | Integration with real ESP32 device | ✅ Done |
| 6H | Polish + production build | ✅ Done |
| 7 | Real payment gateway integration | 🗓 Roadmap |
| 8 | Cloud sync + fleet dashboard | 🗓 Roadmap |
| 9 | iOS port + App Store release | 🗓 Roadmap |

---

## Known Limitations

| Limitation | Detail |
|---|---|
| Mock payment | Payment flow is UI-only — no real transaction is processed |
| GPS timestamp | Firmware timestamp is from device epoch (1970-based); display shows device-local time |
| Trip data not persisted | Distance/duration/max speed reset when app is restarted |
| iOS not supported | BLE permission model and app icon config are Android-only for now |
| Debug signing | Release APK uses debug keystore — not suitable for Play Store |

---

## License

MIT License © 2026 NAZER Project