import '../../core/logging/logger_config.dart';
import '../../core/models/models.dart';
import 'hockey_exercises_database.dart';

/// Local data source for exercises using comprehensive hockey database
/// Provides exercise definitions with metadata
class LocalExerciseSource {
  static final _logger = AppLogger.getLogger();

  /// Gets all available exercises
  Future<List<Exercise>> getAllExercises() async {
    try {
      _logger.d('LocalExerciseSource: Loading all exercises from database');
      return await HockeyExercisesDatabase.getAllExercises();
    } catch (e, stackTrace) {
      _logger.e('LocalExerciseSource: Failed to load exercises',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets a specific exercise by ID
  Future<Exercise?> getExerciseById(String id) async {
    try {
      _logger.d('LocalExerciseSource: Loading exercise with ID: $id');
      return await HockeyExercisesDatabase.getExerciseById(id);
    } catch (e, stackTrace) {
      _logger.e('LocalExerciseSource: Failed to load exercise $id',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Gets exercises by category
  Future<List<Exercise>> getExercisesByCategory(String category) async {
    try {
      _logger
          .d('LocalExerciseSource: Loading exercises for category: $category');

      // Convert string to enum
      final categoryEnum = ExerciseCategory.values.firstWhere(
        (cat) => cat.name.toLowerCase() == category.toLowerCase(),
        orElse: () => ExerciseCategory.strength,
      );

      return await HockeyExercisesDatabase.getExercisesByCategory(categoryEnum);
    } catch (e, stackTrace) {
      _logger.e(
          'LocalExerciseSource: Failed to load exercises for category $category',
          error: e,
          stackTrace: stackTrace);
      return [];
    }
  }

  /// Searches exercises by query
  Future<List<Exercise>> searchExercises(String query) async {
    try {
      _logger.d('LocalExerciseSource: Searching exercises with query: $query');
      return await HockeyExercisesDatabase.searchExercises(query);
    } catch (e, stackTrace) {
      _logger.e('LocalExerciseSource: Failed to search exercises',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }
}
