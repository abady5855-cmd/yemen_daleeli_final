import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_daleeli/features/reviews/domain/entities/review_entity.dart';

/// نموذج التقييم (Review Model)
/// يستخدم لتمثيل بيانات التقييم من Firestore
class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.serviceId,
    required super.userId,
    required super.userName,
    super.userProfileImageUrl,
    required super.rating,
    required super.commentAr,
    super.commentEn,
    super.imageUrls = const [],
    super.helpfulCount = 0,
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

  /// تحويل من JSON إلى ReviewModel
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? 'مستخدم',
      userProfileImageUrl: json['userProfileImageUrl'] as String?,
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      commentAr: json['comment_ar'] as String? ?? '',
      commentEn: json['comment_en'] as String?,
      imageUrls: List<String>.from(json['images'] ?? []),
      helpfulCount: json['helpful'] as int? ?? 0,
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
      'serviceId': serviceId,
      'userId': userId,
      'userName': userName,
      'userProfileImageUrl': userProfileImageUrl,
      'rating': rating,
      'comment_ar': commentAr,
      'comment_en': commentEn,
      'images': imageUrls,
      'helpful': helpfulCount,
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
      'serviceId': serviceId,
      'userId': userId,
      'userName': userName,
      'userProfileImageUrl': userProfileImageUrl,
      'rating': rating,
      'comment_ar': commentAr,
      'comment_en': commentEn,
      'images': imageUrls,
      'helpful': helpfulCount,
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
  factory ReviewModel.fromEntity(ReviewEntity entity) {
    return ReviewModel(
      id: entity.id,
      serviceId: entity.serviceId,
      userId: entity.userId,
      userName: entity.userName,
      userProfileImageUrl: entity.userProfileImageUrl,
      rating: entity.rating,
      commentAr: entity.commentAr,
      commentEn: entity.commentEn,
      imageUrls: entity.imageUrls,
      helpfulCount: entity.helpfulCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
