import 'package:dartz/dartz.dart';
import 'package:local_service_app/core/errors/failures.dart';
import 'package:local_service_app/core/utils/use_case.dart';
import 'package:local_service_app/features/auth/domain/repositories/auth_repository.dart';

class SendOtpUseCase implements UseCase<String, SendOtpParams> {
  SendOtpUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, String>> call(SendOtpParams params) {
    return repository.sendOtp(phone: params.phone);
  }
}

class SendOtpParams {
  const SendOtpParams({required this.phone});
  final String phone;
}
