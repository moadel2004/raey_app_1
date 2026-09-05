import 'package:dio/dio.dart';
import 'api_client.dart';

/// Generic envelope wrapper matching the backend response structure:
/// {
///   "success": true,
///   "message": "...",
///   "data": { ... },
///   "errors": [ ... ]
/// }
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;
  final int? statusCode;

  /// Parses a Dio [Response] using a [fromJson] transformer for the `data` payload.
  factory ApiResponse.fromResponse(
    Response response,
    T Function(dynamic json) fromJson,
  ) {
    final statusCode = response.statusCode ?? 200;
    final body = response.data;

    if (body is! Map) {
      return ApiResponse(
        success: statusCode >= 200 && statusCode < 300,
        statusCode: statusCode,
      );
    }

    final success =
        (body['success'] == true) || (statusCode >= 200 && statusCode < 300);
    final message = body['message']?.toString();

    List<String>? errorsList;
    if (body['errors'] is List) {
      errorsList = (body['errors'] as List).map((e) => e.toString()).toList();
    }

    T? parsedData;
    if (body['data'] != null) {
      try {
        parsedData = fromJson(body['data']);
      } catch (_) {
        parsedData = null;
      }
    }

    return ApiResponse(
      success: success,
      message: message,
      data: parsedData,
      errors: errorsList,
      statusCode: statusCode,
    );
  }

  /// Returns [data] if [success] is true and [data] is not null,
  /// otherwise throws an [ApiException] with the extracted error message.
  T unwrap() {
    if (success && data != null) {
      return data!;
    }

    final errorMsg = (errors != null && errors!.isNotEmpty)
        ? errors!.first
        : (message ?? 'حدث خطأ غير متوقع');

    throw ApiException(errorMsg, statusCode: statusCode);
  }
}
