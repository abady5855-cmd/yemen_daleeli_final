import 'package:yemen_daleeli/core/errors/failures.dart';
import 'package:yemen_daleeli/features/auth/domain/entities/user_entity.dart';
import 'package:yemen_daleeli/features/auth/domain/repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  final AuthRepository repository;
  SignInWithEmailUseCase(this.repository);

  Future<(UserEntity?, Failure?)> call(String email, String password) {
    return repository.signInWithEmail(email, password);
  }
}

class SignUpWithEmailUseCase {
  final AuthRepository repository;
  SignUpWithEmailUseCase(this.repository);

  Future<(UserEntity?, Failure?)> call(String email, String password, String displayName) {
    return repository.signUpWithEmail(email, password, displayName);
  }
}

class SignInWithGoogleUseCase {
  final AuthRepository repository;
  SignInWithGoogleUseCase(this.repository);

  Future<(UserEntity?, Failure?)> call() {
    return repository.signInWithGoogle();
  }
}

class SignInAsGuestUseCase {
  final AuthRepository repository;
  SignInAsGuestUseCase(this.repository);

  Future<(UserEntity?, Failure?)> call() {
    return repository.signInAsGuest();
  }
}

class SignOutUseCase {
  final AuthRepository repository;
  SignOutUseCase(this.repository);

  Future<Failure?> call() {
    return repository.signOut();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  UserEntity? call() {
    return repository.getCurrentUser();
  }
}

class RestoreSessionUseCase {
  final AuthRepository repository;
  RestoreSessionUseCase(this.repository);

  Future<UserEntity?> call() {
    return repository.restoreSession();
  }
}

class IsUserSignedInUseCase {
  final AuthRepository repository;
  IsUserSignedInUseCase(this.repository);

  bool call() {
    return repository.isUserSignedIn();
  }
}

class ReloadUserUseCase {
  final AuthRepository repository;
  ReloadUserUseCase(this.repository);

  Future<Failure?> call() {
    return repository.reloadUser();
  }
}

class UpdateUserProfileUseCase {
  final AuthRepository repository;
  UpdateUserProfileUseCase(this.repository);

  Future<Failure?> call(String displayName, String photoUrl) {
    return repository.updateUserProfile(displayName, photoUrl);
  }
}

class SendPasswordResetEmailUseCase {
  final AuthRepository repository;
  SendPasswordResetEmailUseCase(this.repository);

  Future<Failure?> call(String email) {
    return repository.sendPasswordResetEmail(email);
  }
}

class SendEmailVerificationUseCase {
  final AuthRepository repository;
  SendEmailVerificationUseCase(this.repository);

  Future<Failure?> call() {
    return repository.sendEmailVerification();
  }
}

class VerifyEmailUseCase {
  final AuthRepository repository;
  VerifyEmailUseCase(this.repository);

  Future<Failure?> call(String code) {
    return repository.verifyEmail(code);
  }
}
