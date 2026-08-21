import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../auth/models/user_model.dart';
import '../../auth/repository/auth_repository.dart';
import '../models/dashboard_model.dart';

class HomeRepository {
  const HomeRepository(this._authRepository, this._apiClient);

  final AuthRepository _authRepository;
  final ApiClient _apiClient;

  Future<UserModel> getUserData() async {
    final user = _authRepository.getCachedUser();
    if (user == null) throw Exception('مفيش بيانات مستخدم، سجّل دخولك تاني.');
    return user;
  }

  /// GET /dashboard — Farmer only
  Future<DashboardModel> getDashboard() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.farmerDashboard);
      final data = response.data is Map ? response.data['data'] : null;
      return DashboardModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }
}
