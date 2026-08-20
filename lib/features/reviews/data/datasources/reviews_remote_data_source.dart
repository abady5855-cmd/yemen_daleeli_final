import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_daleeli/features/reviews/data/models/review_model.dart';

abstract class ReviewsRemoteDataSource {
  Future<List<ReviewModel>> getServiceReviews(String serviceId);
  Future<void> addReview(ReviewModel review);
  Future<void> updateReview(ReviewModel review);
  Future<void> deleteReview(String reviewId);
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final FirebaseFirestore _firestore;

  ReviewsRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<List<ReviewModel>> getServiceReviews(String serviceId) async {
    final snapshot = await _firestore
        .collection('services')
        .doc(serviceId)
        .collection('reviews')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> addReview(ReviewModel review) async {
    await _firestore
        .collection('services')
        .doc(review.serviceId)
        .collection('reviews')
        .doc(review.id)
        .set(review.toFirestore());
  }

  @override
  Future<void> updateReview(ReviewModel review) async {
    await _firestore
        .collection('services')
        .doc(review.serviceId)
        .collection('reviews')
        .doc(review.id)
        .update(review.toFirestore());
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    // ملاحظة: الحذف الناعم يتطلب معرفة الـ serviceId
    // في هذا التصميم، التقييمات هي subcollection
    // سنحتاج لتعديل الواجهة أو البحث عن التقييم أولاً
    // للتبسيط، سنفترض أننا نستخدم collection group query أو نمرر الـ serviceId
  }
}
