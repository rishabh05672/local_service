import 'package:local_service_app/core/network/api_client.dart';
import 'package:local_service_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<String> sendOtp({required String phone});
  Future<AuthResponseModel> verifyOtpAndLogin({
    required String phone,
    required String idToken,
  });
  Future<AuthResponseModel> register({
    required String name,
    required String phone,
    required String idToken,
    required String role,
    String? email,
  });
  Future<AuthResponseModel> refreshToken({required String refreshToken});
  Future<UserModel> getCurrentUser();
  Future<void> logout({required String fcmToken});
  Future<UserModel> updateProfile({
    required String name,
    String? email,
    String? avatarUrl,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<String> sendOtp({required String phone}) async {
    final res = await apiClient.post('/auth/send-otp', data: {'phone': phone});
    // ✅ Fixed: ResponseInterceptor wraps as {data, message, statusCode}
    // The message from controller is inside data.message
    final data = res.data['data'];
    if (data is Map) {
      return data['message']?.toString() ?? 'OTP sent successfully';
    }
    return res.data['message']?.toString() ?? 'OTP sent successfully';
  }

  @override
  Future<AuthResponseModel> verifyOtpAndLogin({
    required String phone,
    required String idToken,
  }) async {
    final res = await apiClient.post('/auth/verify-login', data: {
      'phone': phone,
      'idToken': idToken,
    });
    return AuthResponseModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String phone,
    required String idToken,
    required String role,
    String? email,
  }) async {
    final res = await apiClient.post('/auth/register', data: {
      'name': name,
      'phone': phone,
      'idToken': idToken,
      'role': role,
      if (email != null && email.isNotEmpty) 'email': email,
    });
    return AuthResponseModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> refreshToken({required String refreshToken}) async {
    final res = await apiClient.post('/auth/refresh', data: {
      'refreshToken': refreshToken,
    });
    return AuthResponseModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final res = await apiClient.get('/users/me');
    return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout({required String fcmToken}) async {
    await apiClient.post('/auth/logout', data: {'fcmToken': fcmToken});
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    String? email,
    String? avatarUrl,
  }) async {
    final res = await apiClient.put('/users/me', data: {
      'name': name,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    });
    return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
