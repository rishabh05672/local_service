import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_service_app/core/network/api_client.dart';
import 'package:local_service_app/core/security/secure_storage_service.dart';

// ─── Secure Storage ──────────────────────────────────────────────────────────

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageServiceImpl();
});

// ─── Token Manager ───────────────────────────────────────────────────────────

final tokenManagerProvider = Provider<TokenManager>((ref) {
  return TokenManager(storage: ref.watch(secureStorageProvider));
});

// ─── API Client ───────────────────────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenManager: ref.watch(tokenManagerProvider));
});
