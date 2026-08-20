import 'package:equatable/equatable.dart';

class DistrictEntity extends Equatable {
  final String id;
  final String governorateId;
  final String nameAr;
  final String? nameEn;
  final String code;
  final bool isActive;

  const DistrictEntity({
    required this.id,
    required this.governorateId,
    required this.nameAr,
    this.nameEn,
    required this.code,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, governorateId, nameAr, nameEn, code, isActive];

  String getName(String languageCode) {
    if (languageCode == 'en' && nameEn != null && nameEn!.isNotEmpty) {
      return nameEn!;
    }
    return nameAr;
  }
}
