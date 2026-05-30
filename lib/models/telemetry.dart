// lib/models/telemetry.dart
// Field names confirmed from test_ble_integration.cpp sendTelemetry():
//   device_id, timestamp, lat, lon,
//   speed_kmh, speed_gps_kmh, speed_imu_kmh,
//   heading_deg, speed_limit_kmh, altitude_m,
//   satellites, hdop, battery_pct, gsm_signal,
//   is_stationary, accel_x, accel_y, accel_z

class TelemetryData {
  final String deviceId;
  final double speed;        // km/h  ← firmware: speed_kmh
  final int speedLimit;      // km/h  ← firmware: speed_limit_kmh
  final double latitude;     //       ← firmware: lat
  final double longitude;    //       ← firmware: lon
  final int satellites;      //       ← firmware: satellites
  final int gsmSignal;       //       ← firmware: gsm_signal
  final double battery;      // %     ← firmware: battery_pct
  final bool isStationary;   //       ← firmware: is_stationary
  final double heading;      // deg   ← firmware: heading_deg
  final double altitude;     // m     ← firmware: altitude_m
  final double hdop;         //       ← firmware: hdop
  final DateTime timestamp;

  const TelemetryData({
    required this.deviceId,
    required this.speed,
    required this.speedLimit,
    required this.latitude,
    required this.longitude,
    required this.satellites,
    required this.gsmSignal,
    required this.battery,
    required this.isStationary,
    required this.heading,
    required this.altitude,
    required this.hdop,
    required this.timestamp,
  });

  bool get isOverLimit => speed > speedLimit;

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    return TelemetryData(
      deviceId:    (json['device_id'] ?? '') as String,
      // Firmware sends speed_kmh; fallback to 'speed' for future compat
      speed:       (json['speed_kmh'] ?? json['speed'] as num?)?.toDouble() ?? 0.0,
      speedLimit:  ((json['speed_limit_kmh'] ?? json['speed_limit'] ?? 80) as num).toInt(),
      latitude:    (json['lat'] as num?)?.toDouble() ?? 0.0,
      longitude:   (json['lon'] as num?)?.toDouble() ?? 0.0,
      satellites:  (json['satellites'] ?? 0) as int,
      gsmSignal:   (json['gsm_signal'] ?? 0) as int,
      battery:     (json['battery_pct'] ?? json['battery'] as num?)?.toDouble() ?? 0.0,
      isStationary:(json['is_stationary'] ?? false) as bool,
      heading:     (json['heading_deg'] as num?)?.toDouble() ?? 0.0,
      altitude:    (json['altitude_m'] as num?)?.toDouble() ?? 0.0,
      hdop:        (json['hdop'] as num?)?.toDouble() ?? 0.0,
      timestamp:   json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}