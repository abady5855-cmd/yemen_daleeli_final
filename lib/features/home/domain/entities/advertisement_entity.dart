import 'package:equatable/equatable.dart';

/// كيان الإعلان (Advertisement Entity)
class AdvertisementEntity extends Equatable {
  final String id;
  final String titleAr;
  final String? titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String imageUrl;
  final String? targetUrl;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  const AdvertisementEntity({
    required this.id,
    required this.titleAr,
    this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.imageUrl,
    this.targetUrl,
    this.isActive = true,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        titleAr,
        titleEn,
        descriptionAr,
        descriptionEn,
        imageUrl,
        targetUrl,
        isActive,
        startDate,
        endDate,
        createdAt,
      ];

  /// الحصول على العنوان بناءً على اللغة
  String getTitle(String languageCode) {
    if (languageCode == 'en' && titleEn != null && titleEn!.isNotEmpty) {
      return titleEn!;
    }
    return titleAr;
  }
}
