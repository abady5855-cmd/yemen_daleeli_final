import 'package:equatable/equatable.dart';

/// كائن التقييم (Entity)
/// يمثل تقييماً واحداً لخدمة مع دعم Audit Fields
class ReviewEntity extends Equatable {
  final String id;
  final String serviceId;
  final String userId;
  final String userName;
  final String? userProfileImageUrl;
  final double rating;
  final String comment;
  final List<String> imageUrls;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReviewEntity({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.userName,
    this.userProfileImageUrl,
    required this.rating,
    required this.comment,
    this.imageUrls = const [],
    this.helpfulCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        serviceId,
        userId,
        userName,
        userProfileImageUrl,
        rating,
        comment,
        imageUrls,
        helpfulCount,
        createdAt,
        updatedAt,
      ];

  /// نسخ التقييم مع تعديلات
  ReviewEntity copyWith({
    String? id,
    String? serviceId,
    String? userId,
    String? userName,
    String? userProfileImageUrl,
    double? rating,
    String? comment,
    List<String>? imageUrls,
    int? helpfulCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
