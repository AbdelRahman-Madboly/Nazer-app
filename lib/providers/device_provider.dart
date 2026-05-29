// TODO Phase 6B: Wire up BleService streams
import 'package:flutter/foundation.dart';
import '../models/device_state.dart';
import '../models/telemetry.dart';
import '../services/ble_service.dart';

class DeviceProvider extends ChangeNotifier {
  final BleService _ble = BleService();

  DeviceState _state = const DeviceState();
  TelemetryData? _lastTelemetry;

  DeviceState get state => _state;
  TelemetryData? get lastTelemetry => _lastTelemetry;
  bool get isConnected => _state.isConnected;

  Future<void> startScan() async {
    _state = _state.copyWith(connectionState: BleConnectionState.scanning);
    notifyListeners();
    // TODO Phase 6B: await _ble.startScan();
  }

  Future<void> disconnect() async {
    await _ble.disconnect();
    _state = const DeviceState();
    notifyListeners();
  }

  void _onTelemetry(TelemetryData data) {
    _lastTelemetry = data;
    notifyListeners();
  }

  @override
  void dispose() {
    _ble.dispose();
    super.dispose();
  }
}
