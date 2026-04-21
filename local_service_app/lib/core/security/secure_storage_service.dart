import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_service_app/core/constants/app_constants.dart';
import 'package:local_service_app/core/utils/app_logger.dart';

/// Abstraction over secure storage — swap implementation without touching callers.
abstract class SecureStorageService {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
  Future<bool> containsKey({required String key});
  Future<Map<String, String>> readAll();
}

class SecureStorageServiceImpl implements SecureStorageService {
  SecureStorageServiceImpl() : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
          accountName: 'com.localservice.app',
        ),
      );

  final FlutterSecureStorage _storage;

  @override
  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      AppLogger.error('SecureStorage write failed for key=$key', error: e);
      rethrow;
    }
  }

  @override
  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      AppLogger.error('SecureStorage read failed for key=$key', error: e);
      return null;
    }
  }

  @override
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      AppLogger.error('SecureStorage delete failed for key=$key', error: e);
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      AppLogger.error('SecureStorage deleteAll failed', error: e);
    }
  }

  @override
  Future<bool> containsKey({required String key}) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      AppLogger.error('SecureStorage containsKey failed for key=$key', error: e);
      return false;
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      AppLogger.error('SecureStorage readAll failed', error: e);
      return {};
    }
  }
}

/// Token manager — the single source of truth for auth tokens.
class TokenManager {
  TokenManager({required this.storage});

  final SecureStorageService storage;

  Future<String?> getAccessToken() =>
      storage.read(key: AppConstants.kAccessToken);

  Future<String?> getRefreshToken() =>
      storage.read(key: AppConstants.kRefreshToken);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      storage.write(key: AppConstants.kAccessToken, value: accessToken),
      storage.write(key: AppConstants.kRefreshToken, value: refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      storage.delete(key: AppConstants.kAccessToken),
      storage.delete(key: AppConstants.kRefreshToken),
    ]);
  }

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
