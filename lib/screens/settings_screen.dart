// lib/screens/settings_screen.dart
// Phase 6H: Added Appearance card (Dark Mode toggle via ThemeProvider).
//           Fixed: dp.isConnected now exists on DeviceProvider.
//                  dp.setSpeedLimit() now exists on DeviceProvider.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/device_state.dart';
import '../providers/device_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/violations_provider.dart';
import '../theme/app_theme.dart';

const _kSpeedLimitKey = 'speed_limit_override';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _sliderValue = 60;
  bool _prefLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_kSpeedLimitKey);
    if (mounted) {
      setState(() {
        if (saved != null) {
          _sliderValue = saved.toDouble();
          _prefLoaded = true;
        }
      });
    }
    if (!_prefLoaded && mounted) {
      final dp = context.read<DeviceProvider>();
      final fromDevice = dp.lastTelemetry?.speedLimit;
      if (fromDevice != null && mounted) {
        setState(() {
          _sliderValue = fromDevice.toDouble().clamp(30, 120);
          _prefLoaded = true;
        });
      } else {
        setState(() => _prefLoaded = true);
      }
    }
  }

  Future<void> _applyLimit(DeviceProvider dp) async {
    final limit = _sliderValue.round();
    await dp.setSpeedLimit(limit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSpeedLimitKey, limit);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Speed limit updated to $limit km/h'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmClearAll(ViolationsProvider vp) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear All Violations?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This will permanently delete all violation records from this device.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await vp.clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All violations cleared'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _disconnect(DeviceProvider dp) async {
    await dp.disconnect();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DeviceProvider, ViolationsProvider>(
      builder: (context, dp, vp, _) {
        final isConnected = dp.isConnected;
        final deviceId = dp.lastTelemetry?.deviceId ?? '—';
        final connState = dp.state.connectionState;

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            backgroundColor: AppColors.bgDark,
            elevation: 0,
            title: const Text(
              'Settings',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Appearance ──────────────────────────────────────────────
                const _SectionLabel('APPEARANCE'),
                const _AppearanceCard(),
                const SizedBox(height: 24),

                // ── Device ──────────────────────────────────────────────────
                const _SectionLabel('DEVICE CONNECTION'),
                _DeviceCard(
                  deviceId: deviceId,
                  connState: connState,
                  isConnected: isConnected,
                  onDisconnect: () => _disconnect(dp),
                ),
                const SizedBox(height: 24),

                // ── Speed limit ─────────────────────────────────────────────
                const _SectionLabel('SPEED LIMIT OVERRIDE'),
                _SpeedLimitCard(
                  sliderValue: _sliderValue,
                  isConnected: isConnected,
                  onChanged: (v) => setState(() => _sliderValue = v),
                  onApply: () => _applyLimit(dp),
                ),
                const SizedBox(height: 24),

                // ── App ─────────────────────────────────────────────────────
                const _SectionLabel('APP'),
                _AppCard(onClearAll: () => _confirmClearAll(vp)),
                const SizedBox(height: 32),

                const Center(
                  child: Column(
                    children: [
                      Text(
                        'Made with ❤️ for safer driving',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '© 2026 NAZER. All rights reserved.',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Appearance card (Dark Mode toggle)
// ─────────────────────────────────────────────────────────────────────────────

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.dark_mode_rounded,
                color: AppColors.textMuted, size: 22),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Dark Mode',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
            ),
            Switch(
              value: themeProvider.isDark,
              onChanged: (_) => themeProvider.toggleTheme(),
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Device card
// ─────────────────────────────────────────────────────────────────────────────

class _DeviceCard extends StatelessWidget {
  final String deviceId;
  final BleConnectionState connState;
  final bool isConnected;
  final VoidCallback onDisconnect;

  const _DeviceCard({
    required this.deviceId,
    required this.connState,
    required this.isConnected,
    required this.onDisconnect,
  });

  Color get _pillColor => switch (connState) {
        BleConnectionState.connected => AppColors.success,
        BleConnectionState.scanning ||
        BleConnectionState.connecting =>
          AppColors.warning,
        BleConnectionState.disconnected => AppColors.danger,
      };

  String get _pillText => switch (connState) {
        BleConnectionState.connected    => 'Connected',
        BleConnectionState.scanning     => 'Scanning…',
        BleConnectionState.connecting   => 'Connecting…',
        BleConnectionState.disconnected => 'Disconnected',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bluetooth_rounded,
                    color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NAZER-EFD0',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deviceId,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _pillColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _pillText,
                          style: TextStyle(
                            color: _pillColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isConnected) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onDisconnect,
                icon: const Icon(Icons.bluetooth_disabled,
                    size: 16, color: AppColors.danger),
                label: const Text(
                  'Disconnect',
                  style: TextStyle(color: AppColors.danger),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Speed limit card
// ─────────────────────────────────────────────────────────────────────────────

class _SpeedLimitCard extends StatelessWidget {
  final double sliderValue;
  final bool isConnected;
  final ValueChanged<double> onChanged;
  final VoidCallback onApply;

  const _SpeedLimitCard({
    required this.sliderValue,
    required this.isConnected,
    required this.onChanged,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Speed Limit',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${sliderValue.round()} km/h',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.bgSurface,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.15),
              valueIndicatorColor: AppColors.primary,
              disabledActiveTrackColor: AppColors.textMuted,
              disabledInactiveTrackColor: AppColors.bgSurface,
              disabledThumbColor: AppColors.textMuted,
            ),
            child: Slider(
              value: sliderValue,
              min: 30,
              max: 120,
              divisions: 9,
              label: '${sliderValue.round()} km/h',
              onChanged: isConnected ? onChanged : null,
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('30',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text('120',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isConnected ? onApply : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.bgSurface,
                foregroundColor: Colors.black,
                disabledForegroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                isConnected ? 'Apply' : 'Connect device to apply',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App section card
// ─────────────────────────────────────────────────────────────────────────────

class _AppCard extends StatelessWidget {
  final VoidCallback onClearAll;
  const _AppCard({required this.onClearAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: AppColors.textMuted, size: 22),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Version',
                    style:
                        TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  ),
                ),
                Text(
                  '1.0.0 (Build 1)',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          InkWell(
            onTap: onClearAll,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.delete_outline,
                      color: AppColors.danger, size: 22),
                  SizedBox(width: 14),
                  Text(
                    'Clear All Violations',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}