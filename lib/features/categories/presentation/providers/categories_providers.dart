import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_daleeli/core/providers/core_providers.dart';
import 'package:yemen_daleeli/features/auth/presentation/providers/auth_providers.dart';
import 'package:yemen_daleeli/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:yemen_daleeli/features/categories/data/datasources/categories_local_data_source.dart';
import 'package:yemen_daleeli/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:yemen_daleeli/features/categories/domain/entities/category_entity.dart';
import 'package:yemen_daleeli/features/categories/domain/repositories/categories_repository.dart';

final categoriesRemoteDataSourceProvider = Provider<CategoriesRemoteDataSource>((ref) {
  return CategoriesRemoteDataSourceImpl(firestore: ref.watch(firestoreProvider));
});

final categoriesLocalDataSourceProvider = Provider<CategoriesLocalDataSource>((ref) {
  return CategoriesLocalDataSourceImpl(sharedPreferences: ref.watch(sharedPreferencesProvider));
});

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepositoryImpl(
    remoteDataSource: ref.watch(categoriesRemoteDataSourceProvider),
    localDataSource: ref.watch(categoriesLocalDataSourceProvider),
  );
});

final categoriesProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final repository = ref.watch(categoriesRepositoryProvider);
  final (categories, failure) = await repository.getCategories();
  if (failure != null) throw failure;
  return categories ?? [];
});
