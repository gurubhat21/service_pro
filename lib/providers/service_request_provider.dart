import 'package:flutter/material.dart';
import 'package:service_pro/config/constants.dart';
import 'package:service_pro/models/service_request_model.dart';
import 'package:service_pro/services/firestore_service.dart';
import 'dart:async';

class ServiceRequestProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ServiceRequestModel> _services = [];
  List<ServiceRequestModel> _filteredServices = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedStatus;
  String? _selectedType;

  StreamSubscription? _serviceSubscription;

  List<ServiceRequestModel> get services => _filteredServices;
  List<ServiceRequestModel> get allServices => _services;
  List<ServiceRequestModel> get filteredServices => _filteredServices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedStatus => _selectedStatus;
  String? get selectedType => _selectedType;

  int get pendingCount =>
      _services.where((s) => s.status == ServiceStatus.pending).length;
  int get inProgressCount =>
      _services.where((s) => s.status == ServiceStatus.inProgress).length;
  int get completedCount =>
      _services.where((s) => s.status == ServiceStatus.completed).length;
  int get totalCount => _services.length;

  Future<void> loadServices(String adminId) async {
    _setLoading(true);
    try {
      _serviceSubscription?.cancel();
      _serviceSubscription =
          _firestoreService.getServicesStream(adminId).listen((data) {
        _services = data;
        _applyFilters();
      });
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> createService({
    required String adminId,
    required String customerId,
    required String customerName,
    required String customerPhone,
    required ServiceType serviceType,
    required String title,
    String? description,
    required ServicePriority priority,
    String? assignedStaffId,
    String? assignedStaffName,
    DateTime? scheduledDate,
    double? locationLat,
    double? locationLng,
    String? locationAddress,
  }) async {
    try {
      final now = DateTime.now();
      final id = _firestoreService.generateId('service_requests');
      final service = ServiceRequestModel(
        id: id,
        adminId: adminId,
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        assignedStaffId: assignedStaffId,
        assignedStaffName: assignedStaffName,
        serviceType: serviceType,
        title: title,
        description: description,
        status: ServiceStatus.pending,
        priority: priority,
        locationLat: locationLat,
        locationLng: locationLng,
        locationAddress: locationAddress,
        scheduledDate: scheduledDate,
        createdAt: now,
        updatedAt: now,
      );
      await _firestoreService.createServiceRequest(service);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateServiceStatus(String serviceId, ServiceStatus status) async {
    try {
      await _firestoreService.updateServiceStatus(serviceId, status);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _firestoreService.deleteServiceRequest(serviceId);
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
    _applyFilters();
  }

  void searchServices(String query) {
    _applyFilters();
  }

  void _applyFilters() {
    _filteredServices = List.from(_services);

    if (_selectedStatus != null) {
      _filteredServices = _filteredServices
          .where((s) => s.status.name == _selectedStatus)
          .toList();
    }

    if (_selectedType != null) {
      _filteredServices = _filteredServices
          .where((s) => s.serviceType.name == _selectedType)
          .toList();
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
