import 'package:yemen_daleeli/core/errors/failures.dart';
import 'package:yemen_daleeli/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:yemen_daleeli/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:yemen_daleeli/features/auth/data/models/user_model.dart';
import 'package:yemen_daleeli/features/auth/domain/entities/user_entity.dart';
import 'package:yemen_daleeli/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<(UserEntity?, Failure?)> signInWithEmail(String email, String password) async {
    try {
      final user = await remoteDataSource.signInWithEmail(email, password);
      await localDataSource.cacheUser(user as UserModel);
      return (user, null);
    } catch (e) {
      return (null, _handleException(e));
    }
  }

  @override
  Future<(UserEntity?, Failure?)> signUpWithEmail(String email, String password, String displayName) async {
    try {
      final user = await remoteDataSource.signUpWithEmail(email, password, displayName);
      await localDataSource.cacheUser(user as UserModel);
      return (user, null);
    } catch (e) {
      return (null, _handleException(e));
    }
  }

  @override
  Future<(UserEntity?, Failure?)> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      await localDataSource.cacheUser(user as UserModel);
      return (user, null);
    } catch (e) {
      return (null, _handleException(e));
    }
  }

  @override
  Future<(UserEntity?, Failure?)> signInAsGuest() async {
    try {
      final user = await remoteDataSource.signInAsGuest();
      await localDataSource.cacheUser(user as UserModel);
      return (user, null);
    } catch (e) {
      return (null, _handleException(e));
    }
  }

  @override
  Future<Failure?> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return null;
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Failure?> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
      return null;
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Failure?> verifyEmail(String code) async {
    try {
      // Logic for verification
      return null;
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Failure?> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCache();
      return null;
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  UserEntity? getCurrentUser() {
    // نحاول الحصول عليه من الذاكرة أولاً
    final user = remoteDataSource.getCurrentUser();
    return user;
  }

  Future<UserEntity?> restoreSession() async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        // إذا وجدنا مستخدماً في الكاش، نتحقق من حالته في Firebase
        if (remoteDataSource.isUserSignedIn()) {
          return remoteDataSource.getCurrentUser();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  bool isUserSignedIn() {
    return remoteDataSource.isUserSignedIn();
  }

  @override
  Future<Failure?> reloadUser() async {
    try {
      await remoteDataSource.reloadUser();
      final user = remoteDataSource.getCurrentUser();
      if (user != null) {
        await localDataSource.cacheUser(user as UserModel);
      }
      return null;
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Failure?> updateUserProfile(String displayName, String photoUrl) async {
    try {
      await remoteDataSource.updateUserProfile(displayName, photoUrl);
      final user = remoteDataSource.getCurrentUser();
      if (user != null) {
        await localDataSource.cacheUser(user as UserModel);
      }
      return null;
    } catch (e) {
      return _handleException(e);
    }
  }

  Failure _handleException(dynamic e) {
    if (e is Exception) {
      return AuthFailure(message: e.toString().replaceAll('Exception: ', ''));
    }
    return AuthFailure(message: 'حدث خطأ غير متوقع');
  }
}
