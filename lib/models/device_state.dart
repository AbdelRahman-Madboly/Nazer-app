enum BleConnectionState { disconnected, scanning, connecting, connected }

class DeviceState {
  final BleConnectionState connectionState;
  final String? deviceId;
  final String? deviceName;

  const DeviceState({
    this.connectionState = BleConnectionState.disconnected,
    this.deviceId,
    this.deviceName,
  });

  bool get isConnected => connectionState == BleConnectionState.connected;

  DeviceState copyWith({
    BleConnectionState? connectionState,
    String? deviceId,
    String? deviceName,
  }) {
    return DeviceState(
      connectionState: connectionState ?? this.connectionState,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
    );
  }
}
