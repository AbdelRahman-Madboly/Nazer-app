// lib/providers/device_provider.dart
// Phase 6H: Fixed imports (telemetry.dart / violation.dart, not *_data.dart).
//           Fixed stream names to match BleService API (connectionEventStream,
//           telemetryStream, violationStream — NOT stateStream).
//           Added isConnected getter, setSpeedLimit(), and trip tracking
//           (tripDistanceKm, maxSpeedKmh, tripDuration).

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/device_state.dart';
import '../models/telemetry.dart';
import '../models/violation.dart';
import '../services/ble_service.dart';

class DeviceProvider extends ChangeNotifier {
  // ── BLE state ───────────────────────────────────────────────────────────────
  DeviceState _state = const DeviceState();
  DeviceState get state => _state;

  TelemetryData? _lastTelemetry;
  TelemetryData? get lastTelemetry => _lastTelemetry;

  /// Convenience getter used by SettingsScreen
  bool get isConnected => _state.isConnected;

  /// Callback wired in main.dart: DeviceProvider → ViolationsProvider
  void Function(ViolationData)? onViolationReceived;

  final BleService _ble = BleService();
  StreamSubscription<BleConnectionEvent>? _connEventSub;
  StreamSubscription<TelemetryData>? _telemetrySub;
  StreamSubscription<ViolationData>? _violationSub;

  // ── Phase 6H: Trip tracking ─────────────────────────────────────────────────
  double _tripDistanceKm = 0.0;
  double _maxSpeedKmh    = 0.0;
  DateTime? _tripStartTime;
  double? _lastLat;
  double? _lastLon;

  double    get tripDistanceKm => _tripDistanceKm;
  double    get maxSpeedKmh    => _maxSpeedKmh;
  Duration? get tripDuration   =>
      _tripStartTime == null
          ? null
          : DateTime.now().difference(_tripStartTime!);

  // ── Init ────────────────────────────────────────────────────────────────────
  DeviceProvider() {
    _init();
  }

  void _init() {
    // BleService exposes connectionEventStream (BleConnectionEvent), not stateStream
    _connEventSub = _ble.connectionEventStream.listen((event) {
      _state = _state.copyWith(
        connectionState: _bleEventToState(event),
      );
      notifyListeners();
    });

    _telemetrySub = _ble.telemetryStream.listen((tel) {
      _lastTelemetry = tel;
      // Update DeviceState.speedLimit from telemetry
      _state = _state.copyWith(
        deviceId: tel.deviceId,
        speedLimit: tel.speedLimit,
      );
      _updateTrip(tel);
      notifyListeners();
    });

    _violationSub = _ble.violationStream.listen((v) {
      onViolationReceived?.call(v);
    });
  }

  BleConnectionState _bleEventToState(BleConnectionEvent event) {
    return switch (event) {
      BleConnectionEvent.scanning    => BleConnectionState.scanning,
      BleConnectionEvent.connecting  => BleConnectionState.connecting,
      BleConnectionEvent.connected   => BleConnectionState.connected,
      BleConnectionEvent.disconnected ||
      BleConnectionEvent.notFound    => BleConnectionState.disconnected,
    };
  }

  // ── BLE control ─────────────────────────────────────────────────────────────
  Future<void> startScan() => _ble.startScan();

  Future<void> disconnect() async {
    await _ble.disconnect();
    _state = const DeviceState();
    notifyListeners();
  }

  /// Send a set_limit command to the device. Used by SettingsScreen.
  Future<void> setSpeedLimit(int limit) async {
    await _ble.sendCommand({'cmd': 'set_limit', 'value': limit});
    _state = _state.copyWith(speedLimit: limit);
    notifyListeners();
  }

  // ── Trip tracking ───────────────────────────────────────────────────────────
  void _updateTrip(TelemetryData tel) {
    if (tel.speed > _maxSpeedKmh) _maxSpeedKmh = tel.speed;

    if (!tel.isStationary && _tripStartTime == null) {
      _tripStartTime = DateTime.now();
    }

    if (!tel.isStationary && _lastLat != null && _lastLon != null) {
      _tripDistanceKm +=
          _haversineKm(_lastLat!, _lastLon!, tel.latitude, tel.longitude);
    }

    _lastLat = tel.latitude;
    _lastLon = tel.longitude;
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180.0);

  // ── Dispose ─────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _connEventSub?.cancel();
    _telemetrySub?.cancel();
    _violationSub?.cancel();
    _ble.dispose();
    super.dispose();
  }
}