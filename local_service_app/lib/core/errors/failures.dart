import 'package:equatable/equatable.dart';

/// Base failure for all domain layer errors
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Network / HTTP failures
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.statusCode});
}

/// Server-side failures (5xx)
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Client-side input validation failures (4xx)
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.statusCode = 422});
}

/// Authentication failures (401 / 403)
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode = 401});
}

/// Resource not found (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.statusCode = 404});
}

/// Rate limit (429)
class RateLimitFailure extends Failure {
  const RateLimitFailure({
    super.message = 'Too many requests. Please slow down.',
    super.statusCode = 429,
  });
}

/// Local/cache failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
  });
}

/// Payment failures
class PaymentFailure extends Failure {
  const PaymentFailure({required super.message, super.statusCode});
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}
