// lib/providers/device_provider.dart
// Phase 6B: Wires BleService streams into provider state.
// Handles: permissions, scan, connect, disconnect, auto-reconnect,
//          telemetry stream, violation stream → ViolationsProvider.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/device_state.dart';
import '../models/telemetry.dart';
import '../models/violation.dart';
import '../services/ble_service.dart';

class DeviceProvider extends ChangeNotifier {
  final BleService _ble = BleService();

  DeviceState _state = const DeviceState();
  TelemetryData? _lastTelemetry;

  // Optional callback so DeviceProvider can forward violations to
  // ViolationsProvider without a hard dependency cycle.
  // Set by main.dart after both providers are created.
  void Function(ViolationData)? onViolationReceived;

  DeviceProvider() {
    _listenToBleEvents();
    _listenToTelemetry();
    _listenToViolations();
  }

  // ── Getters ────────────────────────────────────────────────────────────────
  DeviceState get state => _state;
  TelemetryData? get lastTelemetry => _lastTelemetry;
  bool get isConnected =>
      _state.connectionState == BleConnectionState.connected;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Request Android BLE permissions then start scanning.
  /// Safe to call from any screen — handles permission denial gracefully.
  Future<void> startScan() async {
    final granted = await _requestBlePermissions();
    if (!granted) {
      debugPrint('[DeviceProvider] BLE permissions denied — cannot scan');
      return;
    }
    await _ble.startScan();
  }

  Future<void> disconnect() async {
    await _ble.disconnect();
    _state = const DeviceState();
    notifyListeners();
  }

  /// Send a set_limit command to the connected device.
  Future<void> setSpeedLimit(int limit) async {
    await _ble.sendCommand({'cmd': 'set_limit', 'value': limit});
  }

  // ── Stream subscriptions ──────────────────────────────────────────────────

  void _listenToBleEvents() {
    _ble.connectionEventStream.listen((event) {
      final newConnState = switch (event) {
        BleConnectionEvent.scanning     => BleConnectionState.scanning,
        BleConnectionEvent.connecting   => BleConnectionState.connecting,
        BleConnectionEvent.connected    => BleConnectionState.connected,
        BleConnectionEvent.disconnected => BleConnectionState.disconnected,
        // notFound: scan completed without finding the device —
        // show as disconnected so the banner offers a "Scan" button.
        BleConnectionEvent.notFound     => BleConnectionState.disconnected,
      };
      _state = _state.copyWith(connectionState: newConnState);
      notifyListeners();
      debugPrint('[DeviceProvider] State → $newConnState');
    });
  }

  void _listenToTelemetry() {
    _ble.telemetryStream.listen((data) {
      _lastTelemetry = data;
      // Reflect the device ID and speed limit from telemetry into state
      _state = _state.copyWith(
        deviceId: data.deviceId,
        speedLimit: data.speedLimit,
      );
      notifyListeners();
    });
  }

  void _listenToViolations() {
    _ble.violationStream.listen((violation) {
      debugPrint('[DeviceProvider] Violation received: ${violation.violationId}');
      onViolationReceived?.call(violation);
    });
  }

  // ── Permissions ───────────────────────────────────────────────────────────

  /// Returns true when all required permissions are granted.
  Future<bool> _requestBlePermissions() async {
    if (!Platform.isAndroid) return true;

    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final allGranted = statuses.values.every(
      (s) => s == PermissionStatus.granted,
    );

    if (!allGranted) {
      for (final entry in statuses.entries) {
        debugPrint('[Perms] ${entry.key} → ${entry.value}');
      }
    }

    return allGranted;
  }

  @override
  void dispose() {
    _ble.dispose();
    super.dispose();
  }
}