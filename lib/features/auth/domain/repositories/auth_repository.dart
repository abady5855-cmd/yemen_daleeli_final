import 'package:yemen_daleeli/core/errors/failures.dart';
import 'package:yemen_daleeli/features/auth/domain/entities/user_entity.dart';

/// واجهة Repository للمصادقة (Auth Repository Interface)
/// تحدد العمليات المتاحة للمصادقة

abstract class AuthRepository {
  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<(UserEntity?, Failure?)> signInWithEmail(String email, String password);

  /// إنشاء حساب جديد بالبريد الإلكتروني وكلمة المرور
  Future<(UserEntity?, Failure?)> signUpWithEmail(
    String email,
    String password,
    String displayName,
  );

  /// تسجيل الدخول بحساب Google
  Future<(UserEntity?, Failure?)> signInWithGoogle();

  /// تسجيل الدخول كضيف
  Future<(UserEntity?, Failure?)> signInAsGuest();

  /// استعادة كلمة المرور
  Future<Failure?> sendPasswordResetEmail(String email);

  /// إرسال بريد التحقق من البريد الإلكتروني
  Future<Failure?> sendEmailVerification();

  /// التحقق من البريد الإلكتروني
  Future<Failure?> verifyEmail(String code);

  /// تسجيل الخروج
  Future<Failure?> signOut();

  /// الحصول على المستخدم الحالي
  UserEntity? getCurrentUser();

  /// استعادة الجلسة من الكاش
  Future<UserEntity?> restoreSession();

  /// التحقق من وجود مستخدم مسجل دخول
  bool isUserSignedIn();

  /// إعادة تحميل بيانات المستخدم
  Future<Failure?> reloadUser();

  /// تحديث البيانات الشخصية
  Future<Failure?> updateUserProfile(String displayName, String photoUrl);
}
