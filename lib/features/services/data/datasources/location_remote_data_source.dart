import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_daleeli/features/services/data/models/governorate_model.dart';
import 'package:yemen_daleeli/features/services/data/models/district_model.dart';

abstract class LocationRemoteDataSource {
  Future<List<GovernorateModel>> getGovernorates();
  Future<List<DistrictModel>> getDistricts(String governorateId);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final FirebaseFirestore _firestore;

  LocationRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<List<GovernorateModel>> getGovernorates() async {
    final snapshot = await _firestore
        .collection('governorates')
        .where('status', isEqualTo: 'Active')
        .orderBy('name_ar')
        .get();

    return snapshot.docs
        .map((doc) => GovernorateModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<DistrictModel>> getDistricts(String governorateId) async {
    final snapshot = await _firestore
        .collection('governorates')
        .doc(governorateId)
        .collection('districts')
        .where('status', isEqualTo: 'Active')
        .orderBy('name_ar')
        .get();

    return snapshot.docs
        .map((doc) => DistrictModel.fromJson(doc.data()))
        .toList();
  }
}
