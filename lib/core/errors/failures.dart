/// Failure base class for error handling
abstract class Failure {
  const Failure(this.message);
  
  final String message;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure && 
      runtimeType == other.runtimeType &&
      message == other.message;
  
  @override
  int get hashCode => message.hashCode;
}

/// Repository failures
class RepositoryFailure extends Failure {
  const RepositoryFailure(super.message);
}

/// Storage failures
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// TODO: Add more specific failure types as needed
