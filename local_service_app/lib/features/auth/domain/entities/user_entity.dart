import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.avatarUrl,
    this.isVerified = false,
    this.isActive = true,
    this.fcmToken,
    this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final String role; // customer | provider | admin
  final String? email;
  final String? avatarUrl;
  final bool isVerified;
  final bool isActive;
  final String? fcmToken;
  final DateTime? createdAt;

  bool get isCustomer => role == 'customer';
  bool get isProvider => role == 'provider';
  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [
        id, name, phone, role, email, avatarUrl,
        isVerified, isActive, fcmToken, createdAt,
      ];
}

class AuthTokenEntity extends Equatable {
  const AuthTokenEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserEntity user;

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
