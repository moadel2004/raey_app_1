import 'package:equatable/equatable.dart';

/// Base class for all domain and data failures in the application.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

/// Returned when server responds with an error code (4xx, 5xx) or business logic error.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode, this.errors});

  final int? statusCode;
  final List<String>? errors;

  @override
  List<Object?> get props => [message, statusCode, errors];
}

/// Returned when connectivity issues or timeouts occur.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'يرجى التحقق من اتصال الإنترنت والمحاولة مجدداً',
  ]);
}

/// Returned when token is invalid or session has expired (HTTP 401).
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'انتهت الجلسة، يرجى تسجيل الدخول مجدداً']);
}

/// Returned when input validation fails.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.fieldErrors});

  final Map<String, List<String>>? fieldErrors;

  @override
  List<Object?> get props => [message, fieldErrors];
}
