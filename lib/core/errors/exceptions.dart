/// Custom exceptions for the Hockey Gym app
class HockeyGymException implements Exception {
  const HockeyGymException(this.message);

  final String message;

  @override
  String toString() => 'HockeyGymException: $message';
}

/// Repository exceptions
class RepositoryException extends HockeyGymException {
  const RepositoryException(super.message);
}

/// Storage exceptions
class StorageException extends HockeyGymException {
  const StorageException(super.message);
}

/// Network exceptions
class NetworkException extends HockeyGymException {
  const NetworkException(super.message);
}

/// Validation exceptions
class ValidationException extends HockeyGymException {
  const ValidationException(super.message);
}

// TODO: Add more specific exception types as needed
