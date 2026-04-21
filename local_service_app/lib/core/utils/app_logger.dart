import 'package:logger/logger.dart';
import 'package:local_service_app/core/config/app_config.dart';

/// Centralized, redaction-aware logger.
/// In production, logging is suppressed below warning level.
class AppLogger {
  static final Logger _logger = Logger(
    level: AppConfig.isProduction ? Level.warning : Level.trace,
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 100,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    filter: _ProductionFilter(),
  );

  static void trace(String message) => _logger.t(message);
  static void debug(String message) => _logger.d(message);
  static void info(String message) => _logger.i(message);
  static void warning(String message) => _logger.w(message);
  static void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
  static void fatal(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.f(message, error: error, stackTrace: stackTrace);

  /// Logs network requests — redacts Authorization header.
  static void networkRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (AppConfig.isProduction) return;
    final sanitizedHeaders = _redactHeaders(headers);
    _logger.d('→ $method $url\nHeaders: $sanitizedHeaders\nBody: $body');
  }

  static void networkResponse({
    required int statusCode,
    required String url,
    dynamic body,
  }) {
    if (AppConfig.isProduction) return;
    _logger.d('← $statusCode $url\nBody: $body');
  }

  static Map<String, dynamic>? _redactHeaders(Map<String, dynamic>? headers) {
    if (headers == null) return null;
    return {
      for (final e in headers.entries)
        e.key: e.key.toLowerCase() == 'authorization' ? '[REDACTED]' : e.value,
    };
  }

  AppLogger._();
}

class _ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (AppConfig.isProduction) {
      return event.level.index >= Level.warning.index;
    }
    return true;
  }
}
