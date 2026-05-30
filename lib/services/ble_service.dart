// lib/services/ble_service.dart
// Phase 6C: Fixed double-connect race — scan timeout future is cancelled as
//           soon as a device is found so it cannot fire a second connect().
//
// Firmware notes (from BLETransport.h / BLETransport.cpp):
//  - Device advertises as "NAZER-XXXX" (last 4 hex of MAC)
//  - Service UUID:   4fafc201-1fb5-459e-8fcc-c5c9c331914b
//  - Telemetry char: beb5483e-36e1-4688-b7f5-ea07361b26a8  (NOTIFY)
//    ↑ Violations are also sent on this same characteristic
//  - Command char:   1c95d5e3-d8f7-413a-bf3d-7a2e5d7be87e  (WRITE)
//  - Chunked framing: "N/M|{json...}" — must reassemble before parsing
//  - Telemetry fires every 10 s; violations fire on event

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/telemetry.dart';
import '../models/violation.dart';

class BleService {
  // ── Constants ──────────────────────────────────────────────────────────────
  static const String targetDevicePrefix = 'NAZER-';

  static const String serviceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';

  /// Telemetry NOTIFY — also carries violation payloads (see firmware sendViolation)
  static const String telemetryCharUuid =
      'beb5483e-36e1-4688-b7f5-ea07361b26a8';

  /// Command WRITE — {"cmd":"set_limit","value":80}
  static const String commandCharUuid =
      '1c95d5e3-d8f7-413a-bf3d-7a2e5d7be87e';

  // Delay before retrying after a mid-session disconnect (device was connected, then dropped).
  // Scan timeouts do NOT auto-retry — the user taps "Scan" or the banner to retry.
  static const Duration _reconnectDelay = Duration(seconds: 8);

  // ── Stream controllers ─────────────────────────────────────────────────────
  final _telemetryController = StreamController<TelemetryData>.broadcast();
  final _violationController = StreamController<ViolationData>.broadcast();
  final _connectionStateController =
      StreamController<BleConnectionEvent>.broadcast();

  Stream<TelemetryData> get telemetryStream => _telemetryController.stream;
  Stream<ViolationData> get violationStream => _violationController.stream;
  Stream<BleConnectionEvent> get connectionEventStream =>
      _connectionStateController.stream;

  // ── Internal state ─────────────────────────────────────────────────────────
  BluetoothDevice? _device;
  BluetoothCharacteristic? _commandChar;
  StreamSubscription<List<int>>? _notifySubscription;
  StreamSubscription<BluetoothConnectionState>? _connStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  bool _disposed = false;
  bool _autoReconnect = false;

  /// Set to true once we have successfully connected and subscribed.
  /// Used to distinguish "device not found on scan" (no auto-retry) from
  /// "device dropped mid-session" (auto-retry after _reconnectDelay).
  bool _everConnected = false;

  /// FIX (Phase 6C): tracks whether we already initiated a connect() during
  /// the current scan so the scan-timeout branch is a no-op when a device
  /// was found before the timeout fired.
  bool _connectInitiated = false;

