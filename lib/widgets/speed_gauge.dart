// TODO Phase 6C: Animated circular gauge
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SpeedGauge extends StatelessWidget {
  final double speed;
  final double speedLimit;
  final double maxSpeed;

  const SpeedGauge({
    super.key,
    required this.speed,
    required this.speedLimit,
    this.maxSpeed = 200,
  });

  @override
  Widget build(BuildContext context) {
    final isOverLimit = speed > speedLimit;
    final color = isOverLimit ? AppColors.danger : AppColors.primary;

    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // TODO Phase 6C: CustomPainter arc gauge
          CircularProgressIndicator(
            value: (speed / maxSpeed).clamp(0.0, 1.0),
            strokeWidth: 12,
            backgroundColor: AppColors.bgSurface,
            color: color,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${speed.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: color)),
              Text('km/h', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text('Limit: ${speedLimit.toStringAsFixed(0)} km/h',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
