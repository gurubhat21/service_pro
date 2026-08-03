import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String? serviceRequestId;
  final String adminId;
  final String title;
  final String? message;
  final DateTime remindAt;
  final bool isNotified;
  final DateTime createdAt;

  ReminderModel({
    required this.id,
    this.serviceRequestId,
    required this.adminId,
    required this.title,
    this.message,
    required this.remindAt,
    this.isNotified = false,
    required this.createdAt,
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      serviceRequestId: map['serviceRequestId'] as String?,
      adminId: map['adminId'] as String,
      title: map['title'] as String,
      message: map['message'] as String?,
      remindAt: (map['remindAt'] as Timestamp).toDate(),
      isNotified: map['isNotified'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceRequestId': serviceRequestId,
      'adminId': adminId,
      'title': title,
      'message': message,
      'remindAt': Timestamp.fromDate(remindAt),
      'isNotified': isNotified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ReminderModel copyWith({
    String? id,
    String? serviceRequestId,
    String? adminId,
    String? title,
    String? message,
    DateTime? remindAt,
    bool? isNotified,
    DateTime? createdAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      serviceRequestId: serviceRequestId ?? this.serviceRequestId,
      adminId: adminId ?? this.adminId,
      title: title ?? this.title,
      message: message ?? this.message,
      remindAt: remindAt ?? this.remindAt,
      isNotified: isNotified ?? this.isNotified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
