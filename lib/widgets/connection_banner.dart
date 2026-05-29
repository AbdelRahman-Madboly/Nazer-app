// TODO Phase 6B: Connect to DeviceProvider state
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/device_state.dart';

class ConnectionBanner extends StatelessWidget {
  final BleConnectionState state;
  const ConnectionBanner({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      BleConnectionState.connected    => ('Connected',  AppColors.success),
      BleConnectionState.scanning     => ('Scanning…',  AppColors.warning),
      BleConnectionState.connecting   => ('Connecting…',AppColors.info),
      BleConnectionState.disconnected => ('Disconnected',AppColors.danger),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: color.withOpacity(0.15),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
