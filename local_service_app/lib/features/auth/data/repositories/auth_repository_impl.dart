import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:local_service_app/core/errors/failures.dart';
import 'package:local_service_app/core/security/secure_storage_service.dart';
import 'package:local_service_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:local_service_app/features/auth/domain/entities/user_entity.dart';
import 'package:local_service_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenManager,
  });

  final AuthRemoteDataSource remoteDataSource;
  final TokenManager tokenManager;

  @override
  Future<Either<Failure, String>> sendOtp({required String phone}) async {
    try {
      final msg = await remoteDataSource.sendOtp(phone: phone);
      return Right(msg);
    } on DioException catch (e) {
      return Left(e.error is Failure ? e.error as Failure : NetworkFailure(message: e.message ?? 'Network error'));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, AuthTokenEntity>> verifyOtpAndLogin({
    required String phone,
    required String idToken,
  }) async {
    try {
      final model = await remoteDataSource.verifyOtpAndLogin(phone: phone, idToken: idToken);
      await tokenManager.saveTokens(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
      );
      return Right(AuthTokenEntity(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
        user: model.user,
      ));
    } on DioException catch (e) {
      return Left(e.error is Failure ? e.error as Failure : NetworkFailure(message: e.message ?? 'Network error'));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, AuthTokenEntity>> register({
    required String name,
    required String phone,
    required String idToken,
    required String role,
    String? email,
  }) async {
    try {
      final model = await remoteDataSource.register(
        name: name, phone: phone, idToken: idToken, role: role, email: email,
      );
      await tokenManager.saveTokens(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
      );
      return Right(AuthTokenEntity(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
        user: model.user,
      ));
    } on DioException catch (e) {
      return Left(e.error is Failure ? e.error as Failure : NetworkFailure(message: e.message ?? 'Network error'));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, AuthTokenEntity>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final model = await remoteDataSource.refreshToken(refreshToken: refreshToken);
      await tokenManager.saveTokens(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
      );
      return Right(AuthTokenEntity(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
        user: model.user,
      ));
    } on DioException catch (e) {
      return Left(e.error is Failure ? e.error as Failure : NetworkFailure(message: e.message ?? 'Network error'));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on DioException catch (e) {
      return Left(e.error is Failure ? e.error as Failure : NetworkFailure(message: e.message ?? 'Network error'));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout(fcmToken: '');
      await tokenManager.clearTokens();
      return const Right(null);
    } catch (_) {
      await tokenManager.clearTokens();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String name,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      final user = await remoteDataSource.updateProfile(
        name: name, email: email, avatarUrl: avatarUrl,
      );
      return Right(user);
    } on DioException catch (e) {
      return Left(e.error is Failure ? e.error as Failure : NetworkFailure(message: e.message ?? 'Network error'));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
