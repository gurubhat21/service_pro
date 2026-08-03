import 'package:flutter/material.dart';

class ReminderProvider extends ChangeNotifier {
  List<dynamic> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<dynamic> get upcomingReminders {
    // TODO: implement logic to filter upcoming reminders
    return _reminders;
  }

  Future<void> loadReminders(String adminId) async {
    _setLoading(true);
    try {
      // TODO: Implement load
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addReminder(dynamic reminderData) async {
    try {
      // TODO: Implement add
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      // TODO: Implement delete
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsNotified(String reminderId) async {
    try {
      // TODO: Implement update
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
