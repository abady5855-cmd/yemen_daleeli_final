import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_daleeli/features/auth/domain/entities/user_entity.dart';

/// نموذج المستخدم (User Model)
/// يستخدم لتمثيل بيانات المستخدم من Firebase مع دعم Audit Fields و Soft Delete
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.phoneNumber,
    super.profileImageUrl,
    super.address,
    super.city,
    super.isEmailVerified = false,
    required super.createdAt,
    super.lastLoginAt,
    super.role = UserRole.user,
    super.isActive = true,
    super.governorate,
    super.district,
    super.updatedAt,
    super.tenantId,
    this.isDeleted = false,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.version = 1,
  });

  final bool isDeleted;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;
  final int version;

  /// تحويل من JSON إلى UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate() 
          : DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null 
          ? (json['lastLoginAt'] is Timestamp 
              ? (json['lastLoginAt'] as Timestamp).toDate() 
              : DateTime.parse(json['lastLoginAt'] as String))
          : null,
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] as String? ?? 'user'),
        orElse: () => UserRole.user,
      ),
      isActive: json['isActive'] as bool? ?? true,
      governorate: json['governorate'] as String?,
      district: json['district'] as String?,
      tenantId: json['tenantId'] as String?,
      updatedAt: json['updatedAt'] != null 
          ? (json['updatedAt'] is Timestamp 
              ? (json['updatedAt'] as Timestamp).toDate() 
              : DateTime.parse(json['updatedAt'] as String))
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null 
          ? (json['deletedAt'] is Timestamp 
              ? (json['deletedAt'] as Timestamp).toDate() 
              : DateTime.parse(json['deletedAt'] as String))
          : null,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      deletedBy: json['deletedBy'] as String?,
      version: json['version'] as int? ?? 1,
    );
  }

  /// تحويل لـ JSON الخاص بـ Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'city': city,
      'isEmailVerified': isEmailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'role': role.name,
      'isActive': isActive,
      'governorate': governorate,
      'district': district,
      'tenantId': tenantId,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'deletedBy': deletedBy,
      'version': version,
    };
  }

  /// تحويل لـ JSON بسيط للتخزين المحلي
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'city': city,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'role': role.name,
      'isActive': isActive,
      'governorate': governorate,
      'district': district,
      'tenantId': tenantId,
      'updatedAt': updatedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'deletedBy': deletedBy,
      'version': version,
    };
  }

  /// تحويل من Entity إلى Model
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      profileImageUrl: entity.profileImageUrl,
      address: entity.address,
      city: entity.city,
      isEmailVerified: entity.isEmailVerified,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      role: entity.role,
      isActive: entity.isActive,
      governorate: entity.governorate,
      district: entity.district,
      tenantId: entity.tenantId,
      updatedAt: entity.updatedAt,
    );
  }
}
