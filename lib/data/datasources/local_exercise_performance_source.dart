import 'package:hive_flutter/hive_flutter.dart';
import '../../core/logging/logger_config.dart';
import '../../core/models/models.dart';
import '../../core/storage/hive_boxes.dart';

/// Local data source for exercise performance using Hive
class LocalExercisePerformanceSource {
  static final _logger = AppLogger.getLogger();

  /// Save an exercise performance record
  Future<bool> savePerformance(ExercisePerformance performance) async {
    try {
      Box<dynamic> box;
      if (Hive.isBoxOpen(HiveBoxes.exercisePerformance)) {
        box = Hive.box(HiveBoxes.exercisePerformance);
      } else {
        box = await Hive.openBox(HiveBoxes.exercisePerformance);
      }

      await box.put(performance.id, performance.toJson());
      _logger.d(
          'LocalExercisePerformanceSource: Saved performance: ${performance.id}');
      return true;
    } catch (e, stackTrace) {
      _logger.e('LocalExercisePerformanceSource: Failed to save performance',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Get exercise performance by ID
  Future<ExercisePerformance?> getPerformanceById(String id) async {
    try {
      Box<dynamic> box;
      if (Hive.isBoxOpen(HiveBoxes.exercisePerformance)) {
        box = Hive.box(HiveBoxes.exercisePerformance);
      } else {
        box = await Hive.openBox(HiveBoxes.exercisePerformance);
      }

      final data = box.get(id);
      if (data == null) return null;

      if (data is Map) {
        return ExercisePerformance.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e, stackTrace) {
      _logger.e('LocalExercisePerformanceSource: Failed to get performance',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get all performances for a specific exercise
  Future<List<ExercisePerformance>> getPerformancesByExerciseId(
      String exerciseId) async {
    try {
      Box<dynamic> box;
      if (Hive.isBoxOpen(HiveBoxes.exercisePerformance)) {
        box = Hive.box(HiveBoxes.exercisePerformance);
      } else {
        box = await Hive.openBox(HiveBoxes.exercisePerformance);
      }

      final performances = <ExercisePerformance>[];

      for (final data in box.values) {
        if (data is Map) {
          final performance =
              ExercisePerformance.fromJson(Map<String, dynamic>.from(data));
          if (performance.exerciseId == exerciseId) {
            performances.add(performance);
          }
        }
      }

      // Sort by timestamp, most recent first
      performances.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return performances;
    } catch (e, stackTrace) {
      _logger.e(
          'LocalExercisePerformanceSource: Failed to get performances by exercise ID',
          error: e,
          stackTrace: stackTrace);
      return [];
    }
  }

  /// Get all performances for a specific session
  Future<List<ExercisePerformance>> getPerformancesBySession(
      String programId, int week, int session) async {
    try {
      Box<dynamic> box;
      if (Hive.isBoxOpen(HiveBoxes.exercisePerformance)) {
        box = Hive.box(HiveBoxes.exercisePerformance);
      } else {
        box = await Hive.openBox(HiveBoxes.exercisePerformance);
      }

      final performances = <ExercisePerformance>[];

      for (final data in box.values) {
        if (data is Map) {
          final performance =
              ExercisePerformance.fromJson(Map<String, dynamic>.from(data));
          if (performance.programId == programId &&
              performance.week == week &&
              performance.session == session) {
            performances.add(performance);
          }
        }
      }

      return performances;
    } catch (e, stackTrace) {
      _logger.e(
          'LocalExercisePerformanceSource: Failed to get performances by session',
          error: e,
          stackTrace: stackTrace);
      return [];
    }
  }

  /// Get all performance records
  Future<List<ExercisePerformance>> getAllPerformances() async {
    try {
      // Check if box is already open, if so use it, otherwise open it
      Box<dynamic> box;
      if (Hive.isBoxOpen(HiveBoxes.exercisePerformance)) {
        box = Hive.box(HiveBoxes.exercisePerformance);
      } else {
        box = await Hive.openBox(HiveBoxes.exercisePerformance);
      }

      final performances = <ExercisePerformance>[];

      for (final data in box.values) {
        if (data is Map) {
          performances.add(
              ExercisePerformance.fromJson(Map<String, dynamic>.from(data)));
        }
      }

      // Sort by timestamp, most recent first
      performances.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return performances;
    } catch (e, stackTrace) {
      _logger.e(
          'LocalExercisePerformanceSource: Failed to get all performances',
          error: e,
          stackTrace: stackTrace);
      return [];
    }
  }

  /// Delete a performance record
  Future<bool> deletePerformance(String id) async {
    try {
      Box<dynamic> box;
      if (Hive.isBoxOpen(HiveBoxes.exercisePerformance)) {
        box = Hive.box(HiveBoxes.exercisePerformance);
      } else {
        box = await Hive.openBox(HiveBoxes.exercisePerformance);
      }

      await box.delete(id);
      _logger.d('LocalExercisePerformanceSource: Deleted performance: $id');
      return true;
    } catch (e, stackTrace) {
      _logger.e('LocalExercisePerformanceSource: Failed to delete performance',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Clear all performance data
  Future<bool> clearAll() async {
    try {
      Box<dynamic> box;
      if (Hive.isBoxOpen(HiveBoxes.exercisePerformance)) {
        box = Hive.box(HiveBoxes.exercisePerformance);
      } else {
        box = await Hive.openBox(HiveBoxes.exercisePerformance);
      }

      await box.clear();
      _logger.d('LocalExercisePerformanceSource: Cleared all performances');
      return true;
    } catch (e, stackTrace) {
      _logger.e('LocalExercisePerformanceSource: Failed to clear performances',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
