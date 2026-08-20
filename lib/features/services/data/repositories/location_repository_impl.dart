import 'package:yemen_daleeli/core/errors/failures.dart';
import 'package:yemen_daleeli/features/services/data/datasources/location_remote_data_source.dart';
import 'package:yemen_daleeli/features/services/data/datasources/location_local_data_source.dart';
import 'package:yemen_daleeli/features/services/domain/entities/governorate_entity.dart';
import 'package:yemen_daleeli/features/services/domain/entities/district_entity.dart';
import 'package:yemen_daleeli/features/services/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;
  final LocationLocalDataSource localDataSource;

  LocationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<(List<GovernorateEntity>?, Failure?)> getGovernorates() async {
    try {
      final remoteGovernorates = await remoteDataSource.getGovernorates();
      await localDataSource.cacheGovernorates(remoteGovernorates);
      return (remoteGovernorates, null);
    } catch (e) {
      final cached = await localDataSource.getCachedGovernorates();
      if (cached.isNotEmpty) return (cached, null);
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<DistrictEntity>?, Failure?)> getDistricts(String governorateId) async {
    try {
      final remoteDistricts = await remoteDataSource.getDistricts(governorateId);
      await localDataSource.cacheDistricts(governorateId, remoteDistricts);
      return (remoteDistricts, null);
    } catch (e) {
      final cached = await localDataSource.getCachedDistricts(governorateId);
      if (cached.isNotEmpty) return (cached, null);
      return (null, ServerFailure(message: e.toString()));
    }
  }
}
