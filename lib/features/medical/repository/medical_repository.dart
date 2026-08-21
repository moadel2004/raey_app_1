import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/animal_medical_history_model.dart';
import '../models/medical_record_model.dart';
import '../models/prescription_model.dart';
import '../models/record_change_model.dart';

class MedicalRepository {
  const MedicalRepository(this._apiClient);

  final ApiClient _apiClient;

  // ── Create ────────────────────────────────────────────────────────────────

  Future<MedicalRecordModel> createRecord({
    required int animalId,
    required int vetId,       // ← vetId from VetProfile, NOT userId
    required int bookingId,
    required String visitType,
    String? symptoms,
    String? diagnosis,
    String? notes,
    List<PrescriptionModel> prescriptions = const [],
  }) async {
    try {
      final r = await _apiClient.dio.post(
        ApiEndpoints.medicalRecords,
        data: {
          'animalId':  animalId,
          'vetId':     vetId,
          'bookingId': bookingId,
          'visitType': visitType,
          if (symptoms  != null && symptoms.isNotEmpty)  'symptoms':  symptoms,
          if (diagnosis != null && diagnosis.isNotEmpty) 'diagnosis': diagnosis,
          if (notes     != null && notes.isNotEmpty)     'notes':     notes,
          'prescriptions': prescriptions.map((p) => p.toJson()).toList(),
        },
      );
      return MedicalRecordModel.fromJson(_data(r));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<MedicalRecordModel> updateRecord(
    int id, {
    required String visitType,
    String? symptoms,
    String? diagnosis,
    String? notes,
    List<PrescriptionModel> prescriptions = const [],
  }) async {
    try {
      final r = await _apiClient.dio.put(
        ApiEndpoints.medicalRecordById(id),
        data: {
          'visitType': visitType,
          if (symptoms  != null && symptoms.isNotEmpty)  'symptoms':  symptoms,
          if (diagnosis != null && diagnosis.isNotEmpty) 'diagnosis': diagnosis,
          if (notes     != null && notes.isNotEmpty)     'notes':     notes,
          'prescriptions': prescriptions.map((p) => p.toJson()).toList(),
        },
      );
      return MedicalRecordModel.fromJson(_data(r));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteRecord(int id) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.medicalRecordById(id));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Read single ───────────────────────────────────────────────────────────

  Future<MedicalRecordModel> getRecord(int id) async {
    try {
      final r = await _apiClient.dio.get(ApiEndpoints.medicalRecordById(id));
      return MedicalRecordModel.fromJson(_data(r));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Animal history ────────────────────────────────────────────────────────

  Future<AnimalMedicalHistoryModel> getAnimalHistory(int animalId) async {
    try {
      final r = await _apiClient.dio.get(
        ApiEndpoints.animalMedicalHistory(animalId),
      );
      return AnimalMedicalHistoryModel.fromJson(_data(r));
    } on DioException catch (e) {
      // Backend returns 400 when animal exists but has no records yet
      if (e.response?.statusCode == 400) {
        final body = e.response?.data;
        final msg  = (body is Map
                ? (body['Message'] ?? body['message'] ?? '')
                : '')
            .toString()
            .toLowerCase();
        if (msg.contains('no medical records found')) {
          return AnimalMedicalHistoryModel(
            animalId:      animalId,
            officialTagId: '',
            type:          '',
            breed:         '',
            records:       [],
          );
        }
      }
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Record change log ─────────────────────────────────────────────────────

  Future<List<RecordChangeModel>> getRecordChanges(int id) async {
    try {
      final r = await _apiClient.dio.get(ApiEndpoints.medicalRecordHistory(id));
      final raw  = r.data is Map ? r.data['data'] : null;
      final list = raw is List ? raw : <dynamic>[];
      return list
          .whereType<Map<String, dynamic>>()
          .map(RecordChangeModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────

  Future<List<MedicalRecordModel>> searchRecords({
    int? animalId,
    int? veterinarianId,   // ← search uses "veterinarianId", not "vetId"
    String? visitType,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final r = await _apiClient.dio.get(
        ApiEndpoints.medicalSearch,
        queryParameters: {
          if (animalId        != null) 'animalId':       animalId,
          if (veterinarianId  != null) 'veterinarianId': veterinarianId,
          if (visitType       != null) 'visitType':      visitType,
          if (fromDate        != null) 'fromDate':       fromDate.toIso8601String(),
          if (toDate          != null) 'toDate':         toDate.toIso8601String(),
          'pageNumber': page,
          'pageSize':   pageSize,
        },
      );
      final body  = r.data is Map ? r.data['data'] : null;
      final items = body is Map ? body['items'] : (body is List ? body : null);
      final list  = items is List ? items : <dynamic>[];
      return list
          .whereType<Map<String, dynamic>>()
          .map(MedicalRecordModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  Map<String, dynamic> _data(dynamic r) =>
      Map<String, dynamic>.from(r.data is Map ? r.data['data'] as Map : {});
}
