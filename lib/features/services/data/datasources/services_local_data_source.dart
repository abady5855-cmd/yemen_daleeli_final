import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_daleeli/features/services/data/models/service_model.dart';

abstract class ServicesLocalDataSource {
  Future<List<ServiceModel>> getLastServices();
  Future<void> cacheServices(List<ServiceModel> services);
  Future<List<ServiceModel>> getFavoriteServices();
  Future<void> cacheFavoriteServices(List<ServiceModel> services);
}

const CACHED_SERVICES = 'CACHED_SERVICES';
const CACHED_FAVORITES = 'CACHED_FAVORITES';

class ServicesLocalDataSourceImpl implements ServicesLocalDataSource {
  final SharedPreferences sharedPreferences;

  ServicesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<ServiceModel>> getLastServices() {
    final jsonString = sharedPreferences.getString(CACHED_SERVICES);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(jsonList.map((e) => ServiceModel.fromJson(e)).toList());
    } else {
      return Future.value([]);
    }
  }

  @override
  Future<void> cacheServices(List<ServiceModel> services) {
    final jsonList = services.map((e) => e.toJson()).toList();
    return sharedPreferences.setString(CACHED_SERVICES, json.encode(jsonList));
  }

  @override
  Future<List<ServiceModel>> getFavoriteServices() {
    final jsonString = sharedPreferences.getString(CACHED_FAVORITES);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(jsonList.map((e) => ServiceModel.fromJson(e)).toList());
    } else {
      return Future.value([]);
    }
  }

  @override
  Future<void> cacheFavoriteServices(List<ServiceModel> services) {
    final jsonList = services.map((e) => e.toJson()).toList();
    return sharedPreferences.setString(CACHED_FAVORITES, json.encode(jsonList));
  }
}
