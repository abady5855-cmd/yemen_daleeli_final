import 'package:yemen_daleeli/core/errors/failures.dart';
import 'package:yemen_daleeli/features/home/domain/entities/advertisement_entity.dart';

abstract class HomeRepository {
  Future<(List<AdvertisementEntity>?, Failure?)> getActiveAdvertisements();
}
