import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_daleeli/features/home/domain/entities/advertisement_entity.dart';

/// نموذج الإعلان
/// مسؤول عن تحويل بيانات Firestore إلى AdvertisementEntity
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

  /// تحويل Timestamp / String إلى DateTime بشكل آمن
  static DateTime _parseDate(
    dynamic value, {
    DateTime? fallback,
  }) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);

      if (parsed != null) {
        return parsed;
      }
    }

    return fallback ?? DateTime.now();
  }

  /// تحويل قيمة إلى String بشكل آمن
  static String _parseString(
    dynamic value, {
    String fallback = '',
  }) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return fallback;
  }

  /// تحويل Firestore إلى AdvertisementModel
  factory AdvertisementModel.fromJson(
    Map<String, dynamic> json, {
    String? documentId,
  }) {
    final id = _parseString(
      json['id'],
      fallback: documentId ?? '',
    );

    final titleAr = _parseString(
      json['title_ar'],
      fallback: 'إعلان',
    );

    final imageUrl = _parseString(
      json['image'],
    );

    return AdvertisementModel(
      id: id,

      titleAr: titleAr,

      titleEn: json['title_en'] as String?,

      descriptionAr: json['description_ar'] as String?,

      descriptionEn: json['description_en'] as String?,

      imageUrl: imageUrl,

      targetUrl: json['targetUrl'] as String?,

      isActive: json['isActive'] as bool? ?? true,

      startDate: _parseDate(
        json['startDate'],
      ),

      endDate: _parseDate(
        json['endDate'],
      ),

      createdAt: _parseDate(
        json['createdAt'],
      ),

      isDeleted: json['isDeleted'] as bool? ?? false,

      version: json['version'] is int
          ? json['version'] as int
          : 1,
    );
  }

  /// تحويل إلى Firestore
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

  /// تحويل إلى JSON للتخزين المحلي
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
