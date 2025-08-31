import '../models/models.dart';

/// Repository interface for managing training sessions
/// Provides access to session data and exercises
abstract class SessionRepository {
  /// Gets a session by its unique identifier
  /// Returns null if session is not found
  Future<Session?> getById(String id);

  /// Gets all sessions for a specific program
  Future<List<Session>> getByProgramId(String programId);

  /// Gets all sessions for a specific week in a program
  Future<List<Session>> getByWeek(String programId, int week);
}
