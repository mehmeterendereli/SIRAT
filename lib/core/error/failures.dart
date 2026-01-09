import 'package:equatable/equatable.dart';

/// Base Failure class for the Domain layer
abstract class Failure extends Equatable {
  final String message;
  const Failure([this.message = 'An unexpected error occurred.']);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server connection failed.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache access failed.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Location access failed.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Required permissions missing.']);
}
