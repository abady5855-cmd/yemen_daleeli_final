import 'package:yemen_daleeli/core/errors/failures.dart';
import 'package:yemen_daleeli/features/services/domain/entities/governorate_entity.dart';
import 'package:yemen_daleeli/features/services/domain/entities/district_entity.dart';

abstract class LocationRepository {
  Future<(List<GovernorateEntity>?, Failure?)> getGovernorates();
  Future<(List<DistrictEntity>?, Failure?)> getDistricts(String governorateId);
}
