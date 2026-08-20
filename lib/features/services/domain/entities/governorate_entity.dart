import 'package:equatable/equatable.dart';

class GovernorateEntity extends Equatable {
  final String id;
  final String nameAr;
  final String? nameEn;
  final String code;
  final String? descriptionAr;
  final String? descriptionEn;
  final bool isActive;

  const GovernorateEntity({
    required this.id,
    required this.nameAr,
    this.nameEn,
    required this.code,
    this.descriptionAr,
    this.descriptionEn,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, nameAr, nameEn, code, descriptionAr, descriptionEn, isActive];

  String getName(String languageCode) {
    if (languageCode == 'en' && nameEn != null && nameEn!.isNotEmpty) {
      return nameEn!;
    }
    return nameAr;
  }
}
