import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_daleeli/core/providers/core_providers.dart';
import 'package:yemen_daleeli/features/auth/presentation/providers/auth_providers.dart';
import 'package:yemen_daleeli/features/services/data/datasources/location_remote_data_source.dart';
import 'package:yemen_daleeli/features/services/data/datasources/location_local_data_source.dart';
import 'package:yemen_daleeli/features/services/data/repositories/location_repository_impl.dart';
import 'package:yemen_daleeli/features/services/domain/entities/governorate_entity.dart';
import 'package:yemen_daleeli/features/services/domain/entities/district_entity.dart';
import 'package:yemen_daleeli/features/services/domain/repositories/location_repository.dart';

final locationRemoteDataSourceProvider = Provider<LocationRemoteDataSource>((ref) {
  return LocationRemoteDataSourceImpl(firestore: ref.watch(firestoreProvider));
});

final locationLocalDataSourceProvider = Provider<LocationLocalDataSource>((ref) {
  return LocationLocalDataSourceImpl(sharedPreferences: ref.watch(sharedPreferencesProvider));
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(
    remoteDataSource: ref.watch(locationRemoteDataSourceProvider),
    localDataSource: ref.watch(locationLocalDataSourceProvider),
  );
});

final governoratesProvider = FutureProvider<List<GovernorateEntity>>((ref) async {
  final repository = ref.watch(locationRepositoryProvider);
  final (governorates, failure) = await repository.getGovernorates();
  if (failure != null) throw failure;
  return governorates ?? [];
});

final districtsProvider = FutureProvider.family<List<DistrictEntity>, String>((ref, governorateId) async {
  final repository = ref.watch(locationRepositoryProvider);
  final (districts, failure) = await repository.getDistricts(governorateId);
  if (failure != null) throw failure;
  return districts ?? [];
});
