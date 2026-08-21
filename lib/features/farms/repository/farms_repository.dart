import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/farm_model.dart';
import '../models/region_model.dart';

class FarmsRepository {
  const FarmsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<FarmModel>> getFarms({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.farms,
        queryParameters: {'pageNumber': page, 'pageSize': pageSize},
      );
      final dataField = response.data is Map ? response.data['data'] : null;
      final List<dynamic> items =
          (dataField is Map && dataField['items'] is List)
              ? dataField['items'] as List
              : [];
      return items.whereType<Map<String, dynamic>>().map(FarmModel.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<FarmModel> getFarm(int id) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.farmById(id));
      final data = response.data is Map ? response.data['data'] : null;
      return FarmModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<FarmModel> createFarm({
    required String name,
    required String location,
    required int regionId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.farms,
        data: {'name': name, 'location': location, 'regionId': regionId},
      );
      final data = response.data is Map ? response.data['data'] : null;
      return FarmModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<FarmModel> updateFarm({
    required int id,
    required String name,
    required String location,
    required int regionId,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.farmById(id),
        data: {'name': name, 'location': location, 'regionId': regionId},
      );
      final data = response.data is Map ? response.data['data'] : null;
      return FarmModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> deleteFarm(int id) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.farmById(id));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<List<RegionModel>> getRegions() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.regions);
      // regions endpoint returns array directly in data (not paginated)
      final data = response.data is Map ? response.data['data'] : null;
      final List<dynamic> raw = data is List ? data : [];
      return raw.whereType<Map<String, dynamic>>().map(RegionModel.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }
}
