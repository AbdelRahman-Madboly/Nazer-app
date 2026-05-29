// TODO Phase 6B: Implement BLE scan, connect, NOTIFY subscriptions
// Requires: flutter_blue_plus

import 'dart:async';
import 'dart:convert';
import '../models/telemetry.dart';
import '../models/violation.dart';

class BleService {
  static const String targetDeviceName = 'NAZER-EFD0';
  static const String serviceUuid      = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String telemetryCharUuid= '6fbe1ec0-3d8b-4c6a-a9c2-f6b4c3d1e2f0'; // fill from device
  static const String violationCharUuid= '14d1c9ef-a3b2-4c5d-8e9f-1a2b3c4d5e6f'; // fill from device
  static const String commandCharUuid  = '1c95d5e3-b4a3-4d5e-9f0a-2b3c4d5e6f7a'; // fill from device

  final _telemetryController = StreamController<TelemetryData>.broadcast();
  final _violationController = StreamController<ViolationData>.broadcast();

  Stream<TelemetryData> get telemetryStream => _telemetryController.stream;
  Stream<ViolationData> get violationStream  => _violationController.stream;

  // Placeholder — filled in Phase 6B
  Future<void> startScan() async {}
  Future<void> connect(String deviceId) async {}
  Future<void> disconnect() async {}
  Future<void> sendCommand(Map<String, dynamic> cmd) async {}

  void dispose() {
    _telemetryController.close();
    _violationController.close();
  }
}
