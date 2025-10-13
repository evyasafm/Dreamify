import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Insufficient credits failure
class InsufficientCreditsFailure extends Failure {
  const InsufficientCreditsFailure(super.message);
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Local storage failure
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Permission denied failure
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Cancellation failure
class CancellationFailure extends Failure {
  const CancellationFailure(super.message);
}

/// Generic failure
class GenericFailure extends Failure {
  const GenericFailure(super.message);
}
