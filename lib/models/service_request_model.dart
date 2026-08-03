import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_pro/config/constants.dart';

class ServiceRequestModel {
  final String id;
  final String adminId;
  final String customerId;
  final String? customerName;
  final String? customerPhone;
  final String? assignedStaffId;
  final String? assignedStaffName;
  final ServiceType serviceType;
  final String title;
  final String? description;
  final ServiceStatus status;
  final ServicePriority priority;
  final double? locationLat;
  final double? locationLng;
  final String? locationAddress;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceRequestModel({
    required this.id,
    required this.adminId,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    this.assignedStaffId,
    this.assignedStaffName,
    required this.serviceType,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.locationLat,
    this.locationLng,
    this.locationAddress,
    this.scheduledDate,
    this.completedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceRequestModel.fromMap(Map<String, dynamic> map) {
    return ServiceRequestModel(
      id: map['id'] as String,
      adminId: map['adminId'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String?,
      customerPhone: map['customerPhone'] as String?,
      assignedStaffId: map['assignedStaffId'] as String?,
      assignedStaffName: map['assignedStaffName'] as String?,
      serviceType: ServiceType.values.firstWhere(
        (e) => e.toString().split('.').last == map['serviceType'],
        orElse: () => ServiceType.computer,
      ),
      title: map['title'] as String,
      description: map['description'] as String?,
      status: ServiceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ServiceStatus.pending,
      ),
      priority: ServicePriority.values.firstWhere(
        (e) => e.toString().split('.').last == map['priority'],
        orElse: () => ServicePriority.medium,
      ),
      locationLat: (map['locationLat'] as num?)?.toDouble(),
      locationLng: (map['locationLng'] as num?)?.toDouble(),
      locationAddress: map['locationAddress'] as String?,
      scheduledDate: map['scheduledDate'] != null ? (map['scheduledDate'] as Timestamp).toDate() : null,
      completedDate: map['completedDate'] != null ? (map['completedDate'] as Timestamp).toDate() : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminId': adminId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'assignedStaffId': assignedStaffId,
      'assignedStaffName': assignedStaffName,
      'serviceType': serviceType.toString().split('.').last,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'locationAddress': locationAddress,
      'scheduledDate': scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
      'completedDate': completedDate != null ? Timestamp.fromDate(completedDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ServiceRequestModel copyWith({
    String? id,
    String? adminId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? assignedStaffId,
    String? assignedStaffName,
    ServiceType? serviceType,
    String? title,
    String? description,
    ServiceStatus? status,
    ServicePriority? priority,
    double? locationLat,
    double? locationLng,
    String? locationAddress,
    DateTime? scheduledDate,
    DateTime? completedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      serviceType: serviceType ?? this.serviceType,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      locationAddress: locationAddress ?? this.locationAddress,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
