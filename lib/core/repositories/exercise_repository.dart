import '../models/models.dart';

/// Repository interface for managing exercises
/// Provides access to exercise data and metadata
abstract class ExerciseRepository {
  /// Gets an exercise by its unique identifier
  /// Returns null if exercise is not found
  Future<Exercise?> getById(String id);

  /// Gets all exercises in a specific category
  Future<List<Exercise>> getByCategory(String category);

  /// Gets all available exercises
  Future<List<Exercise>> getAll();

  /// Searches exercises by name or description
  Future<List<Exercise>> search(String query);
}
