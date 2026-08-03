import 'package:flutter/material.dart';
import 'package:service_pro/models/reminder_model.dart';
import 'package:service_pro/services/firestore_service.dart';
import 'dart:async';

class ReminderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ReminderModel> _reminders = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription? _reminderSubscription;

  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ReminderModel> get upcomingReminders {
    final now = DateTime.now();
    return _reminders.where((r) => r.remindAt.isAfter(now)).toList()
      ..sort((a, b) => a.remindAt.compareTo(b.remindAt));
  }

  Future<void> loadReminders(String adminId) async {
    _setLoading(true);
    try {
      _reminderSubscription?.cancel();
      _reminderSubscription =
          _firestoreService.getRemindersStream(adminId).listen((data) {
        _reminders = data;
        _setLoading(false);
      });
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> addReminder({
    required String adminId,
    required String title,
    String? message,
    required DateTime remindAt,
    String? serviceRequestId,
  }) async {
    try {
      final id = _firestoreService.generateId('reminders');
      final reminder = ReminderModel(
        id: id,
        adminId: adminId,
        title: title,
        message: message,
        remindAt: remindAt,
        serviceRequestId: serviceRequestId,
        isNotified: false,
        createdAt: DateTime.now(),
      );
      await _firestoreService.createReminder(reminder);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      await _firestoreService.deleteReminder(reminderId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsNotified(String reminderId) async {
    try {
      // TODO: implement mark as notified
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
    _reminderSubscription?.cancel();
    super.dispose();
  }
}
