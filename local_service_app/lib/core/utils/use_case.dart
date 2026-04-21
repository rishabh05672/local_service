import 'package:dartz/dartz.dart';
import 'package:local_service_app/core/errors/failures.dart';

/// Base use case contract — all use cases implement this.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// For use cases with no parameters.
class NoParams {
  const NoParams();
}
