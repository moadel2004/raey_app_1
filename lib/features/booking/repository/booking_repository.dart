import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/vet_summary_model.dart';

class BookingRepository {
  const BookingRepository(this._apiClient);

  final ApiClient _apiClient;

  /// GET /veterinarians/regions/{regionId} — returns array directly in data
  Future<List<VetSummaryModel>> getVetsByRegion(int regionId) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.vetsByRegionId(regionId));
      final data = response.data is Map ? response.data['data'] : null;
      final List<dynamic> raw = data is List ? data : [];
      return raw.whereType<Map<String, dynamic>>().map(VetSummaryModel.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  /// POST /bookings — scheduledAt MUST be UTC ISO 8601
  Future<void> createBooking({
    required int vetId,
    int? farmId,
    required String type,
    required DateTime scheduledAt,
    required List<int> animalIds,
  }) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.bookings,
        data: {
          'vetId': vetId,
          if (farmId != null) 'farmId': farmId,
          'type': type,
          'scheduledAt': scheduledAt.toUtc().toIso8601String(),
          'animalIds': animalIds,
        },
      );
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }
}
