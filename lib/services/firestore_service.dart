import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_pro/models/admin_model.dart';
import 'package:service_pro/models/staff_model.dart';
import 'package:service_pro/models/customer_model.dart';
import 'package:service_pro/models/service_request_model.dart';
import 'package:service_pro/models/clear_request_model.dart';
import 'package:service_pro/models/reminder_model.dart';
import 'package:service_pro/config/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Admins ---
  Future<AdminModel?> getAdmin(String uid) async {
    final doc = await _db.collection('admins').doc(uid).get();
    if (doc.exists) {
      return AdminModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateAdmin(AdminModel admin) async {
    await _db.collection('admins').doc(admin.uid).update(admin.toMap());
  }

  // --- Staff ---
  Future<void> inviteStaff(String email, String adminId, StaffRole role) async {
    await _db.collection('staff_invites').add({
      'email': email,
      'adminId': adminId,
      'role': role.toString().split('.').last,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<StaffModel>> getStaffByAdmin(String adminId) {
    return _db
        .collection('staff')
        .where('adminId', isEqualTo: adminId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StaffModel.fromMap(doc.data()))
            .toList());
  }

  // --- Customers ---
  Future<void> createCustomer(CustomerModel customer) async {
    await _db.collection('customers').doc(customer.id).set(customer.toMap());
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await _db.collection('customers').doc(customer.id).update(customer.toMap());
  }

  Stream<List<CustomerModel>> getCustomersByAdmin(String adminId) {
    return _db
        .collection('customers')
        .where('adminId', isEqualTo: adminId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomerModel.fromMap(doc.data()))
            .toList());
  }

  // --- Service Requests ---
  Future<void> createServiceRequest(ServiceRequestModel request) async {
    await _db.collection('service_requests').doc(request.id).set(request.toMap());
  }

  Future<void> updateServiceRequest(ServiceRequestModel request) async {
    await _db.collection('service_requests').doc(request.id).update(request.toMap());
  }

  Stream<List<ServiceRequestModel>> getServicesByAdmin(String adminId) {
    return _db
        .collection('service_requests')
        .where('adminId', isEqualTo: adminId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceRequestModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<ServiceRequestModel>> getServicesByStaff(String staffId) {
    return _db
        .collection('service_requests')
        .where('assignedStaffId', isEqualTo: staffId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceRequestModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<ServiceRequestModel>> getServicesByStatus(String adminId, ServiceStatus status) {
    return _db
        .collection('service_requests')
        .where('adminId', isEqualTo: adminId)
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceRequestModel.fromMap(doc.data()))
            .toList());
  }

  Future<Map<ServiceStatus, int>> getServiceCounts(String adminId) async {
    final Map<ServiceStatus, int> counts = {};
    for (var status in ServiceStatus.values) {
      counts[status] = 0;
    }

    final querySnapshot = await _db
        .collection('service_requests')
        .where('adminId', isEqualTo: adminId)
        .get();

    for (var doc in querySnapshot.docs) {
      final statusStr = doc['status'] as String;
      final status = ServiceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == statusStr,
        orElse: () => ServiceStatus.pending,
      );
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  // --- Clear Requests ---
  Future<void> createClearRequest(ClearRequestModel request) async {
    final batch = _db.batch();
    
    // Create clear request
    final clearRef = _db.collection('clear_requests').doc(request.id);
    batch.set(clearRef, request.toMap());

    // Update service request status
    final serviceRef = _db.collection('service_requests').doc(request.serviceRequestId);
    batch.update(serviceRef, {
      'status': ServiceStatus.clear_requested.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Stream<List<ClearRequestModel>> getPendingClearRequests(String adminId) {
    return _db
        .collection('clear_requests')
        .where('adminId', isEqualTo: adminId)
        .where('status', isEqualTo: ClearRequestStatus.pending.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClearRequestModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> respondToClearRequest(String clearRequestId, String serviceRequestId, bool approve) async {
    final batch = _db.batch();
    final now = FieldValue.serverTimestamp();

    // Update clear request
    final clearRef = _db.collection('clear_requests').doc(clearRequestId);
    batch.update(clearRef, {
      'status': (approve ? ClearRequestStatus.approved : ClearRequestStatus.rejected).toString().split('.').last,
      'respondedAt': now,
    });

    // Update service request
    final serviceRef = _db.collection('service_requests').doc(serviceRequestId);
    batch.update(serviceRef, {
      'status': (approve ? ServiceStatus.completed : ServiceStatus.in_progress).toString().split('.').last,
      if (approve) 'completedDate': now,
      'updatedAt': now,
    });

    await batch.commit();
  }

  // --- Reminders ---
  Future<void> createReminder(ReminderModel reminder) async {
    await _db.collection('reminders').doc(reminder.id).set(reminder.toMap());
  }
}
