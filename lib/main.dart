// lib/main.dart  (Phase 6B delta — show the wiring change only)
//
// Add this after creating providers in MultiProvider, to connect
// DeviceProvider.onViolationReceived → ViolationsProvider.addViolation
//
// ─────────────────────────────────────────────────────────────────────
// In your existing runApp / main():
//
//   final deviceProvider    = DeviceProvider();
//   final violationsProvider = ViolationsProvider(StorageService());
//
//   // Wire violation events from BLE → storage/state
//   deviceProvider.onViolationReceived = violationsProvider.addViolation;
//
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider.value(value: deviceProvider),
//         ChangeNotifierProvider.value(value: violationsProvider),
//         // … other providers
//       ],
//       child: const NazerApp(),
//     ),
//   );
//
// ─────────────────────────────────────────────────────────────────────
// Then in your app's home screen (or wherever you want to auto-start
// scanning on launch), call:
//
//   context.read<DeviceProvider>().startScan();
//
// This requests permissions then starts BLE scan automatically.
// ─────────────────────────────────────────────────────────────────────

// Full main.dart for reference:

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'models/violation.dart';
import 'providers/device_provider.dart';
import 'providers/violations_provider.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive init
  await Hive.initFlutter();
  Hive.registerAdapter(ViolationDataAdapter());
  await Hive.openBox<ViolationData>('violations');

  // Build providers
  final storageService     = StorageService();
  final deviceProvider     = DeviceProvider();
  final violationsProvider = ViolationsProvider(storageService);

  // Wire violation stream: BLE event → ViolationsProvider
  deviceProvider.onViolationReceived = violationsProvider.addViolation;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: deviceProvider),
        ChangeNotifierProvider.value(value: violationsProvider),
      ],
      child: const NazerApp(),
    ),
  );
}