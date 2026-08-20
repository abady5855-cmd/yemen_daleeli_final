import 'package:yemen_daleeli/core/errors/failures.dart';
import 'package:yemen_daleeli/core/models/paginated_result.dart';
import 'package:yemen_daleeli/features/services/domain/entities/service_entity.dart';

abstract class ServicesRepository {
  Future<(PaginatedResult<ServiceEntity>?, Failure?)> getServices({
    String? categoryId,
    String? governorateId,
    String? districtId,
    String? query,
    int limit = 20,
    dynamic lastDocument,
  });
  Future<(ServiceEntity?, Failure?)> getServiceById(String id);
  Future<Failure?> createService(ServiceEntity service);
  Future<Failure?> updateService(ServiceEntity service);
  Future<Failure?> deleteService(String id);
  Future<Failure?> restoreService(String id);
  Future<(List<ServiceEntity>?, Failure?)> getFavoriteServices(String userId);
  Future<Failure?> toggleFavorite(String userId, String serviceId, bool isFavorite);
}
