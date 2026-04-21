abstract class AppConstants {
  // ─── Storage Keys ──────────────────────────────────────────────────────────
  static const String kAccessToken = 'access_token';
  static const String kRefreshToken = 'refresh_token';
  static const String kUserData = 'user_data';
  static const String kUserRole = 'user_role';
  static const String kOnboardingDone = 'onboarding_done';
  static const String kThemeMode = 'theme_mode';
  static const String kFcmToken = 'fcm_token';
  static const String kLanguage = 'language';

  // ─── User Roles ────────────────────────────────────────────────────────────
  static const String roleCustomer = 'customer';
  static const String roleProvider = 'provider';
  static const String roleAdmin = 'admin';

  // ─── Booking Status ────────────────────────────────────────────────────────
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  static const String statusDisputed = 'disputed';

  // ─── Payment Status ────────────────────────────────────────────────────────
  static const String paymentPending = 'pending';
  static const String paymentSuccess = 'success';
  static const String paymentFailed = 'failed';
  static const String paymentRefunded = 'refunded';

  // ─── Chat Message Types ────────────────────────────────────────────────────
  static const String msgTypeText = 'text';
  static const String msgTypeImage = 'image';
  static const String msgTypeLocation = 'location';
  static const String msgTypeAudio = 'audio';
  static const String msgTypeFile = 'file';
  static const String msgTypeSystem = 'system';

  // ─── WebSocket Events ──────────────────────────────────────────────────────
  static const String wsEventMessage = 'message';
  static const String wsEventTyping = 'typing';
  static const String wsEventRead = 'message:read';
  static const String wsEventJoinRoom = 'room:join';
  static const String wsEventLeaveRoom = 'room:leave';
  static const String wsEventOnline = 'user:online';
  static const String wsEventOffline = 'user:offline';
  static const String wsEventBookingUpdate = 'booking:updated';

  // ─── API Headers ───────────────────────────────────────────────────────────
  static const String headerTraceId = 'x-trace-id';
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String headerIdempotencyKey = 'x-idempotency-key';

  // ─── Validation Limits ─────────────────────────────────────────────────────
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxMessageLength = 2000;
  static const int otpLength = 6;
  static const double maxFileUploadMB = 10.0;
  static const int maxImageCount = 5;

  // ─── Map ──────────────────────────────────────────────────────────────────
  static const double defaultLatitude = 20.5937;
  static const double defaultLongitude = 78.9629;
  static const double defaultZoom = 13.0;
  static const double maxSearchRadius = 50.0; // km

  AppConstants._();
}
