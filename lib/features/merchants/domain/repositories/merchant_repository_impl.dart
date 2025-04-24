import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yukngantri/core/network/api_service.dart';
import 'package:yukngantri/features/merchants/data/models/merchant_model.dart';
import 'package:yukngantri/features/merchants/domain/entities/merchant.dart';
import 'package:yukngantri/features/merchants/domain/repositories/merchant_repository.dart';

class MerchantRepositoryImpl implements MerchantRepository {
  final ApiService apiService;
  final FlutterSecureStorage storage;

  MerchantRepositoryImpl({required this.apiService, required this.storage});

  @override
  Future<List<Merchant>> getMerchants({int page = 1, String? query}) async {
    try {
      var queryParams = {
        'page': page.toString(),
        if (query != null) 'query': query,
      };
      final response = await apiService.sendRequest(
        method: 'GET',
        endpoint: '/merchants',
        useAuth: true,
        queryParameters: queryParams
      );
      if (response?.statusCode == 200) {
        final data = response?.data as List;
        return data.map((json) => MerchantModel.fromJson(json).toEntity()).toList();
      } else {
        throw Exception('Failed to fetch merchants');
      }
    } catch (e) {
      print('Error fetching merchants: $e');
      throw Exception('Failed to fetch merchants: $e');
    }
  }

  @override
  Future<void> createMerchant(Merchant merchant) async {
    try {
      await apiService.sendRequest(
        method: 'POST',
        endpoint: '/merchants',
        data: MerchantModel(
          id: merchant.id,
          name: merchant.name,
        ).toJson(),
        useAuth: true,
      );
    } catch (e) {
      print('Error creating merchant: $e');
      throw Exception('Failed to create merchant: $e');
    }
  }

  @override
  Future<void> updateMerchant(Merchant merchant) async {
    try {
      await apiService.sendRequest(
        method: 'PUT',
        endpoint: '/merchants/${merchant.id}',
        data: MerchantModel(
          id: merchant.id,
          name: merchant.name,
        ).toJson(),
        useAuth: true,
      );
    } catch (e) {
      print('Error updating merchant: $e');
      throw Exception('Failed to update merchant: $e');
    }
  }

  @override
  Future<void> deleteMerchant(int id) async {
    try {
      await apiService.sendRequest(
        method: 'DELETE',
        endpoint: '/merchants/$id',
        useAuth: true,
      );
    } catch (e) {
      print('Error deleting merchant: $e');
      throw Exception('Failed to delete merchant: $e');
    }
  }
}

extension on MerchantModel {
  Merchant toEntity() {
    return Merchant(
      id: id,
      name: name,
    );
  }
}