import 'package:flutter/material.dart';

class StaffProvider extends ChangeNotifier {
  List<dynamic> _staffList = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get staffList => _staffList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStaff(String adminId) async {
    _setLoading(true);
    try {
      // TODO: Implement load staff
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> inviteStaff(String email, String name, String phone, String role) async {
    _setLoading(true);
    try {
      // TODO: Implement invite logic
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleStaffActive(String staffId, bool isActive) async {
    try {
      // TODO: Implement toggle
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeStaff(String staffId) async {
    try {
      // TODO: Implement removal
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
