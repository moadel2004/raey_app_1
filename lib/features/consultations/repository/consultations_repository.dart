import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../booking/models/vet_summary_model.dart';
import '../models/consultation_model.dart';

class ConsultationsRepository {
  const ConsultationsRepository(this._apiClient);

  final ApiClient _apiClient;

  // ── Vets list ─────────────────────────────────────────────────────────────

  Future<List<VetSummaryModel>> getAllVets() async {
    try {
      final r = await _apiClient.dio.get(ApiEndpoints.vetsSearch);
      final raw = r.data is Map ? r.data['data'] : null;
      final list = raw is List ? raw : (raw is Map ? raw['items'] : null) ?? <dynamic>[];
      return (list as List)
          .whereType<Map<String, dynamic>>()
          .map(VetSummaryModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<ConsultationModel> createConsultation({
    required int veterinarianId,
    required String subject,
    String? description,
  }) async {
    try {
      final r = await _apiClient.dio.post(
        ApiEndpoints.consultations,
        data: {
          'veterinarianId': veterinarianId,
          'subject': subject,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );
      return ConsultationModel.fromJson(_data(r));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<List<ConsultationModel>> getMyConsultations({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final r = await _apiClient.dio.get(
        ApiEndpoints.myConsultations,
        queryParameters: {
          if (status != null) 'status': status,
          'pageNumber': page,
          'pageSize': pageSize,
        },
      );
      return _parseList(r);
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<List<ConsultationModel>> getVetConsultations({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final r = await _apiClient.dio.get(
        ApiEndpoints.vetConsultations,
        queryParameters: {
          if (status != null) 'status': status,
          'pageNumber': page,
          'pageSize': pageSize,
        },
      );
      return _parseList(r);
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<ConsultationModel> getConsultation(int id) async {
    try {
      final r = await _apiClient.dio.get(ApiEndpoints.consultationById(id));
      return ConsultationModel.fromJson(_data(r));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Actions (PUT with no body) ─────────────────────────────────────────────

  Future<void> acceptConsultation(int id) async {
    try {
      await _apiClient.dio.put(ApiEndpoints.acceptConsultation(id));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> rejectConsultation(int id) async {
    try {
      await _apiClient.dio.put(ApiEndpoints.rejectConsultation(id));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> closeConsultation(int id) async {
    try {
      await _apiClient.dio.put(ApiEndpoints.closeConsultation(id));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<ConsultationModel> _parseList(dynamic r) {
    final body  = r.data is Map ? r.data['data'] : null;
    final items = body is Map ? body['items'] : (body is List ? body : null);
    final list  = items is List ? items : <dynamic>[];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ConsultationModel.fromJson)
        .toList();
  }

  Map<String, dynamic> _data(dynamic r) =>
      Map<String, dynamic>.from(r.data is Map ? r.data['data'] as Map : {});
}
