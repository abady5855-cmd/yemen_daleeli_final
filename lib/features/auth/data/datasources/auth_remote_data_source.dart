import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yemen_daleeli/features/auth/data/models/user_model.dart';
import 'package:yemen_daleeli/features/auth/domain/entities/user_entity.dart';

/// مصدر البيانات البعيد للمصادقة (Auth Remote Data Source)
/// يتعامل مع عمليات Firebase Authentication و Firestore
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password, String displayName);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInAsGuest();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<void> signOut();
  UserModel? getCurrentUser();
  Future<UserModel?> getUserData(String userId);
  Future<void> saveUserData(UserModel user);
  bool isUserSignedIn();
  Future<void> reloadUser();
  Future<void> updateUserProfile(String displayName, String photoUrl);
}

/// تنفيذ مصدر البيانات البعيد للمصادقة
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final userData = await getUserData(userCredential.user!.uid);
      if (userData != null) return userData;
      
      return _userToUserModel(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.sendEmailVerification();

      final userModel = _userToUserModel(userCredential.user!);
      await saveUserData(userModel);
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('تم إلغاء تسجيل الدخول');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      final existingData = await getUserData(userCredential.user!.uid);
      if (existingData != null) return existingData;
      
      final newUser = _userToUserModel(userCredential.user!);
      await saveUserData(newUser);
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserModel> signInAsGuest() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      return _userToUserModel(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> sendEmailVerification() async {
    await _firebaseAuth.currentUser?.sendEmailVerification();
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  UserModel? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return _userToUserModel(user);
  }

  @override
  Future<UserModel?> getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> saveUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toFirestore());
  }

  @override
  bool isUserSignedIn() => _firebaseAuth.currentUser != null;

  @override
  Future<void> reloadUser() async => await _firebaseAuth.currentUser?.reload();

  @override
  Future<void> updateUserProfile(String displayName, String photoUrl) async {
    await _firebaseAuth.currentUser?.updateDisplayName(displayName);
    await _firebaseAuth.currentUser?.updatePhotoURL(photoUrl);
    
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('users').doc(uid).update({
        'fullName': displayName,
        'profileImageUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  UserModel _userToUserModel(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      fullName: user.displayName ?? '',
      profileImageUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      role: user.isAnonymous ? UserRole.guest : UserRole.user,
      isActive: true,
      updatedAt: DateTime.now(),
    );
  }

  Exception _handleAuthException(FirebaseAuthException e) {
    return Exception(e.message ?? 'حدث خطأ غير متوقع في المصادقة');
  }
}
