import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/animal_model.dart';

class AnimalsRepository {
  const AnimalsRepository(this._apiClient);

  final ApiClient _apiClient;

  /// GET /animals/farm/{farmId} — returns array directly in data
  Future<List<AnimalModel>> getAnimalsByFarm(int farmId) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.animalsByFarm(farmId));
      final data = response.data is Map ? response.data['data'] : null;
      final List<dynamic> raw = data is List ? data : [];
      return raw.whereType<Map<String, dynamic>>().map(AnimalModel.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException(_mapError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<AnimalModel> createAnimal({
    required String officialTagId,
    required String type,
    required String breed,
    required String gender,
    DateTime? birthDate,
    required int farmId,
  }) async {
    try {
      final body = <String, dynamic>{
        'officialTagId': officialTagId,
        'type': type,
        'breed': breed,
        'gender': gender,
        'farmId': farmId,
        if (birthDate != null)
          'birthDate': birthDate.toIso8601String().substring(0, 10),
      };
      final response = await _apiClient.dio.post(ApiEndpoints.animals, data: body);
      final data = response.data is Map ? response.data['data'] : null;
      return AnimalModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw ApiException(_mapError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<AnimalModel> updateAnimal({
    required int id,
    required String type,
    required String breed,
    required String gender,
    DateTime? birthDate,
  }) async {
    try {
      final body = <String, dynamic>{
        'type': type,
        'breed': breed,
        'gender': gender,
        if (birthDate != null)
          'birthDate': birthDate.toIso8601String().substring(0, 10),
      };
      final response =
          await _apiClient.dio.put(ApiEndpoints.animalById(id), data: body);
      final data = response.data is Map ? response.data['data'] : null;
      return AnimalModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw ApiException(_mapError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> deleteAnimal(int id) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.animalById(id));
    } on DioException catch (e) {
      throw ApiException(_mapError(e), statusCode: e.response?.statusCode);
    }
  }

  /// 409 for animals = duplicate officialTagId
  String _mapError(DioException e) {
    if (e.response?.statusCode == 409) return 'رقم التاج ده مستخدم قبل كده';
    return mapDioError(e);
  }
}
