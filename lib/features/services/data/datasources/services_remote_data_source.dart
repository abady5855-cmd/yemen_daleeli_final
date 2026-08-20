import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_daleeli/core/models/paginated_result.dart';
import 'package:yemen_daleeli/features/services/data/models/service_model.dart';

abstract class ServicesRemoteDataSource {
  Future<PaginatedResult<ServiceModel>> getServices({
    String? categoryId,
    String? governorateId,
    String? districtId,
    String? query,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  });
  Future<ServiceModel> getServiceById(String id);
  Future<void> createService(ServiceModel service);
  Future<void> updateService(ServiceModel service);
  Future<void> deleteService(String id);
  Future<List<ServiceModel>> getFavoriteServices(String userId);
  Future<void> toggleFavorite(String userId, String serviceId, bool isFavorite);
}

class ServicesRemoteDataSourceImpl implements ServicesRemoteDataSource {
  final FirebaseFirestore _firestore;

  ServicesRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<PaginatedResult<ServiceModel>> getServices({
    String? categoryId,
    String? governorateId,
    String? districtId,
    String? query,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    Query firestoreQuery = _firestore
        .collection('services')
        .where('isDeleted', isEqualTo: false)
        .where('status', isEqualTo: 'active');

    if (categoryId != null) {
      firestoreQuery = firestoreQuery.where('categoryId', isEqualTo: categoryId);
    }
    if (governorateId != null) {
      firestoreQuery = firestoreQuery.where('governorateId', isEqualTo: governorateId);
    }
    if (districtId != null) {
      firestoreQuery = firestoreQuery.where('districtId', isEqualTo: districtId);
    }

    if (query != null && query.isNotEmpty) {
      firestoreQuery = firestoreQuery
          .where('name_ar', isGreaterThanOrEqualTo: query)
          .where('name_ar', isLessThanOrEqualTo: '$query\uf8ff');
    }

    // إضافة ترتيب افتراضي لضمان عمل Pagination بشكل صحيح
    firestoreQuery = firestoreQuery.orderBy('createdAt', descending: true);

    firestoreQuery = firestoreQuery.limit(limit);

    if (lastDocument != null) {
      firestoreQuery = firestoreQuery.startAfterDocument(lastDocument);
    }

    final snapshot = await firestoreQuery.get();
    final items = snapshot.docs
        .map((doc) => ServiceModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    
    return PaginatedResult(
      items: items,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: items.length == limit,
    );
  }

  @override
  Future<ServiceModel> getServiceById(String id) async {
    final doc = await _firestore.collection('services').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return ServiceModel.fromJson(doc.data()!);
    }
    throw Exception('الخدمة غير موجودة');
  }

  @override
  Future<void> createService(ServiceModel service) async {
    await _firestore.collection('services').doc(service.id).set(service.toFirestore());
  }

  @override
  Future<void> updateService(ServiceModel service) async {
    await _firestore.collection('services').doc(service.id).update(service.toFirestore());
  }

  @override
  Future<void> deleteService(String id) async {
    await _firestore.collection('services').doc(id).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<ServiceModel>> getFavoriteServices(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();
    
    final serviceIds = snapshot.docs.map((doc) => doc.id).toList();
    
    if (serviceIds.isEmpty) return [];

    // جلب تفاصيل الخدمات المفضلة
    final servicesSnapshot = await _firestore
        .collection('services')
        .where(FieldPath.documentId, whereIn: serviceIds)
        .get();

    return servicesSnapshot.docs
        .map((doc) => ServiceModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> toggleFavorite(String userId, String serviceId, bool isFavorite) async {
    final favoriteDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(serviceId);

    if (isFavorite) {
      await favoriteDoc.set({
        'createdAt': FieldValue.serverTimestamp(),
      });
      // تحديث عداد المفضلة في الخدمة (يُفضل عبر Cloud Functions ولكن سنضعه هنا مؤقتاً)
      await _firestore.collection('services').doc(serviceId).update({
        'favoriteCount': FieldValue.increment(1),
      });
    } else {
      await favoriteDoc.delete();
      await _firestore.collection('services').doc(serviceId).update({
        'favoriteCount': FieldValue.increment(-1),
      });
    }
  }
}
