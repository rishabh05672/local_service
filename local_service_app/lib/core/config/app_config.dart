/// Application-wide configuration loaded via environment.
/// NEVER hardcode real values here — use --dart-define or a .env loader.
abstract class AppConfig {
  // ─── Backend ───────────────────────────────────────────────────────────────
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1', // Android emulator localhost
  );

  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  // ─── Feature Flags ─────────────────────────────────────────────────────────
  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';
  static bool get isStaging => appEnv == 'staging';

  // ─── Timeouts ──────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ─── Pagination ────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ─── Rate Limiting (client-side UI debounce) ───────────────────────────────
  static const Duration otpResendDelay = Duration(seconds: 60);
  static const Duration searchDebounce = Duration(milliseconds: 400);

  // ─── Map (OpenStreetMap — No API Key Required) ─────────────────────────────
  static const String osmTileUrl =
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  // ─── Cache ─────────────────────────────────────────────────────────────────
  static const Duration tileCacheDuration = Duration(days: 30);

  AppConfig._();
}
