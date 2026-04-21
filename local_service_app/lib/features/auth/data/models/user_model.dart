import 'package:local_service_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.role,
    super.email,
    super.avatarUrl,
    super.isVerified,
    super.isActive,
    super.fcmToken,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        role: json['role'] as String,
        email: json['email'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        isVerified: json['isVerified'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
        fcmToken: json['fcmToken'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'role': role,
        'email': email,
        'avatarUrl': avatarUrl,
        'isVerified': isVerified,
        'isActive': isActive,
        'fcmToken': fcmToken,
        'createdAt': createdAt?.toIso8601String(),
      };
}

// ──────────────────────────────────────────────────────────────────────────────

class AuthResponseModel {
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserModel user;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}
