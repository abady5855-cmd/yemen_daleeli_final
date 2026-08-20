import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_daleeli/core/providers/core_providers.dart';
import 'package:yemen_daleeli/features/auth/presentation/providers/auth_providers.dart';
import 'package:yemen_daleeli/features/services/data/datasources/services_remote_data_source.dart';
import 'package:yemen_daleeli/features/services/data/datasources/services_local_data_source.dart';
import 'package:yemen_daleeli/features/services/data/repositories/services_repository_impl.dart';
import 'package:yemen_daleeli/features/services/domain/entities/service_entity.dart';
import 'package:yemen_daleeli/features/services/domain/repositories/services_repository.dart';

final servicesRemoteDataSourceProvider = Provider<ServicesRemoteDataSource>((ref) {
  return ServicesRemoteDataSourceImpl(firestore: ref.watch(firestoreProvider));
});

final servicesLocalDataSourceProvider = Provider<ServicesLocalDataSource>((ref) {
  return ServicesLocalDataSourceImpl(sharedPreferences: ref.watch(sharedPreferencesProvider));
});

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepositoryImpl(
    remoteDataSource: ref.watch(servicesRemoteDataSourceProvider),
    localDataSource: ref.watch(servicesLocalDataSourceProvider),
  );
});

class PaginatedServicesState {
  final List<ServiceEntity> items;
  final bool isLoading;
  final bool isLoadingMore;
  final dynamic lastDocument;
  final bool hasMore;
  final String? error;

  PaginatedServicesState({
    required this.items,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.lastDocument,
    this.hasMore = true,
    this.error,
  });

  PaginatedServicesState copyWith({
    List<ServiceEntity>? items,
    bool? isLoading,
    bool? isLoadingMore,
    dynamic lastDocument,
    bool? hasMore,
    String? error,
  }) {
    return PaginatedServicesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      lastDocument: lastDocument ?? this.lastDocument,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class PaginatedServicesNotifier extends StateNotifier<PaginatedServicesState> {
  final ServicesRepository _repository;
  final Map<String, dynamic> _params;

  PaginatedServicesNotifier(this._repository, this._params)
      : super(PaginatedServicesState(items: [])) {
    fetchInitial();
  }

  Future<void> fetchInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    final (result, failure) = await _repository.getServices(
      categoryId: _params['categoryId'],
      governorateId: _params['governorateId'],
      districtId: _params['districtId'],
      query: _params['query'],
      limit: 10,
    );

    if (failure != null) {
      state = state.copyWith(isLoading: false, error: failure.message);
    } else if (result != null) {
      state = state.copyWith(
        isLoading: false,
        items: result.items,
        lastDocument: result.lastDocument,
        hasMore: result.hasMore,
      );
    }
  }

  Future<void> fetchMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    final (result, failure) = await _repository.getServices(
      categoryId: _params['categoryId'],
      governorateId: _params['governorateId'],
      districtId: _params['districtId'],
      query: _params['query'],
      limit: 10,
      lastDocument: state.lastDocument,
    );

    if (failure != null) {
      state = state.copyWith(isLoadingMore: false, error: failure.message);
    } else if (result != null) {
      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...result.items],
        lastDocument: result.lastDocument,
        hasMore: result.hasMore,
      );
    }
  }
}

final paginatedServicesProvider = StateNotifierProvider.family<PaginatedServicesNotifier, PaginatedServicesState, Map<String, dynamic>>((ref, params) {
  final repository = ref.watch(servicesRepositoryProvider);
  return PaginatedServicesNotifier(repository, params);
});

final serviceDetailProvider = FutureProvider.family<ServiceEntity, String>((ref, id) async {
  final repository = ref.watch(servicesRepositoryProvider);
  final (service, failure) = await repository.getServiceById(id);
  if (failure != null) throw failure;
  return service!;
});

final favoriteServicesProvider = FutureProvider<List<ServiceEntity>>((ref) async {
  final user = ref.watch(authNotifierProvider).value;
  if (user == null) return [];
  
  final repository = ref.watch(servicesRepositoryProvider);
  final (services, failure) = await repository.getFavoriteServices(user.id);
  if (failure != null) throw failure;
  return services ?? [];
});

class FavoriteNotifier extends StateNotifier<Set<String>> {
  final ServicesRepository _repository;
  final String? _userId;
  final Ref _ref;

  FavoriteNotifier(this._repository, this._userId, this._ref) : super({});

  void toggleFavorite(String serviceId, bool currentStatus) async {
    if (_userId == null) return;

    // Optimistic UI update
    if (currentStatus) {
      state = {...state}..remove(serviceId);
    } else {
      state = {...state}..add(serviceId);
    }

    final failure = await _repository.toggleFavorite(_userId!, serviceId, !currentStatus);
    
    if (failure != null) {
      // Revert on failure
      if (currentStatus) {
        state = {...state}..add(serviceId);
      } else {
        state = {...state}..remove(serviceId);
      }
    } else {
      // Refresh favorites list
      _ref.invalidate(favoriteServicesProvider);
    }
  }

  void setFavorites(List<String> ids) {
    state = ids.toSet();
  }
}

final favoriteNotifierProvider = StateNotifierProvider<FavoriteNotifier, Set<String>>((ref) {
  final repository = ref.watch(servicesRepositoryProvider);
  final user = ref.watch(authNotifierProvider).value;
  final notifier = FavoriteNotifier(repository, user?.id, ref);
  
  // Initialize with current favorites if available
  ref.listen(favoriteServicesProvider, (previous, next) {
    next.whenData((services) {
      notifier.setFavorites(services.map((e) => e.id).toList());
    });
  });
  
  return notifier;
});
