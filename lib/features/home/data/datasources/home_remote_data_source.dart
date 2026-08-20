import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_daleeli/features/home/data/models/advertisement_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<AdvertisementModel>> getActiveAdvertisements();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore _firestore;

  HomeRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<List<AdvertisementModel>> getActiveAdvertisements() async {
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection('advertisements')
        .where('isActive', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .get();

    // الفلترة لـ endDate تتم في الكود لأن Firestore لا يدعم فلترة حقلين مختلفين بعدم المساواة بسهولة بدون فهارس مركبة معقدة
    return snapshot.docs
        .map((doc) => AdvertisementModel.fromJson(doc.data()))
        .where((ad) => ad.endDate.isAfter(now))
        .toList();
  }
}
