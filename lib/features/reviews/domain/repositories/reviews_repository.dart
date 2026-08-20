import 'package:yemen_daleeli/core/errors/failures.dart';
import 'package:yemen_daleeli/features/reviews/domain/entities/review_entity.dart';

abstract class ReviewsRepository {
  Future<(List<ReviewEntity>?, Failure?)> getServiceReviews(String serviceId);
  Future<Failure?> addReview(ReviewEntity review);
  Future<Failure?> updateReview(ReviewEntity review);
  Future<Failure?> deleteReview(String reviewId);
}
