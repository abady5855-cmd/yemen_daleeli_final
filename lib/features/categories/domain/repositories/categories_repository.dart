import 'package:yemen_daleeli/core/errors/failures.dart';
import 'package:yemen_daleeli/features/categories/domain/entities/category_entity.dart';

abstract class CategoriesRepository {
  Future<(List<CategoryEntity>?, Failure?)> getCategories();
  Future<(CategoryEntity?, Failure?)> getCategoryById(String id);
}
