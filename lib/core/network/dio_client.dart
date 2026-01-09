import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Network Core Service
/// Standardized Dio configuration for all API calls.

@lazySingleton
class DioClient {
  final Dio _dio = Dio();

  DioClient() {
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Dio get instance => _dio;
}
