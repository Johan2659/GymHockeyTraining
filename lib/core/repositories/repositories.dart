/// Base repository interfaces for the Hockey Gym app
library;

/// Base repository interface
abstract class Repository {
  // TODO: Add common repository methods
}

/// User repository interface
abstract class UserRepository extends Repository {
  // TODO: Add user-related methods
  // - Get user profile
  // - Update user profile
  // - Save user preferences
}

/// Program repository interface
abstract class ProgramRepository extends Repository {
  // TODO: Add program-related methods
  // - Get available programs
  // - Save program progress
  // - Create custom programs
}

/// Progress repository interface
abstract class ProgressRepository extends Repository {
  // TODO: Add progress-related methods
  // - Save progress events
  // - Get progress history
  // - Generate reports
}

// TODO: Add more repository interfaces as needed
