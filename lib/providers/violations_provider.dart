// lib/providers/violations_provider.dart
// TODO Phase 6D: Full UI + filtering + notification hooks
// Phase 6B: minimal stub — accepts StorageService, exposes addViolation()
//            so DeviceProvider can forward BLE violation events here.

import 'package:flutter/foundation.dart';
import '../models/violation.dart';
import '../services/storage_service.dart';

class ViolationsProvider extends ChangeNotifier {
  final StorageService _storage;

  ViolationsProvider(this._storage);

  List<ViolationData> _violations = [];
  List<ViolationData> get violations => List.unmodifiable(_violations);

  /// Called by DeviceProvider whenever a violation arrives over BLE.
  Future<void> addViolation(ViolationData v) async {
    await _storage.saveViolation(v);
    _violations = await _storage.getAllViolations();
    notifyListeners();
    debugPrint('[ViolationsProvider] Violation saved: ${v.violationId}');
  }

  Future<void> loadAll() async {
    _violations = await _storage.getAllViolations();
    notifyListeners();
  }

  Future<void> markPaid(String violationId) async {
    await _storage.markPaid(violationId);
    _violations = await _storage.getAllViolations();
    notifyListeners();
  }
}