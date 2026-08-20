import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_daleeli/features/services/data/models/governorate_model.dart';
import 'package:yemen_daleeli/features/services/data/models/district_model.dart';

abstract class LocationLocalDataSource {
  Future<List<GovernorateModel>> getCachedGovernorates();
  Future<void> cacheGovernorates(List<GovernorateModel> governorates);
  Future<List<DistrictModel>> getCachedDistricts(String governorateId);
  Future<void> cacheDistricts(String governorateId, List<DistrictModel> districts);
}

const CACHED_GOVERNORATES = 'CACHED_GOVERNORATES';
const CACHED_DISTRICTS_PREFIX = 'CACHED_DISTRICTS_';

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  final SharedPreferences sharedPreferences;

  LocationLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<GovernorateModel>> getCachedGovernorates() {
    final jsonString = sharedPreferences.getString(CACHED_GOVERNORATES);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(jsonList.map((e) => GovernorateModel.fromJson(e)).toList());
    }
    return Future.value([]);
  }

  @override
  Future<void> cacheGovernorates(List<GovernorateModel> governorates) {
    final jsonList = governorates.map((e) => e.toJson()).toList();
    return sharedPreferences.setString(CACHED_GOVERNORATES, json.encode(jsonList));
  }

  @override
  Future<List<DistrictModel>> getCachedDistricts(String governorateId) {
    final jsonString = sharedPreferences.getString(CACHED_DISTRICTS_PREFIX + governorateId);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(jsonList.map((e) => DistrictModel.fromJson(e)).toList());
    }
    return Future.value([]);
  }

  @override
  Future<void> cacheDistricts(String governorateId, List<DistrictModel> districts) {
    final jsonList = districts.map((e) => e.toJson()).toList();
    return sharedPreferences.setString(CACHED_DISTRICTS_PREFIX + governorateId, json.encode(jsonList));
  }
}
