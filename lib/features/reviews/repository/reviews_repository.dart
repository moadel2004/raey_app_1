import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/review_model.dart';
import '../models/vet_reviews_model.dart';

class ReviewsRepository {
  const ReviewsRepository(this._apiClient);

  final ApiClient _apiClient;

  // ── Create ────────────────────────────────────────────────────────────────

  Future<ReviewModel> createReview({
    required int vetId,       // ⚠️ vetId — not veterinarianId
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      final r = await _apiClient.dio.post(
        ApiEndpoints.reviews,
        data: {
          'vetId':     vetId,
          'bookingId': bookingId,
          'rating':    rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
      return ReviewModel.fromJson(_data(r));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<ReviewModel> updateReview(
    int id, {
    required int rating,
    String? comment,
  }) async {
    try {
      final r = await _apiClient.dio.put(
        ApiEndpoints.reviewById(id),
        data: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
      return ReviewModel.fromJson(_data(r));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteReview(int id) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.reviewById(id));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Read single ───────────────────────────────────────────────────────────

  Future<ReviewModel> getReview(int id) async {
    try {
      final r = await _apiClient.dio.get(ApiEndpoints.reviewById(id));
      return ReviewModel.fromJson(_data(r));
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Vet reviews (nested pagination — data['reviews']['items']) ─────────────

  Future<VetReviewsModel> getVetReviews(int vetId, {int page = 1}) async {
    try {
      final r = await _apiClient.dio.get(
        ApiEndpoints.vetReviews(vetId),
        queryParameters: {'pageNumber': page, 'pageSize': 20},
      );
      final data = r.data is Map
          ? Map<String, dynamic>.from(r.data['data'] as Map)
          : <String, dynamic>{};
      return VetReviewsModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  Map<String, dynamic> _data(dynamic r) =>
      Map<String, dynamic>.from(r.data is Map ? r.data['data'] as Map : {});
}
