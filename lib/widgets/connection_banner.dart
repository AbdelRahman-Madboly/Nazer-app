// lib/widgets/connection_banner.dart
// Phase 6B: Reads real BLE state from DeviceProvider.
// Design reference: ConnectionBanner.tsx
//   - disconnected → blue banner with "Connect" button (taps startScan)
//   - scanning     → amber banner + spinner
//   - connecting   → info-blue banner + spinner
//   - connected    → returns null (no banner shown)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/device_state.dart';
import '../providers/device_provider.dart';
import '../theme/app_theme.dart';

class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceProvider>();
    final connState = provider.state.connectionState;

    return switch (connState) {
      BleConnectionState.connected    => const SizedBox.shrink(),
      BleConnectionState.disconnected => _DisconnectedBanner(
          onConnect: () => provider.startScan(),
        ),
      BleConnectionState.scanning     => const _SpinnerBanner(
          label: 'Scanning…',
          subLabel: 'Looking for NAZER device…',
          color: AppColors.warning,
        ),
      BleConnectionState.connecting   => const _SpinnerBanner(
          label: 'Connecting…',
          subLabel: 'Establishing BLE connection…',
          color: AppColors.info,
        ),
    };
  }
}

// ── Disconnected banner ────────────────────────────────────────────────────

class _DisconnectedBanner extends StatelessWidget {
  final VoidCallback onConnect;
  const _DisconnectedBanner({required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      color: AppColors.info.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.bluetooth_disabled,
              color: AppColors.info, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device Not Connected',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Tap to connect your NAZER device',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onConnect,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Connect', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Scanning / Connecting spinner banner ───────────────────────────────────

class _SpinnerBanner extends StatelessWidget {
  final String label;
  final String subLabel;
  final Color color;

  const _SpinnerBanner({
    required this.label,
    required this.subLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      color: color.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                subLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}