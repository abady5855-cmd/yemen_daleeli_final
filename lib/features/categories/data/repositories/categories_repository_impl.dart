import 'package:yemen_daleeli/core/errors/failures.dart';
import 'package:yemen_daleeli/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:yemen_daleeli/features/categories/data/datasources/categories_local_data_source.dart';
import 'package:yemen_daleeli/features/categories/domain/entities/category_entity.dart';
import 'package:yemen_daleeli/features/categories/domain/repositories/categories_repository.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource remoteDataSource;
  final CategoriesLocalDataSource localDataSource;

  CategoriesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<(List<CategoryEntity>?, Failure?)> getCategories() async {
    try {
      // محاولة الحصول على البيانات محلياً أولاً لسرعة الاستجابة
      final cachedCategories = await localDataSource.getCachedCategories();
      
      // جلب البيانات من السيرفر في الخلفية لتحديث الكاش (Fire and forget local return)
      // في بيئة Riverpod، الـ FutureProvider سيعرض البيانات الأولى ثم يمكن عمل invalidate
      // لتحقيق Cache-First حقيقي، سنقوم بإرجاع الكاش إذا وجد، وإلا ننتظر السيرفر
      
      if (cachedCategories.isNotEmpty) {
        // نحدث الكاش في الخلفية
        remoteDataSource.getCategories().then((remote) {
          localDataSource.cacheCategories(remote);
        }).catchError((_) {});
        
        return (cachedCategories, null);
      }

      final remoteCategories = await remoteDataSource.getCategories();
      await localDataSource.cacheCategories(remoteCategories);
      return (remoteCategories, null);
    } catch (e) {
      final cachedCategories = await localDataSource.getCachedCategories();
      if (cachedCategories.isNotEmpty) {
        return (cachedCategories, null);
      }
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(CategoryEntity?, Failure?)> getCategoryById(String id) async {
    try {
      final category = await remoteDataSource.getCategoryById(id);
      return (category, null);
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }
}
