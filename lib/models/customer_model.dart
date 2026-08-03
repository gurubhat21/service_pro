import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String adminId;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? mapPlaceId;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.adminId,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.latitude,
    this.longitude,
    this.mapPlaceId,
    required this.createdAt,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String,
      adminId: map['adminId'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      address: map['address'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      mapPlaceId: map['mapPlaceId'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminId': adminId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'mapPlaceId': mapPlaceId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CustomerModel copyWith({
    String? id,
    String? adminId,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
    String? mapPlaceId,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mapPlaceId: mapPlaceId ?? this.mapPlaceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
