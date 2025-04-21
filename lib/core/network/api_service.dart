import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class ApiService with ChangeNotifier {
  final storage = const FlutterSecureStorage();
  final baseApiUrl = dotenv.env['API_URL'] ?? '';
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseApiUrl,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<Response?> sendRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool useAuth = false,
    bool isMultipart = false,
  }) async {
    // endpoint = '$baseApiUrl$endpoint';
    try {
      String? token = await storage.read(key: 'token');
      if (useAuth && token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      late Response response;

      dynamic payload;

      if (isMultipart && data != null) {
        payload = FormData.fromMap(data);
      } else {
        payload = data;
      }

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(endpoint, queryParameters: queryParameters);
          break;
        case 'POST':
          response = await _dio.post(endpoint, data: payload);
          break;
        case 'PUT':
          response = await _dio.put(endpoint, data: data);
          break;
        case 'DELETE':
          response = await _dio.delete(endpoint, data: data);
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }
      return response;
    } on DioException catch (e) {
      // print('Dio error: ${e.message}');
      if (e.response != null) {
        // return {'status': false, 'data': e.response?.data}
      }
      return e.response;
    } catch (e) {
      // print('Unexpected error: $e');
      return null;
    }
  }
}
