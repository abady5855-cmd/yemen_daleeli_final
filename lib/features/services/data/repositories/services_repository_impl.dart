import 'package:yemen_daleeli/core/errors/failures.dart';
import 'package:yemen_daleeli/features/services/data/datasources/services_remote_data_source.dart';
import 'package:yemen_daleeli/features/services/data/datasources/services_local_data_source.dart';
import 'package:yemen_daleeli/features/services/data/models/service_model.dart';
import 'package:yemen_daleeli/features/services/domain/entities/service_entity.dart';
import 'package:yemen_daleeli/features/services/domain/repositories/services_repository.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource remoteDataSource;
  final ServicesLocalDataSource localDataSource;

  ServicesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<(PaginatedResult<ServiceEntity>?, Failure?)> getServices({
    String? categoryId,
    String? governorateId,
    String? districtId,
    String? query,
    int limit = 20,
    dynamic lastDocument,
  }) async {
    try {
      // استراتيجية Cache-First (فقط للصفحة الأولى والبحث العام)
      if (categoryId == null && governorateId == null && query == null && lastDocument == null) {
        final cached = await localDataSource.getLastServices();
        if (cached.isNotEmpty) {
          // تحديث في الخلفية
          remoteDataSource.getServices(limit: limit).then((remote) {
            localDataSource.cacheServices(remote.items);
          }).catchError((_) {});
          
          return (PaginatedResult(items: cached, hasMore: true), null);
        }
      }

      final remoteResult = await remoteDataSource.getServices(
        categoryId: categoryId,
        governorateId: governorateId,
        districtId: districtId,
        query: query,
        limit: limit,
        lastDocument: lastDocument,
      );
      
      if (categoryId == null && governorateId == null && query == null && lastDocument == null) {
        await localDataSource.cacheServices(remoteResult.items);
      }
      
      return (remoteResult, null);
    } catch (e) {
      if (lastDocument == null) {
        final cached = await localDataSource.getLastServices();
        if (cached.isNotEmpty && categoryId == null && governorateId == null) {
          return (PaginatedResult(items: cached, hasMore: false), null);
        }
      }
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(ServiceEntity?, Failure?)> getServiceById(String id) async {
    try {
      final service = await remoteDataSource.getServiceById(id);
      return (service, null);
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> createService(ServiceEntity service) async {
    try {
      await remoteDataSource.createService(ServiceModel.fromEntity(service));
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> updateService(ServiceEntity service) async {
    try {
      await remoteDataSource.updateService(ServiceModel.fromEntity(service));
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> deleteService(String id) async {
    try {
      await remoteDataSource.deleteService(id);
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> restoreService(String id) async {
    try {
      // Logic for restoration can be added here if needed
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<(List<ServiceEntity>?, Failure?)> getFavoriteServices(String userId) async {
    try {
      final remoteFavorites = await remoteDataSource.getFavoriteServices(userId);
      await localDataSource.cacheFavoriteServices(remoteFavorites);
      return (remoteFavorites, null);
    } catch (e) {
      final cached = await localDataSource.getFavoriteServices();
      if (cached.isNotEmpty) {
        return (cached, null);
      }
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> toggleFavorite(String userId, String serviceId, bool isFavorite) async {
    try {
      await remoteDataSource.toggleFavorite(userId, serviceId, isFavorite);
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }
}
