import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_daleeli/features/categories/domain/entities/category_entity.dart';

/// نموذج التصنيف (Category Model)
/// يستخدم لتمثيل بيانات التصنيف من Firestore
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.nameAr,
    super.nameEn,
    super.descriptionAr,
    super.descriptionEn,
    super.icon,
    super.color,
    super.serviceCount = 0,
    super.isActive = true,
    required super.createdAt,
    super.updatedAt,
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

  /// تحويل من JSON إلى CategoryModel
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      serviceCount: json['serviceCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate() 
          : DateTime.parse(json['createdAt'] as String),
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
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'icon': icon,
      'color': color,
      'serviceCount': serviceCount,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
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
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'icon': icon,
      'color': color,
      'serviceCount': serviceCount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
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
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      icon: entity.icon,
      color: entity.color,
      serviceCount: entity.serviceCount,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
