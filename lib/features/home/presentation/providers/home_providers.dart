import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_daleeli/core/providers/core_providers.dart';
import 'package:yemen_daleeli/features/auth/presentation/providers/auth_providers.dart';
import 'package:yemen_daleeli/features/home/data/datasources/home_remote_data_source.dart';
import 'package:yemen_daleeli/features/home/data/datasources/home_local_data_source.dart';
import 'package:yemen_daleeli/features/home/data/repositories/home_repository_impl.dart';
import 'package:yemen_daleeli/features/home/domain/entities/advertisement_entity.dart';
import 'package:yemen_daleeli/features/home/domain/repositories/home_repository.dart';

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  return HomeRemoteDataSourceImpl(firestore: ref.watch(firestoreProvider));
});

final homeLocalDataSourceProvider = Provider<HomeLocalDataSource>((ref) {
  return HomeLocalDataSourceImpl(sharedPreferences: ref.watch(sharedPreferencesProvider));
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(
    remoteDataSource: ref.watch(homeRemoteDataSourceProvider),
    localDataSource: ref.watch(homeLocalDataSourceProvider),
  );
});

final activeAdvertisementsProvider = FutureProvider<List<AdvertisementEntity>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  final (ads, failure) = await repository.getActiveAdvertisements();
  if (failure != null) throw failure;
  return ads ?? [];
});
