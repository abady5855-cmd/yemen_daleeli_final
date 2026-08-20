import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_daleeli/features/auth/data/models/user_model.dart';
import 'package:yemen_daleeli/features/auth/domain/entities/user_entity.dart';

void main() {
  final tCreatedAt = DateTime(2023, 1, 1);
  final tUserModel = UserModel(
    id: '1',
    email: 'test@example.com',
    fullName: 'Test User',
    createdAt: tCreatedAt,
    role: UserRole.user,
  );

  group('UserModel Mapping Tests', () {
    test('should be a subclass of UserEntity', () {
      expect(tUserModel, isA<UserEntity>());
    });

    test('fromJson should return a valid model', () {
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'email': 'test@example.com',
        'fullName': 'Test User',
        'createdAt': tCreatedAt.toIso8601String(),
        'role': 'user',
        'isActive': true,
      };

      final result = UserModel.fromJson(jsonMap);
      expect(result.id, tUserModel.id);
      expect(result.email, tUserModel.email);
    });

    test('toJson should return a JSON map containing proper data', () {
      final result = tUserModel.toJson();
      final expectedMap = {
        'id': '1',
        'email': 'test@example.com',
        'fullName': 'Test User',
        'phoneNumber': null,
        'profileImageUrl': null,
        'address': null,
        'city': null,
        'isEmailVerified': false,
        'createdAt': tCreatedAt.toIso8601String(),
        'lastLoginAt': null,
        'role': 'user',
        'isActive': true,
        'governorate': null,
        'district': null,
        'updatedAt': null,
        'isDeleted': false,
        'deletedAt': null,
        'createdBy': null,
        'updatedBy': null,
        'deletedBy': null,
        'version': 1,
      };
      expect(result, expectedMap);
    });
  });
}
