import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_daleeli/core/models/working_hours_model.dart';
import 'package:yemen_daleeli/features/services/domain/entities/service_entity.dart';

/// نموذج الخدمة (Service Model)
/// يستخدم لتمثيل بيانات الخدمة من Firestore
class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.nameAr,
    super.nameEn,
    required super.descriptionAr,
    super.descriptionEn,
    required super.categoryId,
    required super.addressAr,
    super.addressEn,
    required super.phone,
    super.whatsapp,
    super.website,
    super.email,
    super.latitude,
    super.longitude,
    super.rating = 0.0,
    super.reviewCount = 0,
    super.favoriteCount = 0,
    super.imageUrls = const [],
    required super.workingHours,
    super.isFavorite = false,
    required super.createdAt,
    super.updatedAt,
    required super.ownerId,
    super.status = ServiceStatus.pending,
    required super.governorateId,
    required super.districtId,
    super.subDistrictId,
    super.verified = false,
    super.featured = false,
    super.tags = const [],
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

  /// تحويل من JSON إلى ServiceModel
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      descriptionAr: json['description_ar'] as String,
      descriptionEn: json['description_en'] as String?,
      categoryId: json['categoryId'] as String,
      addressAr: json['address_ar'] as String,
      addressEn: json['address_en'] as String?,
      phone: json['phone'] as String,
      whatsapp: json['whatsapp'] as String?,
      website: json['website'] as String?,
      email: json['email'] as String?,
      latitude: json['location'] is GeoPoint 
          ? (json['location'] as GeoPoint).latitude 
          : (json['location'] is Map ? json['location']['lat'] : null),
      longitude: json['location'] is GeoPoint 
          ? (json['location'] as GeoPoint).longitude 
          : (json['location'] is Map ? json['location']['lng'] : null),
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] as int? ?? 0,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
      imageUrls: List<String>.from(json['galleryImages'] ?? []),
      workingHours: WeeklyWorkingHours.fromJson(json['workingHours'] ?? {}),
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate() 
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? (json['updatedAt'] is Timestamp 
              ? (json['updatedAt'] as Timestamp).toDate() 
              : DateTime.parse(json['updatedAt'] as String))
          : null,
      ownerId: json['ownerId'] as String,
      status: ServiceStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => ServiceStatus.pending,
      ),
      governorateId: json['governorateId'] as String,
      districtId: json['districtId'] as String,
      subDistrictId: json['subDistrictId'] as String?,
      verified: json['verified'] as bool? ?? false,
      featured: json['featured'] as bool? ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      tenantId: json['tenantId'] as String?,
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
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'categoryId': categoryId,
      'address_ar': addressAr,
      'address_en': addressEn,
      'phone': phone,
      'whatsapp': whatsapp,
      'website': website,
      'email': email,
      'location': latitude != null && longitude != null 
          ? GeoPoint(latitude!, longitude!) 
          : null,
      'rating': rating,
      'reviewCount': reviewCount,
      'favoriteCount': favoriteCount,
      'galleryImages': imageUrls,
      'workingHours': workingHours.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'ownerId': ownerId,
      'status': status.name,
      'governorateId': governorateId,
      'districtId': districtId,
      'subDistrictId': subDistrictId,
      'verified': verified,
      'featured': featured,
      'tags': tags,
      'tenantId': tenantId,
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
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'categoryId': categoryId,
      'address_ar': addressAr,
      'address_en': addressEn,
      'phone': phone,
      'whatsapp': whatsapp,
      'website': website,
      'email': email,
      'location': latitude != null && longitude != null 
          ? {'lat': latitude, 'lng': longitude} 
          : null,
      'rating': rating,
      'reviewCount': reviewCount,
      'favoriteCount': favoriteCount,
      'galleryImages': imageUrls,
      'workingHours': workingHours.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'ownerId': ownerId,
      'status': status.name,
      'governorateId': governorateId,
      'districtId': districtId,
      'subDistrictId': subDistrictId,
      'verified': verified,
      'featured': featured,
      'tags': tags,
      'tenantId': tenantId,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'deletedBy': deletedBy,
      'version': version,
    };
  }

  factory ServiceModel.fromEntity(ServiceEntity entity) {
    return ServiceModel(
      id: entity.id,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      categoryId: entity.categoryId,
      addressAr: entity.addressAr,
      addressEn: entity.addressEn,
      phone: entity.phone,
      whatsapp: entity.whatsapp,
      website: entity.website,
      email: entity.email,
      latitude: entity.latitude,
      longitude: entity.longitude,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      favoriteCount: entity.favoriteCount,
      imageUrls: entity.imageUrls,
      workingHours: entity.workingHours,
      isFavorite: entity.isFavorite,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      ownerId: entity.ownerId,
      status: entity.status,
      governorateId: entity.governorateId,
      districtId: entity.districtId,
      subDistrictId: entity.subDistrictId,
      verified: entity.verified,
      featured: entity.featured,
      tags: entity.tags,
      tenantId: entity.tenantId,
    );
  }
}
