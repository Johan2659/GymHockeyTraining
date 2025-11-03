import '../models/models.dart';

/// Repository for managing exercise performance data
abstract class ExercisePerformanceRepository {
  /// Save an exercise performance record
  Future<bool> save(ExercisePerformance performance);

  /// Get exercise performance by ID
  Future<ExercisePerformance?> getById(String id);

  /// Get all performances for a specific exercise
  Future<List<ExercisePerformance>> getByExerciseId(String exerciseId);

  /// Get all performances for a specific session
  Future<List<ExercisePerformance>> getBySession(
      String programId, int week, int session);

  /// Get the last performance for a specific exercise
  Future<ExercisePerformance?> getLastPerformance(String exerciseId);

  /// Get all performances
  Future<List<ExercisePerformance>> getAll();

  /// Delete a performance record
  Future<bool> delete(String id);

  /// Clear all performance data
  Future<bool> clear();
}
