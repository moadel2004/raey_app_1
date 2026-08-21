import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storage;

  AuthRepository(this._apiClient, this._storage);

  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: {'phoneNumber': phoneNumber, 'password': password},
      );
      return await _handleAuthResponse(response);
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<UserModel> register({
    required String fullName,
    required String phoneNumber,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.register,
        data: {
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'password': password,
          'role': role,
        },
      );
      return await _handleAuthResponse(response, fallbackRole: role);
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> logout() async => _storage.clearAll();

  UserModel? getCachedUser() => _storage.getUser();

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<UserModel> _handleAuthResponse(
    Response response, {
    String? fallbackRole,
  }) async {
    final body = response.data;
    final statusCode = response.statusCode ?? 0;

    final isSuccess =
        statusCode >= 200 &&
        statusCode < 300 &&
        body is Map &&
        body['success'] == true &&
        body['data'] != null;

    if (!isSuccess) {
      throw ApiException(_extractApiError(body, statusCode), statusCode: statusCode);
    }

    final data = Map<String, dynamic>.from(body['data'] as Map);
    final token = data['token'] as String? ?? '';
    if (token.isEmpty) throw ApiException('لم يتم استلام رمز الدخول من السيرفر');

    // data['role'] موجود دايماً من الباك اند؛ fallbackRole أمان للـ register
    final roleFromResponse = (data['role'] as String?)?.trim() ?? '';
    final role = roleFromResponse.isNotEmpty ? roleFromResponse : (fallbackRole ?? '');

    final user = UserModel.fromAuthResponse(data, fallbackRole: role);
    await _storage.saveToken(token);
    await _storage.saveUser(user);
    return user;
  }

  String _extractApiError(dynamic body, int statusCode) {
    if (body is Map) {
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty) return errors.first.toString();
      final msg = body['message'];
      if (msg is String && msg.trim().isNotEmpty) return msg;
    }
    if (statusCode == 401) return 'رقم التليفون أو كلمة المرور غير صحيحة';
    return 'حدث خطأ، حاول تاني';
  }
}
