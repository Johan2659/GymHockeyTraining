import 'dart:convert';
import '../../../core/logging/logger_config.dart';
import '../../../core/models/models.dart';

/// Express workout extras - quick 15-20 minute training sessions
class ExpressWorkoutsData {
  static final _logger = AppLogger.getLogger();

  // =============================================================================
  // EXPRESS WORKOUTS
  // =============================================================================

  static const Map<String, String> _expressWorkouts = {
    'express_cardio_15': '''
{
  "id": "express_cardio_15",
  "title": "15-Min Cardio Blast",
  "description": "High-intensity cardio circuit to boost endurance and agility",
  "type": "express_workout",
  "xpReward": 50,
  "duration": 15,
  "difficulty": "medium",
  "blocks": [
    {"exerciseId": "high_knees_intervals"},
    {"exerciseId": "bike_intervals_20_40"},
    {"exerciseId": "burpee_intervals"},
    {"exerciseId": "jump_squat"}
  ]
}
''',
    'express_strength_20': '''
{
  "id": "express_strength_20",
  "title": "20-Min Strength Circuit",
  "description": "Full-body strength workout for hockey power development",
  "type": "express_workout",
  "xpReward": 75,
  "duration": 20,
  "difficulty": "hard",
  "blocks": [
    {"exerciseId": "dynamic_warmup_ramp"},
    {"exerciseId": "goblet_squat"},
    {"exerciseId": "bench_press"},
    {"exerciseId": "side_plank_reach"},
    {"exerciseId": "bike_intervals_15_45"}
  ]
}
''',
    'express_agility_15': '''
{
  "id": "express_agility_15",
  "title": "15-Min Agility Focus",
  "description": "Quick agility and coordination drills for better on-ice movement",
  "type": "express_workout",
  "xpReward": 60,
  "duration": 15,
  "difficulty": "easy",
  "blocks": [
    {"exerciseId": "ladder_footwork"},
    {"exerciseId": "five_ten_five_shuttle"},
    {"exerciseId": "skater_bounds"},
    {"exerciseId": "pallof_press_rotation"}
  ]
}
''',
  };

  // =============================================================================
  // PUBLIC METHODS
  // =============================================================================

  /// Gets all express workout extras
  static Future<List<ExtraItem>> getAllExpressWorkouts() async {
    try {
      _logger.d('ExpressWorkoutsData: Loading all express workouts');

      final extras = <ExtraItem>[];

      for (final entry in _expressWorkouts.entries) {
        final extra = await _loadExtra(entry.key, entry.value);
        if (extra != null) {
          extras.add(extra);
        }
      }

      _logger.i(
          'ExpressWorkoutsData: Loaded ${extras.length} express workouts');
      return extras;
    } catch (e, stackTrace) {
      _logger.e('ExpressWorkoutsData: Failed to load express workouts',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets a specific express workout by ID
  static Future<ExtraItem?> getExpressWorkoutById(String id) async {
    try {
      _logger
          .d('ExpressWorkoutsData: Loading express workout with ID: $id');

      final extraJson = _expressWorkouts[id];
      if (extraJson == null) {
        _logger.w('ExpressWorkoutsData: Express workout not found: $id');
        return null;
      }

      return await _loadExtra(id, extraJson);
    } catch (e, stackTrace) {
      _logger.e(
          'ExpressWorkoutsData: Failed to load express workout $id',
          error: e,
          stackTrace: stackTrace);
      return null;
    }
  }

  // =============================================================================
  // PRIVATE METHODS
  // =============================================================================

  /// Loads an extra from JSON string
  static Future<ExtraItem?> _loadExtra(String id, String jsonString) async {
    try {
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final extra = ExtraItem.fromJson(jsonData);

      _logger.d(
          'ExpressWorkoutsData: Successfully loaded express workout: ${extra.title}');
      return extra;
    } catch (e, stackTrace) {
      _logger.e(
          'ExpressWorkoutsData: Failed to parse extra JSON for $id',
          error: e,
          stackTrace: stackTrace);
      return null;
    }
  }
}
