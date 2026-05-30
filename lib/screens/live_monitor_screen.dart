// lib/screens/live_monitor_screen.dart
// Phase 6C: Full LiveMonitorScreen matching LiveMonitorScreen.tsx.
//
// Layout:
//  - ConnectionBanner
//  - SpeedGauge (centred, hero)
//  - Pulsing red overlay (AnimatedOpacity 500ms) when speed > limit
//  - Bottom info strip: speed limit label, stationary badge, last-update time
//  - GPS info row: satellites + accuracy (from hdop)
//  - Trip info row: static placeholder (distance, duration, avg speed)
//  - Consumer<DeviceProvider> — rebuilds on every telemetry update

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/device_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_banner.dart';
import '../widgets/speed_gauge.dart';

class LiveMonitorScreen extends StatefulWidget {
  const LiveMonitorScreen({super.key});

  @override
  State<LiveMonitorScreen> createState() => _LiveMonitorScreenState();
}

class _LiveMonitorScreenState extends State<LiveMonitorScreen>
    with SingleTickerProviderStateMixin {
  // Pulsing overlay controller for over-limit state
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.0, end: 0.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          // ── BLE status banner ──────────────────────────────────────────────
          const ConnectionBanner(),

          // ── Main content ───────────────────────────────────────────────────
          Expanded(
            child: Consumer<DeviceProvider>(
              builder: (context, device, _) {
                final tel = device.lastTelemetry;
                final speed = tel?.speed ?? 0.0;
                final speedLimit = tel?.speedLimit.toDouble() ?? 60.0;
                final isOverLimit = speed > speedLimit;
                final isStationary = tel?.isStationary ?? false;

                return Stack(
                  children: [
                    // ── Scrollable content ───────────────────────────────────
                    SafeArea(
                      top: false,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),

                            // ── Hero: speed gauge ───────────────────────────
                            Center(
                              child: SpeedGauge(
                                speed: speed,
                                speedLimit: speedLimit,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Status card ─────────────────────────────────
                            _StatusCard(
                              speed: speed,
                              speedLimit: speedLimit,
                              isOverLimit: isOverLimit,
                              isStationary: isStationary,
                            ),

                            const SizedBox(height: 16),

                            // ── GPS info row ─────────────────────────────────
                            _GpsInfoRow(
                              satellites: tel?.satellites ?? 0,
                              hdop: tel?.hdop ?? 0.0,
                              hasFix: tel != null,
                            ),

                            const SizedBox(height: 16),

                            // ── Trip info (static placeholder) ───────────────
                            _TripInfoCard(),

                            const SizedBox(height: 16),

                            // ── Last update timestamp ────────────────────────
                            _LastUpdateRow(timestamp: tel?.timestamp),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),

                    // ── Pulsing red overlay (over limit) ─────────────────────
                    if (isOverLimit)
                      IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (context, _) => Container(
                            color: AppColors.danger
                                .withValues(alpha: _pulseAnim.value),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status card ───────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final double speed;
  final double speedLimit;
  final bool isOverLimit;
  final bool isStationary;

  const _StatusCard({
    required this.speed,
    required this.speedLimit,
    required this.isOverLimit,
    required this.isStationary,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color statusColor;
    final String statusText;
    final IconData statusIcon;

    if (isStationary) {
      borderColor = AppColors.textSecondary;
      statusColor = AppColors.textSecondary;
      statusText = 'VEHICLE STOPPED';
      statusIcon = Icons.directions_car_rounded;
    } else if (isOverLimit) {
      borderColor = AppColors.danger;
      statusColor = AppColors.danger;
      statusText = '⚠  VIOLATION';
      statusIcon = Icons.warning_rounded;
    } else {
      borderColor = AppColors.success;
      statusColor = AppColors.success;
      statusText = '✓  SAFE DRIVING';
      statusIcon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Speed
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Speed',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    speed.toStringAsFixed(0),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                  const Text(
                    'km/h',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              // Speed limit
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Speed Limit',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    speedLimit.toStringAsFixed(0),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                  ),
                  const Text(
                    'km/h',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Status row
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 16),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),

              if (isOverLimit) ...[
                const Spacer(),
                Text(
                  '+${(speed - speedLimit).toStringAsFixed(0)} km/h over',
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),

          // Over-limit progress bar
          if (isOverLimit) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ((speed - speedLimit) / speedLimit).clamp(0.0, 1.0),
                backgroundColor: AppColors.bgSurface,
                color: AppColors.danger,
                minHeight: 5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── GPS info row ──────────────────────────────────────────────────────────────

class _GpsInfoRow extends StatelessWidget {
  final int satellites;
  final double hdop;
  final bool hasFix;

  const _GpsInfoRow({
    required this.satellites,
    required this.hdop,
    required this.hasFix,
  });

  @override
  Widget build(BuildContext context) {
    String accuracyLabel;
    Color accuracyColor;

    if (!hasFix) {
      accuracyLabel = 'No fix';
      accuracyColor = AppColors.textSecondary;
    } else if (hdop <= 1.0) {
      accuracyLabel = 'Excellent';
      accuracyColor = AppColors.success;
    } else if (hdop <= 2.0) {
      accuracyLabel = 'Good';
      accuracyColor = AppColors.success;
    } else if (hdop <= 5.0) {
      accuracyLabel = 'Moderate';
      accuracyColor = AppColors.warning;
    } else {
      accuracyLabel = 'Poor';
      accuracyColor = AppColors.danger;
    }

    final approxAccuracy = hasFix ? '±${(hdop * 2.5).toStringAsFixed(1)}m' : '--';

    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: Icons.satellite_alt_rounded,
            iconColor: AppColors.info,
            title: 'Satellites',
            value: hasFix ? '$satellites' : '--',
            sub: hasFix ? '● Connected' : '● No signal',
            subColor: hasFix ? AppColors.success : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            icon: Icons.my_location_rounded,
            iconColor: accuracyColor,
            title: 'Accuracy',
            value: approxAccuracy,
            sub: '● $accuracyLabel',
            subColor: accuracyColor,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String sub;
  final Color subColor;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.sub,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              color: subColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Trip info card (static placeholder matching TSX) ──────────────────────────

class _TripInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trip Information',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _TripStat(label: 'Distance', value: '—'),
              _TripDivider(),
              _TripStat(label: 'Duration', value: '—'),
              _TripDivider(),
              _TripStat(label: 'Avg Speed', value: '—'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripStat extends StatelessWidget {
  final String label;
  final String value;
  const _TripStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TripDivider extends StatelessWidget {
  const _TripDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 28,
        color: AppColors.border,
      );
}

// ── Last update row ───────────────────────────────────────────────────────────

class _LastUpdateRow extends StatelessWidget {
  final DateTime? timestamp;
  const _LastUpdateRow({this.timestamp});

  @override
  Widget build(BuildContext context) {
    String label;
    if (timestamp != null) {
      final t = timestamp!;
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      final ss = t.second.toString().padLeft(2, '0');
      label = 'Last update: $hh:$mm:$ss';
    } else {
      label = 'Waiting for telemetry…';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.access_time_rounded,
          color: AppColors.textSecondary,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}