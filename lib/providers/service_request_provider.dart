import 'package:flutter/material.dart';
import 'dart:async';

class ServiceRequestProvider extends ChangeNotifier {
  List<dynamic> _services = [];
  List<dynamic> _filteredServices = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedStatus;
  String? _selectedType;
  
  StreamSubscription? _serviceSubscription;

  List<dynamic> get services => _services;
  List<dynamic> get filteredServices => _filteredServices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedStatus => _selectedStatus;
  String? get selectedType => _selectedType;

  int get pendingCount => _services.where((s) => s.status == 'Pending').length;
  int get inProgressCount => _services.where((s) => s.status == 'In Progress').length;
  int get completedCount => _services.where((s) => s.status == 'Completed').length;
  int get totalCount => _services.length;

  Future<void> loadServices(String adminId) async {
    _setLoading(true);
    try {
      // TODO: Implement load services from FirestoreService
      // _serviceSubscription = _firestoreService.getServicesStream(adminId).listen((data) {
      //   _services = data;
      //   _applyFilters();
      // });
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> createService(dynamic serviceData) async {
    try {
      // TODO: Implement create
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateServiceStatus(String serviceId, String status) async {
    try {
      // TODO: Implement update
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      // TODO: Implement delete
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void filterByStatus(String? status) {
    _selectedStatus = status;
    _applyFilters();
  }

  void filterByType(String? type) {
    _selectedType = type;
    _applyFilters();
  }
  
  void filterByStaff(String? staffId) {
    // TODO: implement staff filter
    _applyFilters();
  }
  
  void searchServices(String query) {
    // TODO: implement search
    _applyFilters();
  }

  void _applyFilters() {
    _filteredServices = List.from(_services);
    
    if (_selectedStatus != null) {
      _filteredServices = _filteredServices.where((s) => s.status == _selectedStatus).toList();
    }
    
    if (_selectedType != null) {
      _filteredServices = _filteredServices.where((s) => s.type == _selectedType).toList();
    }
    
    notifyListeners();
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _serviceSubscription?.cancel();
    super.dispose();
  }
}
