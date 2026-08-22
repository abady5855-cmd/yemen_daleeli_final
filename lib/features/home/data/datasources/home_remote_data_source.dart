import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_daleeli/features/home/data/models/advertisement_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<AdvertisementModel>> getActiveAdvertisements();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore _firestore;

  HomeRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<List<AdvertisementModel>> getActiveAdvertisements() async {
    final now = DateTime.now();

    final snapshot = await _firestore
        .collection('advertisements')
        .where(
          'isActive',
          isEqualTo: true,
        )
        .where(
          'isDeleted',
          isEqualTo: false,
        )
        .where(
          'startDate',
          isLessThanOrEqualTo: Timestamp.fromDate(now),
        )
        .get();

    final advertisements = <AdvertisementModel>[];

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();

        final ad = AdvertisementModel.fromJson(
          data,
          documentId: doc.id,
        );

        // الإعلان يجب أن يكون غير منتهي
        if (ad.endDate.isAfter(now)) {
          advertisements.add(ad);
        }
      } catch (e) {
        // نتجاهل الإعلان التالف بدل أن يتوقف كل قسم الإعلانات
        print(
          'خطأ في قراءة الإعلان ${doc.id}: $e',
        );
      }
    }

    // الأحدث أولاً
    advertisements.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return advertisements;
  }
}
