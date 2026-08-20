import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_daleeli/core/providers/core_providers.dart';
import 'package:yemen_daleeli/features/auth/presentation/providers/auth_providers.dart';
import 'package:yemen_daleeli/features/reviews/data/datasources/reviews_remote_data_source.dart';
import 'package:yemen_daleeli/features/reviews/data/datasources/reviews_local_data_source.dart';
import 'package:yemen_daleeli/features/reviews/data/repositories/reviews_repository_impl.dart';
import 'package:yemen_daleeli/features/reviews/domain/entities/review_entity.dart';
import 'package:yemen_daleeli/features/reviews/domain/repositories/reviews_repository.dart';
import 'package:uuid/uuid.dart';

final reviewsRemoteDataSourceProvider = Provider<ReviewsRemoteDataSource>((ref) {
  return ReviewsRemoteDataSourceImpl(firestore: ref.watch(firestoreProvider));
});

final reviewsLocalDataSourceProvider = Provider<ReviewsLocalDataSource>((ref) {
  return ReviewsLocalDataSourceImpl(sharedPreferences: ref.watch(sharedPreferencesProvider));
});

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepositoryImpl(
    remoteDataSource: ref.watch(reviewsRemoteDataSourceProvider),
    localDataSource: ref.watch(reviewsLocalDataSourceProvider),
  );
});

final serviceReviewsProvider = FutureProvider.family<List<ReviewEntity>, String>((ref, serviceId) async {
  final repository = ref.watch(reviewsRepositoryProvider);
  final (reviews, failure) = await repository.getServiceReviews(serviceId);
  if (failure != null) throw failure;
  return reviews ?? [];
});

class AddReviewNotifier extends StateNotifier<AsyncValue<void>> {
  final ReviewsRepository _repository;
  final Ref _ref;

  AddReviewNotifier(this._repository, this._ref) : super(const AsyncData(null));

  Future<void> addReview({
    required String serviceId,
    required String userId,
    required String userName,
    required double rating,
    String? comment,
  }) async {
    state = const AsyncLoading();
    
    final review = ReviewEntity(
      id: const Uuid().v4(),
      serviceId: serviceId,
      userId: userId,
      userName: userName,
      rating: rating.toInt(),
      commentAr: comment,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final failure = await _repository.addReview(review);
    
    if (failure != null) {
      state = AsyncError(failure, StackTrace.current);
    } else {
      state = const AsyncData(null);
      _ref.invalidate(serviceReviewsProvider(serviceId));
    }
  }
}

final addReviewNotifierProvider = StateNotifierProvider<AddReviewNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(reviewsRepositoryProvider);
  return AddReviewNotifier(repository, ref);
});
