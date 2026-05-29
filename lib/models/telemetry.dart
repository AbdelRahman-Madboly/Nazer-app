/// Parsed telemetry JSON received from NAZER ESP32 via BLE NOTIFY
class TelemetryData {
  final String deviceId;
  final DateTime timestamp;
  final double lat;
  final double lon;
  final double speedKmh;
  final double speedGpsKmh;
  final double speedImuKmh;
  final double speedLimitKmh;
  final int satellites;
  final double hdop;
  final int batteryPct;
  final int gsmSignal;
  final bool isStationary;
  final double accelX;
  final double accelY;
  final double accelZ;

  const TelemetryData({
    required this.deviceId,
    required this.timestamp,
    required this.lat,
    required this.lon,
    required this.speedKmh,
    required this.speedGpsKmh,
    required this.speedImuKmh,
    required this.speedLimitKmh,
    required this.satellites,
    required this.hdop,
    required this.batteryPct,
    required this.gsmSignal,
    required this.isStationary,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
  });

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    return TelemetryData(
      deviceId:       json['device_id'] as String,
      timestamp:      DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now(),
      lat:            (json['lat'] as num).toDouble(),
      lon:            (json['lon'] as num).toDouble(),
      speedKmh:       (json['speed_kmh'] as num).toDouble(),
      speedGpsKmh:    (json['speed_gps_kmh'] as num).toDouble(),
      speedImuKmh:    (json['speed_imu_kmh'] as num).toDouble(),
      speedLimitKmh:  (json['speed_limit_kmh'] as num).toDouble(),
      satellites:     (json['satellites'] as num).toInt(),
      hdop:           (json['hdop'] as num).toDouble(),
      batteryPct:     (json['battery_pct'] as num).toInt(),
      gsmSignal:      (json['gsm_signal'] as num).toInt(),
      isStationary:   json['is_stationary'] as bool,
      accelX:         (json['accel_x'] as num).toDouble(),
      accelY:         (json['accel_y'] as num).toDouble(),
      accelZ:         (json['accel_z'] as num).toDouble(),
    );
  }

  bool get isOverLimit => speedKmh > speedLimitKmh;
}
