import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_daleeli/features/home/data/models/advertisement_model.dart';

abstract class HomeLocalDataSource {
  Future<List<AdvertisementModel>> getCachedAds();
  Future<void> cacheAds(List<AdvertisementModel> ads);
}

const CACHED_ADS = 'CACHED_ADS';

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final SharedPreferences sharedPreferences;

  HomeLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<AdvertisementModel>> getCachedAds() {
    final jsonString = sharedPreferences.getString(CACHED_ADS);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(jsonList.map((e) => AdvertisementModel.fromJson(e)).toList());
    }
    return Future.value([]);
  }

  @override
  Future<void> cacheAds(List<AdvertisementModel> ads) {
    final jsonList = ads.map((e) => e.toJson()).toList();
    return sharedPreferences.setString(CACHED_ADS, json.encode(jsonList));
  }
}
