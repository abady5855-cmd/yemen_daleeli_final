import 'package:equatable/equatable.dart';

/// كيان التصنيف (Category Entity)
/// يمثل تصنيف واحد من تصنيفات الخدمات مع دعم تعدد اللغات
class CategoryEntity extends Equatable {
  final String id;
  final String nameAr;
  final String? nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? icon;
  final String? color;
  final int serviceCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CategoryEntity({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.icon,
    this.color,
    this.serviceCount = 0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        descriptionAr,
        descriptionEn,
        icon,
        color,
        serviceCount,
        isActive,
        createdAt,
        updatedAt,
      ];

  /// الحصول على الاسم بناءً على اللغة
  String getName(String languageCode) {
    if (languageCode == 'en' && nameEn != null && nameEn!.isNotEmpty) {
      return nameEn!;
    }
    return nameAr;
  }

  /// الحصول على الوصف بناءً على اللغة
  String getDescription(String languageCode) {
    if (languageCode == 'en' && descriptionEn != null && descriptionEn!.isNotEmpty) {
      return descriptionEn!;
    }
    return descriptionAr ?? '';
  }

  /// نسخ مع تعديل
  CategoryEntity copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? icon,
    String? color,
    int? serviceCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      serviceCount: serviceCount ?? this.serviceCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
