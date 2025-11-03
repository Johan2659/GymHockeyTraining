import 'package:logger/logger.dart';
import '../../core/models/models.dart';
import '../../core/repositories/exercise_performance_repository.dart';
import '../datasources/local_exercise_performance_source.dart';

/// Implementation of ExercisePerformanceRepository using local data source
class ExercisePerformanceRepositoryImpl
    implements ExercisePerformanceRepository {
  final LocalExercisePerformanceSource _localSource;
  static final _logger = Logger();

  ExercisePerformanceRepositoryImpl({
    LocalExercisePerformanceSource? localSource,
  }) : _localSource = localSource ?? LocalExercisePerformanceSource();

  @override
  Future<bool> save(ExercisePerformance performance) async {
    try {
      _logger.d(
          'ExercisePerformanceRepositoryImpl: Saving performance: ${performance.id}');
      final success = await _localSource.savePerformance(performance);

      if (success) {
        _logger.i(
            'ExercisePerformanceRepositoryImpl: Successfully saved performance');
      } else {
        _logger
            .e('ExercisePerformanceRepositoryImpl: Failed to save performance');
      }

      return success;
    } catch (e, stackTrace) {
      _logger.e('ExercisePerformanceRepositoryImpl: Error saving performance',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<ExercisePerformance?> getById(String id) async {
    try {
      _logger.d('ExercisePerformanceRepositoryImpl: Getting performance: $id');
      return await _localSource.getPerformanceById(id);
    } catch (e, stackTrace) {
      _logger.e('ExercisePerformanceRepositoryImpl: Error getting performance',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<List<ExercisePerformance>> getByExerciseId(String exerciseId) async {
    try {
      _logger.d(
          'ExercisePerformanceRepositoryImpl: Getting performances for exercise: $exerciseId');
      return await _localSource.getPerformancesByExerciseId(exerciseId);
    } catch (e, stackTrace) {
      _logger.e(
          'ExercisePerformanceRepositoryImpl: Error getting performances by exercise ID',
          error: e,
          stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<ExercisePerformance>> getBySession(
      String programId, int week, int session) async {
    try {
      _logger.d(
          'ExercisePerformanceRepositoryImpl: Getting performances for session: $programId, week: $week, session: $session');
      return await _localSource.getPerformancesBySession(
          programId, week, session);
    } catch (e, stackTrace) {
      _logger.e(
          'ExercisePerformanceRepositoryImpl: Error getting performances by session',
          error: e,
          stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<ExercisePerformance?> getLastPerformance(String exerciseId) async {
    try {
      _logger.d(
          'ExercisePerformanceRepositoryImpl: Getting last performance for exercise: $exerciseId');
      final performances =
          await _localSource.getPerformancesByExerciseId(exerciseId);
      return performances.isNotEmpty ? performances.first : null;
    } catch (e, stackTrace) {
      _logger.e(
          'ExercisePerformanceRepositoryImpl: Error getting last performance',
          error: e,
          stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<List<ExercisePerformance>> getAll() async {
    try {
      _logger.d('ExercisePerformanceRepositoryImpl: Getting all performances');
      return await _localSource.getAllPerformances();
    } catch (e, stackTrace) {
      _logger.e(
          'ExercisePerformanceRepositoryImpl: Error getting all performances',
          error: e,
          stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      _logger.d('ExercisePerformanceRepositoryImpl: Deleting performance: $id');
      final success = await _localSource.deletePerformance(id);

      if (success) {
        _logger.i(
            'ExercisePerformanceRepositoryImpl: Successfully deleted performance');
      } else {
        _logger.e(
            'ExercisePerformanceRepositoryImpl: Failed to delete performance');
      }

      return success;
    } catch (e, stackTrace) {
      _logger.e('ExercisePerformanceRepositoryImpl: Error deleting performance',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> clear() async {
    try {
      _logger.d('ExercisePerformanceRepositoryImpl: Clearing all performances');
      final success = await _localSource.clearAll();

      if (success) {
        _logger.i(
            'ExercisePerformanceRepositoryImpl: Successfully cleared all performances');
      } else {
        _logger.e(
            'ExercisePerformanceRepositoryImpl: Failed to clear performances');
      }

      return success;
    } catch (e, stackTrace) {
      _logger.e(
          'ExercisePerformanceRepositoryImpl: Error clearing performances',
          error: e,
          stackTrace: stackTrace);
      return false;
    }
  }
}
