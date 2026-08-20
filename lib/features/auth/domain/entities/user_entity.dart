import 'package:equatable/equatable.dart';

/// تعريف أدوار المستخدم (User Roles)
enum UserRole {
  guest,          // ضيف (بدون حساب)
  user,           // مستخدم عادي
  businessOwner,  // صاحب نشاط تجاري
  moderator,      // مشرف
  admin,          // مسؤول
  superAdmin,     // مسؤول عام
}

/// توسيع UserRole لإضافة دوال مساعدة
extension UserRoleExtension on UserRole {
  /// الحصول على اسم الدور بالعربية
  String get displayName {
    switch (this) {
      case UserRole.guest:
        return 'ضيف';
      case UserRole.user:
        return 'مستخدم';
      case UserRole.businessOwner:
        return 'صاحب نشاط';
      case UserRole.moderator:
        return 'مشرف';
      case UserRole.admin:
        return 'مسؤول';
      case UserRole.superAdmin:
        return 'مسؤول عام';
    }
  }

  /// التحقق من كون المستخدم لديه صلاحيات إدارية
  bool get isAdmin => this == UserRole.admin || this == UserRole.superAdmin;

  /// التحقق من كون المستخدم صاحب نشاط
  bool get isBusinessOwner => this == UserRole.businessOwner;

  /// التحقق من كون المستخدم ضيفاً
  bool get isGuest => this == UserRole.guest;

  /// التحقق من كون المستخدم لديه حساب حقيقي
  bool get hasRealAccount => this != UserRole.guest;
}

/// كيان المستخدم (User Entity)
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? address;
  final String? city;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final UserRole role;
  final bool isActive;
  final String? governorate;
  final String? district;
  final DateTime? updatedAt;
  final String? tenantId;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.profileImageUrl,
    this.address,
    this.city,
    this.isEmailVerified = false,
    required this.createdAt,
    this.lastLoginAt,
    this.role = UserRole.user,
    this.isActive = true,
    this.governorate,
    this.district,
    this.updatedAt,
    this.tenantId,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    phoneNumber,
    profileImageUrl,
    address,
    city,
    isEmailVerified,
    createdAt,
    lastLoginAt,
    role,
    isActive,
    governorate,
    district,
    updatedAt,
    tenantId,
  ];

  /// نسخ المستخدم مع تعديلات
  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
    String? address,
    String? city,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    UserRole? role,
    bool? isActive,
    String? governorate,
    String? district,
    DateTime? updatedAt,
    String? tenantId,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      city: city ?? this.city,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      governorate: governorate ?? this.governorate,
      district: district ?? this.district,
      updatedAt: updatedAt ?? this.updatedAt,
      tenantId: tenantId ?? this.tenantId,
    );
  }

  /// التحقق من كون المستخدم ضيفاً
  bool get isGuest => role == UserRole.guest;

  /// التحقق من كون المستخدم لديه صلاحيات إدارية
  bool get isAdmin => role.isAdmin;

  /// التحقق من كون المستخدم صاحب نشاط
  bool get isBusinessOwner => role.isBusinessOwner;

  /// التحقق من كون المستخدم لديه حساب حقيقي
  bool get hasRealAccount => role.hasRealAccount;
}
