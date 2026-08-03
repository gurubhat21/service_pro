import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_pro/config/constants.dart';

class StaffModel {
  final String uid;
  final String adminId;
  final String email;
  final String name;
  final String phone;
  final StaffRole role;
  final bool isActive;
  final String? photoUrl;
  final DateTime createdAt;

  StaffModel({
    required this.uid,
    required this.adminId,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.isActive,
    this.photoUrl,
    required this.createdAt,
  });

  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      uid: map['uid'] as String,
      adminId: map['adminId'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      role: StaffRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => StaffRole.technician,
      ),
      isActive: map['isActive'] as bool? ?? true,
      photoUrl: map['photoUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'adminId': adminId,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.toString().split('.').last,
      'isActive': isActive,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  StaffModel copyWith({
    String? uid,
    String? adminId,
    String? email,
    String? name,
    String? phone,
    StaffRole? role,
    bool? isActive,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return StaffModel(
      uid: uid ?? this.uid,
      adminId: adminId ?? this.adminId,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
