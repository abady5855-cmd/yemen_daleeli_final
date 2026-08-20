import 'package:yemen_daleeli/features/services/domain/entities/governorate_entity.dart';

class GovernorateModel extends GovernorateEntity {
  const GovernorateModel({
    required super.id,
    required super.nameAr,
    super.nameEn,
    required super.code,
    super.descriptionAr,
    super.descriptionEn,
    super.isActive = true,
  });

  factory GovernorateModel.fromJson(Map<String, dynamic> json) {
    return GovernorateModel(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      code: json['code'] as String,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      isActive: json['status'] == 'Active' || (json['isActive'] as bool? ?? true),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'code': code,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'status': isActive ? 'Active' : 'Inactive',
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'code': code,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'isActive': isActive,
    };
  }
}
