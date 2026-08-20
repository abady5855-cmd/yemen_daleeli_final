import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_daleeli/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();
}

const CACHED_USER = 'CACHED_USER';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedUser() {
    final jsonString = sharedPreferences.getString(CACHED_USER);
    if (jsonString != null) {
      return Future.value(UserModel.fromJson(json.decode(jsonString)));
    }
    return Future.value(null);
  }

  @override
  Future<void> cacheUser(UserModel user) {
    return sharedPreferences.setString(CACHED_USER, json.encode(user.toJson()));
  }

  @override
  Future<void> clearCache() {
    return sharedPreferences.remove(CACHED_USER);
  }
}
