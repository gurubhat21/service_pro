import 'package:flutter/material.dart';
import 'package:service_pro/models/customer_model.dart';
import 'package:service_pro/services/firestore_service.dart';
import 'dart:async';

class CustomerProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CustomerModel> _customers = [];
  List<CustomerModel> _filteredCustomers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  StreamSubscription? _customerSubscription;

  List<CustomerModel> get customers => _filteredCustomers;
  List<CustomerModel> get allCustomers => _customers;
  List<CustomerModel> get filteredCustomers => _filteredCustomers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> loadCustomers(String adminId) async {
    _setLoading(true);
    try {
      _customerSubscription?.cancel();
      _customerSubscription =
          _firestoreService.getCustomersStream(adminId).listen((data) {
        _customers = data;
        _applyFilter();
      });
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> addCustomer({
    required String adminId,
    required String name,
    required String phone,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final id = _firestoreService.generateId('customers');
      final customer = CustomerModel(
        id: id,
        adminId: adminId,
        name: name,
        phone: phone,
        email: email,
        address: address,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now(),
      );
      await _firestoreService.createCustomer(customer);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCustomer(String id, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateCustomerFields(id, data);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _firestoreService.deleteCustomer(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilter();
  }

  /// Alias for search - used by some screens
  void searchCustomers(String query) => search(query);

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredCustomers = List.from(_customers);
    } else {
      _filteredCustomers = _customers.where((c) {
        final name = c.name.toLowerCase();
        final phone = c.phone.toLowerCase();
        return name.contains(_searchQuery) || phone.contains(_searchQuery);
      }).toList();
    }
    _setLoading(false);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _customerSubscription?.cancel();
    super.dispose();
  }
}
