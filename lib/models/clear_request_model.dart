import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_pro/config/constants.dart';

class ClearRequestModel {
  final String id;
  final String serviceRequestId;
  final String staffId;
  final String staffName;
  final String adminId;
  final String? note;
  final ClearRequestStatus status;
  final String? serviceTitle;
  final DateTime createdAt;
  final DateTime? respondedAt;

  ClearRequestModel({
    required this.id,
    required this.serviceRequestId,
    required this.staffId,
    required this.staffName,
    required this.adminId,
    this.note,
    required this.status,
    this.serviceTitle,
    required this.createdAt,
    this.respondedAt,
  });

  factory ClearRequestModel.fromMap(Map<String, dynamic> map) {
    return ClearRequestModel(
      id: map['id'] as String,
      serviceRequestId: map['serviceRequestId'] as String,
      staffId: map['staffId'] as String,
      staffName: map['staffName'] as String,
      adminId: map['adminId'] as String,
      note: map['note'] as String?,
      status: ClearRequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ClearRequestStatus.pending,
      ),
      serviceTitle: map['serviceTitle'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      respondedAt: map['respondedAt'] != null ? (map['respondedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceRequestId': serviceRequestId,
      'staffId': staffId,
      'staffName': staffName,
      'adminId': adminId,
      'note': note,
      'status': status.toString().split('.').last,
      'serviceTitle': serviceTitle,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }

  ClearRequestModel copyWith({
    String? id,
    String? serviceRequestId,
    String? staffId,
    String? staffName,
    String? adminId,
    String? note,
    ClearRequestStatus? status,
    String? serviceTitle,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return ClearRequestModel(
      id: id ?? this.id,
      serviceRequestId: serviceRequestId ?? this.serviceRequestId,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      adminId: adminId ?? this.adminId,
      note: note ?? this.note,
      status: status ?? this.status,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
