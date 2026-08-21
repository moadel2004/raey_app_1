import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/chat_session_model.dart';
import '../models/message_model.dart';

class ChatRepository {
  const ChatRepository(this._apiClient);

  final ApiClient _apiClient;

  // ── Session ───────────────────────────────────────────────────────────────

  Future<ChatSessionModel> getSession(int consultationId) async {
    try {
      final r = await _apiClient.dio.get(
        ApiEndpoints.chatSession(consultationId),
      );
      final data = r.data is Map ? r.data['data'] : null;
      if (data == null) {
        throw ApiException('تعذّر جلب جلسة الشات.');
      }
      return ChatSessionModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ApiException('الشات مش متاح لهذه الاستشارة.');
      }
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  Future<List<MessageModel>> getMessages(
    int chatSessionId, {
    int pageSize = 100,
  }) async {
    try {
      final r = await _apiClient.dio.get(
        ApiEndpoints.sessionMessages(chatSessionId),
        queryParameters: {'pageNumber': 1, 'pageSize': pageSize},
      );
      final body  = r.data is Map ? r.data['data'] : null;
      final items = body is Map ? body['items'] : (body is List ? body : null);
      final list  = items is List ? items : <dynamic>[];
      final msgs  = list
          .whereType<Map<String, dynamic>>()
          .map(MessageModel.fromJson)
          .toList();
      // Sort ascending by createdAt (oldest first)
      msgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return msgs;
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }

  // ── Send ──────────────────────────────────────────────────────────────────

  Future<void> sendMessage({
    required int chatSessionId,
    required String content,
  }) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.messages,
        data: {
          'chatSessionId': chatSessionId, // ← اسم الإرسال مختلف عن اسم الاستقبال
          'content': content,
        },
      );
    } on DioException catch (e) {
      throw ApiException(mapDioError(e), statusCode: e.response?.statusCode);
    }
  }
}