  /// Chunked-message reassembly buffer, keyed by totalChunks
  final Map<int, List<String?>> _chunkBuffer = {};

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Start scanning for any device whose name begins with "NAZER-".
  Future<void> startScan() async {
    if (_disposed) return;
    _autoReconnect = true;
    _connectInitiated = false; // reset for this scan attempt
    // A fresh manual scan should not be treated as a reconnect attempt —
    // clear the mid-session flag so a scan timeout doesn't auto-retry.
    _everConnected = false;

    _connectionStateController.add(BleConnectionEvent.scanning);

    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();

    _scanSubscription =
        FlutterBluePlus.scanResults.listen((results) async {
      // Guard: only connect once per scan attempt
      if (_connectInitiated) return;

      for (final r in results) {
        final name = r.device.platformName;
        if (name.startsWith(targetDevicePrefix)) {
          debugPrint('[BLE] Found device: $name (${r.device.remoteId})');
          _connectInitiated = true; // prevent timeout branch from firing
          await FlutterBluePlus.stopScan();
          await _scanSubscription?.cancel();
          _scanSubscription = null;
          await connect(r.device);
          break;
        }
      }
    });

    // Scan with a timeout; but only act on it when no connect was initiated.
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));

    // startScan() returns after the timeout duration.
    // If _connectInitiated is true a device was found — do nothing.
    if (!_connectInitiated && !_disposed) {
      debugPrint('[BLE] Scan timeout — device not found');
      _connectionStateController.add(BleConnectionEvent.notFound);
      // Only auto-retry if this scan was triggered by a mid-session reconnect
      // (_everConnected). If the user just opened the app and the device isn't
      // around yet, stay idle — no runaway scan loop.
      if (_everConnected) {
        _scheduleReconnect();
      }
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    if (_disposed) return;

    _device = device;
    _connectionStateController.add(BleConnectionEvent.connecting);
    debugPrint('[BLE] Connecting to ${device.platformName}…');

    try {
      await device.connect(
          autoConnect: false, timeout: const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[BLE] connect() error: $e');
      _connectionStateController.add(BleConnectionEvent.disconnected);
      _scheduleReconnect();
      return;
    }

    await _connStateSubscription?.cancel();
    _connStateSubscription = device.connectionState.listen((state) {
      debugPrint('[BLE] Connection state → $state');
      if (state == BluetoothConnectionState.disconnected) {
        _onDisconnected();
      }
    });

    await _discoverAndSubscribe(device);
  }

  Future<void> disconnect() async {
    _autoReconnect = false;
    await _cleanup();
    _connectionStateController.add(BleConnectionEvent.disconnected);
  }

  Future<void> sendCommand(Map<String, dynamic> cmd) async {
    if (_commandChar == null) {
      debugPrint('[BLE] sendCommand: not connected / char not found');
      return;
    }
    final bytes = utf8.encode(jsonEncode(cmd));
    try {
      await _commandChar!.write(bytes, withoutResponse: false);
      debugPrint('[BLE] Command sent: ${jsonEncode(cmd)}');
    } catch (e) {
      debugPrint('[BLE] sendCommand error: $e');
    }
  }

  void dispose() {
    _disposed = true;
    _autoReconnect = false;
    _cleanup();
    _telemetryController.close();
    _violationController.close();
    _connectionStateController.close();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _discoverAndSubscribe(BluetoothDevice device) async {
    debugPrint('[BLE] Discovering services…');
    List<BluetoothService> services;

    try {
      services = await device.discoverServices();
    } catch (e) {
      debugPrint('[BLE] discoverServices error: $e');
      _onDisconnected();
      return;
    }

    BluetoothCharacteristic? telemetryChar;
    _commandChar = null;

    for (final svc in services) {
      if (svc.uuid.toString().toLowerCase() != serviceUuid) continue;
      for (final c in svc.characteristics) {
        final uuid = c.uuid.toString().toLowerCase();
        if (uuid == telemetryCharUuid) telemetryChar = c;
        if (uuid == commandCharUuid) _commandChar = c;
      }
    }

    if (telemetryChar == null) {
      debugPrint('[BLE] Telemetry characteristic not found — check UUIDs');
      _onDisconnected();
      return;
    }

    await _notifySubscription?.cancel();
    try {
      await telemetryChar.setNotifyValue(true);
    } catch (e) {
      debugPrint('[BLE] setNotifyValue error: $e');
      _onDisconnected();
      return;
    }

    _notifySubscription = telemetryChar.onValueReceived.listen(
      _onNotifyReceived,
      onError: (e) => debugPrint('[BLE] notify stream error: $e'),
    );

    debugPrint('[BLE] Subscribed to telemetry NOTIFY — connected!');
    _chunkBuffer.clear();
    _everConnected = true; // mark: we have had a real connection this session
    _connectionStateController.add(BleConnectionEvent.connected);
  }

  void _onNotifyReceived(List<int> rawBytes) {
    final raw = utf8.decode(rawBytes, allowMalformed: true);
    debugPrint('[BLE] Raw notify: $raw');

    final pipeIdx = raw.indexOf('|');
    if (pipeIdx < 0) {
      _dispatchJson(raw);
      return;
    }

    final header = raw.substring(0, pipeIdx);
    final parts = header.split('/');
    if (parts.length != 2) {
      _dispatchJson(raw);
      return;
    }

    final chunkIdx = int.tryParse(parts[0]);
    final totalChunks = int.tryParse(parts[1]);
    if (chunkIdx == null || totalChunks == null) {
      _dispatchJson(raw);
      return;
    }

    final data = raw.substring(pipeIdx + 1);

    if (totalChunks == 1) {
      _dispatchJson(data);
      return;
    }

    _chunkBuffer.putIfAbsent(
        totalChunks, () => List.filled(totalChunks, null));
    final buf = _chunkBuffer[totalChunks]!;
    buf[chunkIdx - 1] = data;

    if (buf.every((c) => c != null)) {
      final full = buf.join();
      _chunkBuffer.remove(totalChunks);
      debugPrint(
          '[BLE] Reassembled $totalChunks-chunk message (${full.length} bytes)');
      _dispatchJson(full);
    }
  }

  void _dispatchJson(String json) {
    debugPrint('[BLE] JSON received: $json');
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final isViolation =
          map.containsKey('violation_id') || map['type'] == 'violation';

      if (isViolation) {
        final v = ViolationData.fromJson(map);
        debugPrint('[BLE] Violation: ${v.violationId} ${v.speed} km/h');
        _violationController.add(v);
      } else {
        final t = TelemetryData.fromJson(map);
        debugPrint('[BLE] Telemetry: speed=${t.speed} limit=${t.speedLimit}');
        _telemetryController.add(t);
      }
    } catch (e) {
      debugPrint('[BLE] JSON parse error: $e\nRaw: $json');
    }
  }

  void _onDisconnected() {
    if (_disposed) return;
    debugPrint('[BLE] Disconnected');
    _cleanup(clearDevice: false);
    _connectionStateController.add(BleConnectionEvent.disconnected);
    if (_autoReconnect) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || !_autoReconnect) return;
    debugPrint('[BLE] Auto-reconnect in ${_reconnectDelay.inSeconds}s…');
    Future.delayed(_reconnectDelay, () {
      if (_disposed || !_autoReconnect) return;
      startScan();
    });
  }

  Future<void> _cleanup({bool clearDevice = true}) async {
    await _notifySubscription?.cancel();
    await _connStateSubscription?.cancel();
    await _scanSubscription?.cancel();
    _notifySubscription = null;
    _connStateSubscription = null;
    _scanSubscription = null;
    _commandChar = null;
    _chunkBuffer.clear();

    if (clearDevice) {
      try {
        await _device?.disconnect();
      } catch (_) {}
      _device = null;
    }
  }
}

enum BleConnectionEvent {
  scanning,
  connecting,
  connected,
  disconnected,
  notFound, // scan completed but device was not in range
}