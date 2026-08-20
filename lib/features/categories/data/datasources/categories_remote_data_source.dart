import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_daleeli/features/categories/data/models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> getCategoryById(String id);
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  final FirebaseFirestore _firestore;

  CategoriesRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _firestore
        .collection('categories')
        .where('isDeleted', isEqualTo: false)
        .where('isActive', isEqualTo: true)
        .orderBy('name_ar')
        .get();

    return snapshot.docs
        .map((doc) => CategoryModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    final doc = await _firestore.collection('categories').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return CategoryModel.fromJson(doc.data()!);
    }
    throw Exception('التصنيف غير موجود');
  }
}
