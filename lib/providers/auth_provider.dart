import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:service_pro/services/auth_service.dart';
import 'package:service_pro/models/admin_model.dart';
import 'package:service_pro/models/staff_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isAdmin = false;
  bool _isStaff = false;
  bool _isSignedIn = false;
  AdminModel? _adminModel;
  StaffModel? _staffModel;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAdmin => _isAdmin;
  bool get isStaff => _isStaff;
  bool get isSignedIn => _isSignedIn;
  AdminModel? get adminModel => _adminModel;
  StaffModel? get staffModel => _staffModel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _currentUser = _authService.currentUser;
    _isSignedIn = _currentUser != null;
    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      _isSignedIn = user != null;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _error = null;
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null) {
        _currentUser = result.user;
        _isSignedIn = true;
        await checkUserRole();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerAdmin({
    required String name,
    required String phone,
    String? businessName,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.registerAdmin(
        name: name,
        phone: phone,
        businessName: businessName,
      );
      await checkUserRole();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      _isSignedIn = false;
      _isAdmin = false;
      _isStaff = false;
      _adminModel = null;
      _staffModel = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkUserRole() async {
    if (_currentUser == null) return;

    final role = await _authService.getUserRole();
    _isAdmin = role == 'admin';
    _isStaff = role == 'staff';

    if (_isAdmin) {
      _adminModel = await _authService.getAdminModel();
    } else if (_isStaff) {
      _staffModel = await _authService.getStaffModel();
    }

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
