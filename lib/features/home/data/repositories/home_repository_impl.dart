import 'package:yemen_daleeli/core/errors/failures.dart';
import 'package:yemen_daleeli/features/home/data/datasources/home_remote_data_source.dart';
import 'package:yemen_daleeli/features/home/data/datasources/home_local_data_source.dart';
import 'package:yemen_daleeli/features/home/domain/entities/advertisement_entity.dart';
import 'package:yemen_daleeli/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<(List<AdvertisementEntity>?, Failure?)> getActiveAdvertisements() async {
    try {
      final cachedAds = await localDataSource.getCachedAds();
      
      if (cachedAds.isNotEmpty) {
        // تحديث في الخلفية
        remoteDataSource.getActiveAdvertisements().then((remote) {
          localDataSource.cacheAds(remote);
        }).catchError((_) {});
        
        return (cachedAds, null);
      }

      final remoteAds = await remoteDataSource.getActiveAdvertisements();
      await localDataSource.cacheAds(remoteAds);
      return (remoteAds, null);
    } catch (e) {
      final cached = await localDataSource.getCachedAds();
      if (cached.isNotEmpty) return (cached, null);
      return (null, ServerFailure(message: e.toString()));
    }
  }
}
