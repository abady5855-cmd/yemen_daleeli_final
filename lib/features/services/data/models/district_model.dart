import 'package:yemen_daleeli/features/services/domain/entities/district_entity.dart';

class DistrictModel extends DistrictEntity {
  const DistrictModel({
    required super.id,
    required super.governorateId,
    required super.nameAr,
    super.nameEn,
    required super.code,
    super.isActive = true,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'] as String,
      governorateId: json['governorateId'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      code: json['code'] as String,
      isActive: json['status'] == 'Active' || (json['isActive'] as bool? ?? true),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'governorateId': governorateId,
      'name_ar': nameAr,
      'name_en': nameEn,
      'code': code,
      'status': isActive ? 'Active' : 'Inactive',
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'governorateId': governorateId,
      'name_ar': nameAr,
      'name_en': nameEn,
      'code': code,
      'isActive': isActive,
    };
  }
}
