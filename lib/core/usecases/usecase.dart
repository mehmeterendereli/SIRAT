import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for all UseCases in the app
/// Follows the Clean Architecture pattern for business logic.

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
