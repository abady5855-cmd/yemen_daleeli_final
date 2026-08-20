import 'package:equatable/equatable.dart';
import 'package:yemen_daleeli/core/models/working_hours_model.dart';

/// حالات الخدمة
enum ServiceStatus {
  active, // نشط
  pending, // قيد الانتظار
  hidden, // مخفي
  closed, // مغلق
}

/// كائن الخدمة (Entity)
/// يمثل خدمة واحدة في التطبيق مع دعم تعدد اللغات و Audit Fields
class ServiceEntity extends Equatable {
  final String id; // معرف فريد (UUID)
  final String nameAr; // اسم الخدمة بالعربية
  final String? nameEn; // اسم الخدمة بالإنجليزية
  final String descriptionAr; // وصف الخدمة بالعربية
  final String? descriptionEn; // وصف الخدمة بالإنجليزية
  final String categoryId; // معرف التصنيف (UUID)
  final String addressAr; // العنوان بالعربية
  final String? addressEn; // العنوان بالإنجليزية
  final String phone; // رقم الهاتف
  final String? whatsapp; // رقم واتس (اختياري)
  final String? website; // الموقع الإلكتروني (اختياري)
  final String? email; // البريد الإلكتروني (اختياري)
  final double? latitude; // خط العرض
  final double? longitude; // خط الطول
  final double rating; // التقييم
  final int reviewCount; // عدد التقييمات
  final int favoriteCount; // عدد المفضلات
  final List<String> imageUrls; // قائمة الصور
  final WeeklyWorkingHours workingHours; // ساعات العمل الأسبوعية
  final bool isFavorite; // هل مفضل للمستخدم الحالي
  final DateTime createdAt; // تاريخ الإنشاء
  final DateTime? updatedAt; // تاريخ التحديث
  final String ownerId; // معرف المالك (UUID)
  final ServiceStatus status; // حالة الخدمة
  final String governorateId; // معرف المحافظة (UUID)
  final String districtId; // معرف المنطقة (UUID)
  final String? subDistrictId; // معرف الحي (UUID)
  final bool verified; // هل تم التحقق من الخدمة
  final bool featured; // هل الخدمة مميزة
  final List<String> tags; // كلمات مفتاحية
  final String? tenantId; // معرف المستأجر (UUID)

  const ServiceEntity({
    required this.id,
    required this.nameAr,
    this.nameEn,
    required this.descriptionAr,
    this.descriptionEn,
    required this.categoryId,
    required this.addressAr,
    this.addressEn,
    required this.phone,
    this.whatsapp,
    this.website,
    this.email,
    this.latitude,
    this.longitude,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.favoriteCount = 0,
    this.imageUrls = const [],
    required this.workingHours,
    this.isFavorite = false,
    required this.createdAt,
    this.updatedAt,
    required this.ownerId,
    this.status = ServiceStatus.pending,
    required this.governorateId,
    required this.districtId,
    this.subDistrictId,
    this.verified = false,
    this.featured = false,
    this.tags = const [],
    this.tenantId,
  });

  /// التحقق من ما إذا كانت الخدمة نشطة
  bool get isActive => status == ServiceStatus.active && verified;

  /// التحقق من ما إذا كانت الخدمة مفتوحة الآن
  bool get isOpenNow => workingHours.isOpenNow();

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
    return descriptionAr;
  }

  /// الحصول على العنوان بناءً على اللغة
  String getAddress(String languageCode) {
    if (languageCode == 'en' && addressEn != null && addressEn!.isNotEmpty) {
      return addressEn!;
    }
    return addressAr;
  }

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        descriptionAr,
        descriptionEn,
        categoryId,
        addressAr,
        addressEn,
        phone,
        whatsapp,
        website,
        email,
        latitude,
        longitude,
        rating,
        reviewCount,
        favoriteCount,
        imageUrls,
        workingHours,
        isFavorite,
        createdAt,
        updatedAt,
        ownerId,
        status,
        governorateId,
        districtId,
        subDistrictId,
        verified,
        featured,
        tags,
      ];

  /// نسخ الخدمة مع تعديلات
  ServiceEntity copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? categoryId,
    String? addressAr,
    String? addressEn,
    String? phone,
    String? whatsapp,
    String? website,
    String? email,
    double? latitude,
    double? longitude,
    double? rating,
    int? reviewCount,
    int? favoriteCount,
    List<String>? imageUrls,
    WeeklyWorkingHours? workingHours,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerId,
    ServiceStatus? status,
    String? governorateId,
    String? districtId,
    String? subDistrictId,
    bool? verified,
    bool? featured,
    List<String>? tags,
  }) {
    return ServiceEntity(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      categoryId: categoryId ?? this.categoryId,
      addressAr: addressAr ?? this.addressAr,
      addressEn: addressEn ?? this.addressEn,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      website: website ?? this.website,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      imageUrls: imageUrls ?? this.imageUrls,
      workingHours: workingHours ?? this.workingHours,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      governorateId: governorateId ?? this.governorateId,
      districtId: districtId ?? this.districtId,
      subDistrictId: subDistrictId ?? this.subDistrictId,
      verified: verified ?? this.verified,
      featured: featured ?? this.featured,
      tags: tags ?? this.tags,
    );
  }
}
