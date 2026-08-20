import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_daleeli/features/categories/data/models/category_model.dart';

abstract class CategoriesLocalDataSource {
  Future<List<CategoryModel>> getCachedCategories();
  Future<void> cacheCategories(List<CategoryModel> categories);
}

const CACHED_CATEGORIES = 'CACHED_CATEGORIES';

class CategoriesLocalDataSourceImpl implements CategoriesLocalDataSource {
  final SharedPreferences sharedPreferences;

  CategoriesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CategoryModel>> getCachedCategories() {
    final jsonString = sharedPreferences.getString(CACHED_CATEGORIES);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(jsonList.map((e) => CategoryModel.fromJson(e)).toList());
    }
    return Future.value([]);
  }

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) {
    final jsonList = categories.map((e) => e.toJson()).toList();
    return sharedPreferences.setString(CACHED_CATEGORIES, json.encode(jsonList));
  }
}
