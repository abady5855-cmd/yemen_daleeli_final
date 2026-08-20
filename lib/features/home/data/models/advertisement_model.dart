import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_daleeli/features/home/domain/entities/advertisement_entity.dart';

/// نموذج الإعلان (Advertisement Model)
/// يستخدم لتمثيل بيانات الإعلان من Firestore
class AdvertisementModel extends AdvertisementEntity {
  const AdvertisementModel({
    required super.id,
    required super.titleAr,
    super.titleEn,
    super.descriptionAr,
    super.descriptionEn,
    required super.imageUrl,
    super.targetUrl,
    super.isActive = true,
    required super.startDate,
    required super.endDate,
    required super.createdAt,
    this.isDeleted = false,
    this.version = 1,
  });

  final bool isDeleted;
  final int version;

  /// تحويل من JSON إلى AdvertisementModel
  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: json['id'] as String,
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      imageUrl: json['image'] as String,
      targetUrl: json['targetUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      startDate: json['startDate'] is Timestamp 
          ? (json['startDate'] as Timestamp).toDate() 
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] is Timestamp 
          ? (json['endDate'] as Timestamp).toDate() 
          : DateTime.parse(json['endDate'] as String),
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate() 
          : DateTime.parse(json['createdAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
      version: json['version'] as int? ?? 1,
    );
  }

  /// تحويل لـ JSON الخاص بـ Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title_ar': titleAr,
      'title_en': titleEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'image': imageUrl,
      'targetUrl': targetUrl,
      'isActive': isActive,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'isDeleted': isDeleted,
      'version': version,
    };
  }

  /// تحويل لـ JSON بسيط للتخزين المحلي
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_ar': titleAr,
      'title_en': titleEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'image': imageUrl,
      'targetUrl': targetUrl,
      'isActive': isActive,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isDeleted': isDeleted,
      'version': version,
    };
  }
}
