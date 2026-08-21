import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_strings.dart';
import '../services/storage_service.dart';
import 'api_endpoints.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int?   statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storage.clearAll();
          }
          handler.next(error);
        },
      ),
    ]);

    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ));
    }
  }

  late final Dio _dio;
  final StorageService _storage;

  Dio get dio => _dio;
}

/// Returns a user-facing Arabic error message from a [DioException].
String mapDioError(DioException e) {
  // Try to extract message from the ApiResponse envelope first.
  try {
    final body = e.response?.data;
    if (body is Map) {
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.first.toString();
      }
      final msg = body['message'];
      if (msg != null && msg.toString().isNotEmpty) {
        return _translateServerMessage(msg.toString());
      }
    }
  } catch (_) {}

  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError) {
    return AppStrings.networkError;
  }

  if (e.type == DioExceptionType.badResponse) {
    final code = e.response?.statusCode ?? 0;
    if (code == 400) return 'البيانات مش صح، راجعها.';
    if (code == 401) return 'الجلسة انتهت، سجّل دخولك تاني.';
    if (code == 403) return 'مش مسموحلك بالوصول لده.';
    if (code == 404) return 'مش لاقي البيانات دي.';
    if (code == 409) return 'الرقم ده مسجل بالفعل، جرب تسجيل الدخول.';
    if (code >= 500) return 'في مشكلة في السيرفر، حاول بعدين.';
  }

  return AppStrings.unknownError;
}

String _translateServerMessage(String msg) {
  final lower = msg.toLowerCase();
  if (lower.contains('overlap')) {
    return 'الميعاد ده بيتعارض مع ميعاد موجود';
  }
  return msg;
}
