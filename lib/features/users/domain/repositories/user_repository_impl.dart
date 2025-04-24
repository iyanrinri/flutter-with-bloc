import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yukngantri/core/network/api_service.dart';
import 'package:yukngantri/features/users/data/models/user_model.dart';
import 'package:yukngantri/features/users/domain/entities/user.dart';
import 'package:yukngantri/features/users/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService apiService;
  final FlutterSecureStorage storage;

  UserRepositoryImpl({required this.apiService, required this.storage});

  @override
  Future<List<User>> getUsers({int page = 1, String? query}) async {
    try {
      final response = await apiService.sendRequest(
        method: 'GET',
        endpoint: '/users',
        useAuth: true,
        queryParameters: {
          'page': page.toString(),
          if (query != null) 'query': query,
        }
      );
      if (response?.statusCode == 200) {
        final data = response?.data as List;
        return data.map((json) => UserModel.fromJson(json).toEntity()).toList();
      } else {
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to fetch users: $e');
    }
  }

  @override
  Future<void> createUser(User user) async {
    try {
      await apiService.sendRequest(
        method: 'POST',
        endpoint: '/users',
        data: UserModel(
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
        ).toJson(),
        useAuth: true,
      );
    } catch (e) {
      print('Error creating user: $e');
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      await apiService.sendRequest(
        method: 'PUT',
        endpoint: '/users/${user.id}',
        data: UserModel(
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
        ).toJson(),
        useAuth: true,
      );
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      await apiService.sendRequest(
        method: 'DELETE',
        endpoint: '/users/$id',
        useAuth: true,
      );
    } catch (e) {
      print('Error deleting user: $e');
      throw Exception('Failed to delete user: $e');
    }
  }
}

extension on UserModel {
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      role: role,
    );
  }
}