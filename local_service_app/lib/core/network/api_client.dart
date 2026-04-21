import 'dart:io';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:local_service_app/core/config/app_config.dart';
import 'package:local_service_app/core/constants/app_constants.dart';
import 'package:local_service_app/core/errors/failures.dart';
import 'package:local_service_app/core/security/secure_storage_service.dart';
import 'package:local_service_app/core/utils/app_logger.dart';

/// Dio-based HTTP client with:
/// - JWT auth injection
/// - Silent refresh token rotation
/// - Request tracing ID
/// - Sanitized error mapping
class ApiClient {
  ApiClient({
    required this.tokenManager,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _configure();
  }

  final TokenManager tokenManager;
  final Dio _dio;
  final _uuid = const Uuid();
  bool _isRefreshing = false;
  final List<_RetryRequest> _pendingRetries = [];

  Dio get client => _dio;

  void _configure() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      headers: {
        AppConstants.headerContentType: 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(tokenManager: tokenManager, client: this),
      _TracingInterceptor(uuid: _uuid),
      _ErrorInterceptor(),
      if (AppConfig.isDevelopment) _LoggingInterceptor(),
    ]);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.put<T>(path, data: data, options: options);

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.patch<T>(path, data: data, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    Options? options,
  }) =>
      _dio.delete<T>(path, options: options);

  Future<Response<T>> upload<T>(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
  }) =>
      _dio.post<T>(path, data: formData, onSendProgress: onSendProgress);
}

// ─── Auth Interceptor ────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({required this.tokenManager, required this.client});

  final TokenManager tokenManager;
  final ApiClient client;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenManager.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers[AppConstants.headerAuthorization] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Avoid refresh loop
    if (err.requestOptions.path.contains('/auth/refresh')) {
      await tokenManager.clearTokens();
      return handler.reject(err);
    }

    if (client._isRefreshing) {
      // Queue retry
      final retry = _RetryRequest(handler: handler, options: err.requestOptions);
      client._pendingRetries.add(retry);
      return;
    }

    client._isRefreshing = true;
    try {
      final refreshToken = await tokenManager.getRefreshToken();
      if (refreshToken == null) {
        await tokenManager.clearTokens();
        return handler.reject(err);
      }

      // Call refresh endpoint
      final response = await client._dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      final newAccess = response.data['data']['accessToken'] as String;
      final newRefresh = response.data['data']['refreshToken'] as String;
      await tokenManager.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      // Retry original request
      err.requestOptions.headers[AppConstants.headerAuthorization] =
          'Bearer $newAccess';
      final retried = await client._dio.fetch(err.requestOptions);
      handler.resolve(retried);

      // Drain queued retries
      for (final r in client._pendingRetries) {
        r.options.headers[AppConstants.headerAuthorization] =
            'Bearer $newAccess';
        final resp = await client._dio.fetch(r.options);
        r.handler.resolve(resp);
      }
      client._pendingRetries.clear();
    } catch (_) {
      await tokenManager.clearTokens();
      for (final r in client._pendingRetries) {
        r.handler.reject(err);
      }
      client._pendingRetries.clear();
      handler.reject(err);
    } finally {
      client._isRefreshing = false;
    }
  }
}

// ─── Tracing Interceptor ─────────────────────────────────────────────────────

class _TracingInterceptor extends Interceptor {
  _TracingInterceptor({required this.uuid});
  final Uuid uuid;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[AppConstants.headerTraceId] = uuid.v4();
    handler.next(options);
  }
}

// ─── Error Mapping Interceptor ────────────────────────────────────────────────

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final mapped = _mapToFailure(err);
    AppLogger.error(
      'API Error: ${mapped.message}',
      error: err,
    );
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: mapped,
        message: mapped.message,
      ),
    );
  }

  Failure _mapToFailure(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return const NetworkFailure(
        message: 'Connection timed out. Check your internet.',
        statusCode: 408,
      );
    }
    if (err.type == DioExceptionType.connectionError ||
        err.error is SocketException) {
      return const NetworkFailure(
        message: 'No internet connection.',
      );
    }

    final code = err.response?.statusCode ?? 500;
    final serverMessage = _extractMessage(err.response?.data);

    return switch (code) {
      400 => ValidationFailure(message: serverMessage ?? 'Invalid request.'),
      401 => const AuthFailure(message: 'Session expired. Please login.'),
      403 => const AuthFailure(message: 'Access denied.', statusCode: 403),
      404 => NotFoundFailure(message: serverMessage ?? 'Resource not found.'),
      422 => ValidationFailure(message: serverMessage ?? 'Validation failed.'),
      429 => const RateLimitFailure(),
      >= 500 => ServerFailure(
          message: 'Server error. Please try again.',
          statusCode: code,
        ),
      _ => const UnknownFailure(),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString();
    }
    return null;
  }
}

// ─── Dev Logging Interceptor ──────────────────────────────────────────────────

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.networkRequest(
      method: options.method,
      url: options.uri.toString(),
      headers: options.headers.cast<String, dynamic>(),
      body: options.data,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.networkResponse(
      statusCode: response.statusCode ?? 0,
      url: response.requestOptions.uri.toString(),
      body: response.data,
    );
    handler.next(response);
  }
}

// ─── Retry Queue Item ─────────────────────────────────────────────────────────

class _RetryRequest {
  _RetryRequest({required this.handler, required this.options});
  final ErrorInterceptorHandler handler;
  final RequestOptions options;
}
