import '../models/models.dart';

/// Repository interface for managing program execution state
/// Tracks user's current progress through training programs
abstract class ProgramStateRepository {
  /// Gets the current program state for the user
  /// Returns null if no active program state exists
  Future<ProgramState?> get();

  /// Saves the program state
  /// Returns true if successful, false otherwise
  Future<bool> save(ProgramState state);

  /// Watches the program state for changes
  /// Useful for reactive UI updates when state changes
  Stream<ProgramState?> watch();

  /// Clears the current program state
  /// Used when user completes or abandons a program
  Future<bool> clear();

  /// Updates specific fields in the program state
  /// More efficient than loading, modifying, and saving entire state
  Future<bool> updateCurrentWeek(int week);
  Future<bool> updateCurrentSession(int session);
  Future<bool> addCompletedExercise(String exerciseId);
  Future<bool> removeCompletedExercise(String exerciseId);
  Future<bool> pauseProgram();
  Future<bool> resumeProgram();

  /// Session in progress management
  Future<bool> saveSessionInProgress(SessionInProgress session);
  Future<bool> clearSessionInProgress();
  Future<SessionInProgress?> getSessionInProgress();
}
