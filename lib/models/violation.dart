import 'package:hive/hive.dart';

part 'violation.g.dart';

@HiveType(typeId: 0)
class ViolationData extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String deviceId;

  @HiveField(2)
  late DateTime timestamp;

  @HiveField(3)
  late double lat;

  @HiveField(4)
  late double lon;

  @HiveField(5)
  late double speedKmh;

  @HiveField(6)
  late double speedLimitKmh;

  @HiveField(7)
  late int durationSec;

  @HiveField(8)
  late bool isPaid;

  ViolationData();

  factory ViolationData.fromJson(Map<String, dynamic> json) {
    final v = ViolationData();
    v.id           = '${json['device_id']}_${json['timestamp']}';
    v.deviceId     = json['device_id'] as String;
    v.timestamp    = DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now();
    v.lat          = (json['lat'] as num).toDouble();
    v.lon          = (json['lon'] as num).toDouble();
    v.speedKmh     = (json['speed_kmh'] as num).toDouble();
    v.speedLimitKmh= (json['speed_limit_kmh'] as num).toDouble();
    v.durationSec  = (json['duration_sec'] as num).toInt();
    v.isPaid       = false;
    return v;
  }

  double get excessKmh => speedKmh - speedLimitKmh;

  /// Fine = 50 EGP base + 5 EGP per km/h over limit
  double get fineAmount => 50.0 + (excessKmh * 5.0);
}
