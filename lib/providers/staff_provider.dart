import 'package:flutter/material.dart';
import 'package:service_pro/config/constants.dart';
import 'package:service_pro/models/staff_model.dart';
import 'package:service_pro/services/firestore_service.dart';
import 'dart:async';

class StaffProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<StaffModel> _staffList = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription? _staffSubscription;

  List<StaffModel> get staffList => _staffList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStaff(String adminId) async {
    _setLoading(true);
    try {
      _staffSubscription?.cancel();
      _staffSubscription =
          _firestoreService.getStaffByAdmin(adminId).listen((data) {
        _staffList = data;
        _setLoading(false);
      });
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> inviteStaff({
    required String adminId,
    required String email,
    required String name,
    required String phone,
    required StaffRole role,
  }) async {
    _setLoading(true);
    try {
      await _firestoreService.inviteStaff(email, adminId, role);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleStaffActive(String staffId, bool isActive) async {
    try {
      // TODO: implement toggle in firestore
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeStaff(String staffId) async {
    try {
      // TODO: implement remove in firestore
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _staffSubscription?.cancel();
    super.dispose();
  }
}
