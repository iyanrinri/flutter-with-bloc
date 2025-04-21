import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // untuk kIsWeb
import 'dart:io' show HttpClient, X509Certificate;
import 'package:dio/io.dart'; // untuk IOHttpClientAdapter

Dio getDio([BaseOptions? options]) {
  final dio = Dio(options);

  if (!kIsWeb) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

  }

  return dio;
}
