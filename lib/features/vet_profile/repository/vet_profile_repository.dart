import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../farms/models/region_model.dart';
import '../models/availability_model.dart';
import '../models/dashboard_model.dart';
import '../models/vet_profile_model.dart';

class VetProfileRepository {
  const VetProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<VetProfileModel> getProfile() async {
    try {
      final r = await _apiClient.dio.get(ApiEndpoints.vetProfile);
      return VetProfileModel.fromJson(_data(r));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<VetProfileModel> updateProfile({
    String? bio,
    required int experienceYears,
    required double consultationFee,
    String? profileImageUrl,
  }) async {
    try {
      final r = await _apiClient.dio.put(ApiEndpoints.vetProfile, data: {
        'bio': bio,
        'experienceYears': experienceYears,
        'consultationFee': consultationFee,
        'profileImageUrl': profileImageUrl,
      });
      return VetProfileModel.fromJson(_data(r));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Regions ─────────────────────────────────────────────────────────────────

  Future<void> addRegion(int regionId) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.vetRegions,
          data: {'regionId': regionId});
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> removeRegion(int regionId) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.vetRegionById(regionId));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<List<RegionModel>> getAllRegions() async {
    try {
      final r = await _apiClient.dio.get(ApiEndpoints.regions);
      final raw = r.data is Map ? r.data['data'] : null;
      final list = raw is List ? raw : <dynamic>[];
      return list
          .whereType<Map<String, dynamic>>()
          .map(RegionModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Availability ─────────────────────────────────────────────────────────────

  Future<List<AvailabilityModel>> getAvailability() async {
    try {
      final r = await _apiClient.dio.get(ApiEndpoints.vetAvailability);
      final raw = r.data is Map ? r.data['data'] : null;
      final list = raw is List ? raw : <dynamic>[];
      return list
          .whereType<Map<String, dynamic>>()
          .map(AvailabilityModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<AvailabilityModel> addAvailability({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final r = await _apiClient.dio.post(ApiEndpoints.vetAvailability, data: {
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
      });
      return AvailabilityModel.fromJson(_data(r));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<AvailabilityModel> updateAvailability({
    required int id,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required bool isActive,
  }) async {
    try {
      final r = await _apiClient.dio.put(
        ApiEndpoints.vetAvailabilityById(id),
        data: {
          'dayOfWeek': dayOfWeek,
          'startTime': startTime,
          'endTime': endTime,
          'isActive': isActive,
        },
      );
      return AvailabilityModel.fromJson(_data(r));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> deleteAvailability(int id) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.vetAvailabilityById(id));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Dashboard ────────────────────────────────────────────────────────────────

  Future<DashboardModel> getDashboard() async {
    try {
      final r = await _apiClient.dio.get(ApiEndpoints.vetDashboard);
      return DashboardModel.fromJson(_data(r));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Helper ───────────────────────────────────────────────────────────────────

  Map<String, dynamic> _data(dynamic r) =>
      Map<String, dynamic>.from(r.data is Map ? r.data['data'] as Map : {});
}
