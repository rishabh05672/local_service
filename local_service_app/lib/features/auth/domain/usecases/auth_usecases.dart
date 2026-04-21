import 'package:dartz/dartz.dart';
import 'package:local_service_app/core/errors/failures.dart';
import 'package:local_service_app/core/utils/use_case.dart';
import 'package:local_service_app/features/auth/domain/entities/user_entity.dart';
import 'package:local_service_app/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase implements UseCase<AuthTokenEntity, VerifyOtpParams> {
  VerifyOtpUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, AuthTokenEntity>> call(VerifyOtpParams params) {
    return repository.verifyOtpAndLogin(
      phone: params.phone,
      idToken: params.idToken,
    );
  }
}

class VerifyOtpParams {
  const VerifyOtpParams({required this.phone, required this.idToken});
  final String phone;
  final String idToken;
}

// ──────────────────────────────────────────────────────────────────────────────

class RegisterUseCase implements UseCase<AuthTokenEntity, RegisterParams> {
  RegisterUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, AuthTokenEntity>> call(RegisterParams params) {
    return repository.register(
      name: params.name,
      phone: params.phone,
      idToken: params.idToken,
      role: params.role,
      email: params.email,
    );
  }
}

class RegisterParams {
  const RegisterParams({
    required this.name,
    required this.phone,
    required this.idToken,
    required this.role,
    this.email,
  });
  final String name;
  final String phone;
  final String idToken;
  final String role;
  final String? email;
}

// ──────────────────────────────────────────────────────────────────────────────

class GetCurrentUserUseCase implements UseCase<UserEntity, NoParams> {
  GetCurrentUserUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}

// ──────────────────────────────────────────────────────────────────────────────

class LogoutUseCase implements UseCase<void, NoParams> {
  LogoutUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
