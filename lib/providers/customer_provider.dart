import 'package:flutter/material.dart';

class CustomerProvider extends ChangeNotifier {
  List<dynamic> _customers = [];
  List<dynamic> _filteredCustomers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<dynamic> get customers => _customers;
  List<dynamic> get filteredCustomers => _filteredCustomers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> loadCustomers(String adminId) async {
    _setLoading(true);
    try {
      // TODO: Implement load from Firestore
      // _customers = await _firestoreService.getCustomers(adminId);
      _applyFilter();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCustomer(dynamic customerData) async {
    try {
      // TODO: Implement add
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCustomer(String id, dynamic data) async {
    try {
      // TODO: Implement update
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      // TODO: Implement delete
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilter();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredCustomers = List.from(_customers);
    } else {
      _filteredCustomers = _customers.where((c) {
        final name = (c.name ?? '').toLowerCase();
        final phone = (c.phone ?? '').toLowerCase();
        return name.contains(_searchQuery) || phone.contains(_searchQuery);
      }).toList();
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
