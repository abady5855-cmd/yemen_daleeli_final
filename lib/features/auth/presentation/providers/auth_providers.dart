import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_daleeli/core/providers/core_providers.dart';
import 'package:yemen_daleeli/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:yemen_daleeli/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:yemen_daleeli/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yemen_daleeli/features/auth/domain/entities/user_entity.dart';
import 'package:yemen_daleeli/features/auth/domain/repositories/auth_repository.dart';
import 'package:yemen_daleeli/features/auth/domain/usecases/auth_usecases.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(sharedPreferences: ref.watch(sharedPreferencesProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

// UseCases
final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) => SignInWithEmailUseCase(ref.watch(authRepositoryProvider)));
final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmailUseCase>((ref) => SignUpWithEmailUseCase(ref.watch(authRepositoryProvider)));
final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) => SignInWithGoogleUseCase(ref.watch(authRepositoryProvider)));
final signInAsGuestUseCaseProvider = Provider<SignInAsGuestUseCase>((ref) => SignInAsGuestUseCase(ref.watch(authRepositoryProvider)));
final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) => SignOutUseCase(ref.watch(authRepositoryProvider)));
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)));
final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>((ref) => RestoreSessionUseCase(ref.watch(authRepositoryProvider)));

class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInAsGuestUseCase _signInAsGuestUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final RestoreSessionUseCase _restoreSessionUseCase;

  AuthNotifier({
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required SignUpWithEmailUseCase signUpWithEmailUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInAsGuestUseCase signInAsGuestUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required RestoreSessionUseCase restoreSessionUseCase,
  })  : _signInWithEmailUseCase = signInWithEmailUseCase,
        _signUpWithEmailUseCase = signUpWithEmailUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _signInAsGuestUseCase = signInAsGuestUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _restoreSessionUseCase = restoreSessionUseCase,
        super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final user = await _restoreSessionUseCase();
    state = AsyncValue.data(user);
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    final (user, failure) = await _signInWithEmailUseCase(email, password);
    if (failure != null) state = AsyncValue.error(failure, StackTrace.current);
    else state = AsyncValue.data(user);
  }

  Future<void> signUpWithEmail(String email, String password, String displayName) async {
    state = const AsyncValue.loading();
    final (user, failure) = await _signUpWithEmailUseCase(email, password, displayName);
    if (failure != null) state = AsyncValue.error(failure, StackTrace.current);
    else state = AsyncValue.data(user);
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final (user, failure) = await _signInWithGoogleUseCase();
    if (failure != null) state = AsyncValue.error(failure, StackTrace.current);
    else state = AsyncValue.data(user);
  }

  Future<void> signInAsGuest() async {
    state = const AsyncValue.loading();
    final (user, failure) = await _signInAsGuestUseCase();
    if (failure != null) state = AsyncValue.error(failure, StackTrace.current);
    else state = AsyncValue.data(user);
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final failure = await _signOutUseCase();
    if (failure != null) state = AsyncValue.error(failure, StackTrace.current);
    else state = AsyncValue.data(null);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(
    signInWithEmailUseCase: ref.watch(signInWithEmailUseCaseProvider),
    signUpWithEmailUseCase: ref.watch(signUpWithEmailUseCaseProvider),
    signInWithGoogleUseCase: ref.watch(signInWithGoogleUseCaseProvider),
    signInAsGuestUseCase: ref.watch(signInAsGuestUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
    restoreSessionUseCase: ref.watch(restoreSessionUseCaseProvider),
  );
});
