import 'package:yemen_daleeli/core/errors/failures.dart';
import 'package:yemen_daleeli/features/reviews/data/datasources/reviews_remote_data_source.dart';
import 'package:yemen_daleeli/features/reviews/data/datasources/reviews_local_data_source.dart';
import 'package:yemen_daleeli/features/reviews/data/models/review_model.dart';
import 'package:yemen_daleeli/features/reviews/domain/entities/review_entity.dart';
import 'package:yemen_daleeli/features/reviews/domain/repositories/reviews_repository.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDataSource remoteDataSource;
  final ReviewsLocalDataSource localDataSource;

  ReviewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<(List<ReviewEntity>?, Failure?)> getServiceReviews(String serviceId) async {
    try {
      final remoteReviews = await remoteDataSource.getServiceReviews(serviceId);
      await localDataSource.cacheReviews(serviceId, remoteReviews);
      return (remoteReviews, null);
    } catch (e) {
      final cached = await localDataSource.getCachedReviews(serviceId);
      if (cached.isNotEmpty) return (cached, null);
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> addReview(ReviewEntity review) async {
    try {
      await remoteDataSource.addReview(ReviewModel.fromEntity(review));
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> updateReview(ReviewEntity review) async {
    try {
      await remoteDataSource.updateReview(ReviewModel.fromEntity(review));
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> deleteReview(String reviewId) async {
    try {
      await remoteDataSource.deleteReview(reviewId);
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }
}
