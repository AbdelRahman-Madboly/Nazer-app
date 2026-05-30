// lib/services/notification_service.dart
// Phase 6D: flutter_local_notifications wrapper.
//
// Fix: moved 'dart:ui' import to top (was erroneously placed after class body).

import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/violation.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'nazer_violations';
  static const String _channelName = 'Speed Violations';
  static const String _channelDesc =
      'Alerts when a new speed violation is detected';

  // ── Init ───────────────────────────────────────────────────────────────────

  /// Call once from main() after WidgetsFlutterBinding.ensureInitialized().
  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(initSettings);

    // Create Android notification channel (required for API 26+)
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    debugPrint('[NotificationService] Initialised');
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Show a high-importance notification for a received violation.
  Future<void> showViolationNotification(ViolationData v) async {
    final excess = v.excessSpeed.toStringAsFixed(0);
    final fine = v.fineAmount.toStringAsFixed(0);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFEF4444), // danger red
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      v.violationId.hashCode & 0x7FFFFFFF,
      'Speed Violation Detected',
      '${v.speed.toStringAsFixed(0)} km/h in a ${v.speedLimit} km/h zone'
          ' — Fine: $fine EGP (+$excess km/h over)',
      details,
    );

    debugPrint('[NotificationService] Notification shown for ${v.violationId}');
  }
}