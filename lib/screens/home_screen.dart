// lib/screens/home_screen.dart
// Phase 6C: Design-faithful HomeScreen matching HomeScreen.tsx.
//
// Layout:
//  - ConnectionBanner (top)
//  - Header: device ID
//  - SpeedGauge (hero)
//  - 2×2 StatCard grid: Speed, Limit, Battery, GSM Signal
//  - GPS row: satellite count + HDOP quality label
//  - Stationary badge (shown when is_stationary == true)
//  - Recent Activity section (static placeholder items, styled per TSX)
//  - All data from DeviceProvider.lastTelemetry — shows "--" when null

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/device_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_banner.dart';
import '../widgets/speed_gauge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceProvider>().startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          // ── BLE status banner ──────────────────────────────────────────────
          const ConnectionBanner(),

          // ── Scrollable content ─────────────────────────────────────────────
          Expanded(
            child: SafeArea(
              top: false,
              child: Consumer<DeviceProvider>(
                builder: (context, device, _) {
                  final tel = device.lastTelemetry;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // ── Header ───────────────────────────────────────────
                        _Header(deviceId: device.state.deviceId),

                        const SizedBox(height: 20),

                        // ── Speed gauge (hero) ───────────────────────────────
                        Center(
                          child: SpeedGauge(
                            speed: tel?.speed ?? 0,
                            speedLimit: tel?.speedLimit.toDouble() ?? 60,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Stationary badge ─────────────────────────────────
                        if (tel != null && tel.isStationary)
                          _StationaryBadge(),

                        if (tel != null && tel.isStationary)
                          const SizedBox(height: 12),

                        // ── 2×2 stats grid ───────────────────────────────────
                        _StatsGrid(tel: tel),

                        const SizedBox(height: 16),

                        // ── GPS row ──────────────────────────────────────────
                        _GpsRow(tel: tel),

                        const SizedBox(height: 24),

                        // ── Recent Activity ──────────────────────────────────
                        _SectionLabel('Recent Activity'),
                        const SizedBox(height: 12),
                        _RecentActivityList(),

                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String? deviceId;
  const _Header({required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'NAZER',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
        ),
        const SizedBox(width: 10),
        Text(
          deviceId ?? 'Not connected',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ── Stationary badge ──────────────────────────────────────────────────────────

class _StationaryBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.directions_car, color: AppColors.warning, size: 16),
          SizedBox(width: 6),
          Text(
            'Vehicle Stationary',
            style: TextStyle(
              color: AppColors.warning,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2×2 Stats grid ────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final dynamic tel; // TelemetryData?
  const _StatsGrid({required this.tel});

  @override
  Widget build(BuildContext context) {
    final speedVal = tel != null ? '${tel.speed.toStringAsFixed(0)}' : '--';
    final speedColor =
        tel != null && tel.isOverLimit ? AppColors.danger : AppColors.primary;

    final limitVal = tel != null ? '${tel.speedLimit}' : '--';

    final battVal = tel != null ? '${tel.battery.toStringAsFixed(0)}%' : '--';
    final battColor = tel == null
        ? AppColors.textSecondary
        : tel.battery < 20
            ? AppColors.danger
            : tel.battery < 50
                ? AppColors.warning
                : AppColors.success;

    final gsmBars = tel != null ? _gsmToBars(tel.gsmSignal as int) : 0;
    final gsmLabel = tel != null ? '$gsmBars / 5 bars' : '--';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _StatCard(
          label: 'Current Speed',
          value: speedVal,
          unit: 'km/h',
          color: speedColor,
          icon: Icons.speed_rounded,
        ),
        _StatCard(
          label: 'Speed Limit',
          value: limitVal,
          unit: 'km/h',
          color: AppColors.textPrimary,
          icon: Icons.warning_amber_rounded,
        ),
        _StatCard(
          label: 'Battery',
          value: battVal,
          unit: '',
          color: battColor,
          icon: Icons.battery_full_rounded,
          trailing: tel != null
              ? _BatteryBar(pct: tel.battery.toDouble())
              : null,
        ),
        _StatCard(
          label: 'GSM Signal',
          value: gsmLabel,
          unit: '',
          color: AppColors.info,
          icon: Icons.signal_cellular_alt_rounded,
          trailing: tel != null
              ? _SignalBars(bars: gsmBars)
              : null,
        ),
      ],
    );
  }

  /// Map raw GSM RSSI (0–31 or -113..0 dBm) to 0–5 bars.
  /// firmware sends gsm_signal as raw RSSI 0–31.
  static int _gsmToBars(int rssi) {
    if (rssi <= 0) return 0;
    if (rssi <= 5) return 1;
    if (rssi <= 10) return 2;
    if (rssi <= 15) return 3;
    if (rssi <= 20) return 4;
    return 5;
  }
}

// ── GPS row ───────────────────────────────────────────────────────────────────

class _GpsRow extends StatelessWidget {
  final dynamic tel;
  const _GpsRow({required this.tel});

  @override
  Widget build(BuildContext context) {
    String satLabel = '--';
    String hdopLabel = '--';
    Color hdopColor = AppColors.textSecondary;

    if (tel != null) {
      satLabel = '${tel.satellites}';
      final hdop = tel.hdop as double;
      if (hdop <= 1.0) {
        hdopLabel = 'Excellent';
        hdopColor = AppColors.success;
      } else if (hdop <= 2.0) {
        hdopLabel = 'Good';
        hdopColor = AppColors.success;
      } else if (hdop <= 5.0) {
        hdopLabel = 'Moderate';
        hdopColor = AppColors.warning;
      } else {
        hdopLabel = 'Poor';
        hdopColor = AppColors.danger;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.satellite_alt_rounded,
              color: AppColors.info, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('GPS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  )),
              Text(
                '$satLabel satellites',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: hdopColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: hdopColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              hdopLabel,
              style: TextStyle(
                color: hdopColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent Activity (static placeholder matching TSX design) ──────────────────

class _RecentActivityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ActivityItem(
          iconBg: Color(0x33EF4444),
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.danger,
          title: 'Speed Violation',
          subtitle: '95 km/h in 60 km/h zone',
          time: '10:30 AM  •  \$10.00',
        ),
        SizedBox(height: 8),
        _ActivityItem(
          iconBg: Color(0x2222C55E),
          icon: Icons.star_rounded,
          iconColor: AppColors.success,
          title: 'Safe Driving Streak',
          subtitle: '7 days without violations',
          time: 'Keep it up!',
        ),
        SizedBox(height: 8),
        _ActivityItem(
          iconBg: Color(0x223B82F6),
          icon: Icons.bluetooth_rounded,
          iconColor: AppColors.info,
          title: 'Device Connected',
          subtitle: 'NAZER_0B49EFD0 paired successfully',
          time: 'Yesterday',
        ),
      ],
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final Widget? trailing;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    this.trailing,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (trailing != null) ...[
            trailing!,
          ] else ...[
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (unit.isNotEmpty)
                    TextSpan(
                      text: ' $unit',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BatteryBar extends StatelessWidget {
  final double pct;
  const _BatteryBar({required this.pct});

  @override
  Widget build(BuildContext context) {
    final color = pct < 20
        ? AppColors.danger
        : pct < 50
            ? AppColors.warning
            : AppColors.success;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${pct.toStringAsFixed(0)}%',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (pct / 100).clamp(0.0, 1.0),
            backgroundColor: AppColors.bgSurface,
            color: color,
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

class _SignalBars extends StatelessWidget {
  final int bars; // 0–5
  const _SignalBars({required this.bars});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$bars / 5',
          style: const TextStyle(
            color: AppColors.info,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (i) {
            final active = i < bars;
            return Container(
              width: 8,
              height: 8 + i * 3.0,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.info
                    : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}