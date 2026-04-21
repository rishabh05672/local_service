import 'package:dartz/dartz.dart';
import 'package:local_service_app/core/errors/failures.dart';
import 'package:local_service_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> sendOtp({required String phone});

  Future<Either<Failure, AuthTokenEntity>> verifyOtpAndLogin({
    required String phone,
    required String idToken,
  });

  Future<Either<Failure, AuthTokenEntity>> register({
    required String name,
    required String phone,
    required String idToken,
    required String role,
    String? email,
  });

  Future<Either<Failure, AuthTokenEntity>> refreshToken({
    required String refreshToken,
  });

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity>> updateProfile({
    required String name,
    String? email,
    String? avatarUrl,
  });
}
