// TODO Phase 6D: Hook into StorageService and BLE violation stream
import 'package:flutter/foundation.dart';
import '../models/violation.dart';
import '../services/storage_service.dart';

class ViolationsProvider extends ChangeNotifier {
  List<ViolationData> _violations = [];

  List<ViolationData> get violations => _violations;
  int get unpaidCount => _violations.where((v) => !v.isPaid).length;

  void load() {
    _violations = StorageService.getAllViolations();
    notifyListeners();
  }

  Future<void> addViolation(ViolationData v) async {
    await StorageService.saveViolation(v);
    load();
  }

  Future<void> markPaid(String id) async {
    await StorageService.markPaid(id);
    load();
  }
}
