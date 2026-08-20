import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_daleeli/features/reviews/data/models/review_model.dart';

abstract class ReviewsLocalDataSource {
  Future<List<ReviewModel>> getCachedReviews(String serviceId);
  Future<void> cacheReviews(String serviceId, List<ReviewModel> reviews);
}

const CACHED_REVIEWS_PREFIX = 'CACHED_REVIEWS_';

class ReviewsLocalDataSourceImpl implements ReviewsLocalDataSource {
  final SharedPreferences sharedPreferences;

  ReviewsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<ReviewModel>> getCachedReviews(String serviceId) {
    final jsonString = sharedPreferences.getString(CACHED_REVIEWS_PREFIX + serviceId);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(jsonList.map((e) => ReviewModel.fromJson(e)).toList());
    }
    return Future.value([]);
  }

  @override
  Future<void> cacheReviews(String serviceId, List<ReviewModel> reviews) {
    final jsonList = reviews.map((e) => e.toJson()).toList();
    return sharedPreferences.setString(CACHED_REVIEWS_PREFIX + serviceId, json.encode(jsonList));
  }
}
