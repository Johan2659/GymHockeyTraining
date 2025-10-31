import 'package:logger/logger.dart';
import '../../core/models/models.dart';
import '../../core/repositories/exercise_repository.dart';
import '../datasources/local_exercise_source.dart';

/// Implementation of ExerciseRepository using local data source
class ExerciseRepositoryImpl implements ExerciseRepository {
  final LocalExerciseSource _localSource;
  static final _logger = Logger();

  ExerciseRepositoryImpl({
    LocalExerciseSource? localSource,
  }) : _localSource = localSource ?? LocalExerciseSource();

  @override
  Future<Exercise?> getById(String id) async {
    try {
      _logger.d('ExerciseRepositoryImpl: Getting exercise by ID: $id');

      final exercise = await _localSource.getExerciseById(id);

      if (exercise != null) {
        _logger.i('ExerciseRepositoryImpl: Found exercise: ${exercise.name}');
      } else {
        _logger.w('ExerciseRepositoryImpl: Exercise not found: $id');
      }

      return exercise;
    } catch (e, stackTrace) {
      _logger.e('ExerciseRepositoryImpl: Failed to get exercise $id',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<List<Exercise>> getByCategory(String category) async {
    try {
      _logger.d(
          'ExerciseRepositoryImpl: Getting exercises for category: $category');

      final exercises = await _localSource.getExercisesByCategory(category);

      _logger.i(
          'ExerciseRepositoryImpl: Found ${exercises.length} exercises for category $category');
      return exercises;
    } catch (e, stackTrace) {
      _logger.e(
          'ExerciseRepositoryImpl: Failed to get exercises for category $category',
          error: e,
          stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<Exercise>> getAll() async {
    try {
      _logger.d('ExerciseRepositoryImpl: Getting all exercises');

      final exercises = await _localSource.getAllExercises();

      _logger.i(
          'ExerciseRepositoryImpl: Found ${exercises.length} total exercises');
      return exercises;
    } catch (e, stackTrace) {
      _logger.e('ExerciseRepositoryImpl: Failed to get all exercises',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<Exercise>> search(String query) async {
    try {
      _logger
          .d('ExerciseRepositoryImpl: Searching exercises with query: $query');

      final exercises = await _localSource.searchExercises(query);

      _logger.i(
          'ExerciseRepositoryImpl: Found ${exercises.length} exercises matching query');
      return exercises;
    } catch (e, stackTrace) {
      _logger.e('ExerciseRepositoryImpl: Failed to search exercises',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }
}
