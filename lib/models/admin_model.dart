import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String? businessName;
  final String? photoUrl;
  final DateTime createdAt;

  AdminModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.businessName,
    this.photoUrl,
    required this.createdAt,
  });

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      businessName: map['businessName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'businessName': businessName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AdminModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? businessName,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return AdminModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
