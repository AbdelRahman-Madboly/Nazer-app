// lib/widgets/speed_gauge.dart
// Phase 6C: Full CustomPainter arc gauge.
//
// Spec:
//  - 260 px diameter canvas
//  - Arc sweeps 220° starting at 160° (bottom-left) clockwise to 20° (bottom-right)
//  - Background arc: AppColors.bgSurface, strokeWidth 14
//  - Speed fill arc: AppColors.primary  (normal) / AppColors.danger (over limit)
//  - Speed limit tick: short white tick on arc at limit's angular position
//  - Smooth animation: AnimatedBuilder + Tween<double>, 300 ms
//  - Center: large speed number, "km/h" label, "Limit: XX" label
//  - Max speed on gauge: 160 km/h

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SpeedGauge extends StatefulWidget {
  final double speed;
  final double speedLimit;
  final double maxSpeed;

  const SpeedGauge({
    super.key,
    required this.speed,
    required this.speedLimit,
    this.maxSpeed = 160,
  });

  @override
  State<SpeedGauge> createState() => _SpeedGaugeState();
}

class _SpeedGaugeState extends State<SpeedGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Tween<double> _speedTween;
  late Animation<double> _speedAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _speedTween = Tween<double>(begin: 0, end: widget.speed);
    _speedAnim = _speedTween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(SpeedGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      _speedTween = Tween<double>(
        begin: _speedAnim.value, // animate from current position
        end: widget.speed,
      );
      _speedAnim = _speedTween.animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOverLimit = widget.speed > widget.speedLimit;

    return AnimatedBuilder(
      animation: _speedAnim,
      builder: (context, _) {
        final animatedSpeed = _speedAnim.value;
        final arcColor = isOverLimit ? AppColors.danger : AppColors.primary;
        final textColor = isOverLimit ? AppColors.danger : AppColors.primary;

        return SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Arc painter ────────────────────────────────────────────────
              CustomPaint(
                size: const Size(260, 260),
                painter: _ArcPainter(
                  speed: animatedSpeed,
                  speedLimit: widget.speedLimit,
                  maxSpeed: widget.maxSpeed,
                  arcColor: arcColor,
                ),
              ),

              // ── Center content ─────────────────────────────────────────────
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Speed number
                  Text(
                    animatedSpeed.toStringAsFixed(0),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                  // "km/h" label
                  const Text(
                    'km/h',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // "Limit: XX" label
                  Text(
                    'Limit: ${widget.speedLimit.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── CustomPainter ─────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double speed;
  final double speedLimit;
  final double maxSpeed;
  final Color arcColor;

  // Arc geometry constants
  // 220° sweep; start at 160° (measuring from positive x-axis = 0°, clockwise)
  static const double _startDeg = 160.0;
  static const double _sweepDeg = 220.0;
  static const double _strokeWidth = 14.0;

  _ArcPainter({
    required this.speed,
    required this.speedLimit,
    required this.maxSpeed,
    required this.arcColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - _strokeWidth) / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // ── Background arc ────────────────────────────────────────────────────────
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = AppColors.bgSurface;

    canvas.drawArc(
      rect,
      _toRadians(_startDeg),
      _toRadians(_sweepDeg),
      false,
      bgPaint,
    );

    // ── Speed fill arc ────────────────────────────────────────────────────────
    final speedFraction = (speed / maxSpeed).clamp(0.0, 1.0);
    final speedSweep = _sweepDeg * speedFraction;

    if (speedFraction > 0) {
      final fgPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = arcColor;

      canvas.drawArc(
        rect,
        _toRadians(_startDeg),
        _toRadians(speedSweep),
        false,
        fgPaint,
      );
    }

    // ── Speed-limit tick ──────────────────────────────────────────────────────
    final limitFraction = (speedLimit / maxSpeed).clamp(0.0, 1.0);
    final limitAngleDeg = _startDeg + _sweepDeg * limitFraction;
    final limitAngleRad = _toRadians(limitAngleDeg);

    final tickOuter = center +
        Offset(math.cos(limitAngleRad), math.sin(limitAngleRad)) *
            (radius + _strokeWidth / 2 + 2);
    final tickInner = center +
        Offset(math.cos(limitAngleRad), math.sin(limitAngleRad)) *
            (radius - _strokeWidth / 2 - 2);

    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.85);

    canvas.drawLine(tickInner, tickOuter, tickPaint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.speed != speed ||
      old.speedLimit != speedLimit ||
      old.arcColor != arcColor;

  static double _toRadians(double degrees) => degrees * math.pi / 180.0;
}