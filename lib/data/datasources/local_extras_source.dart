import 'dart:convert';
import 'package:logger/logger.dart';
import '../../core/models/models.dart';

/// Local data source for static extras definitions
/// Loads extras from embedded JSON data
class LocalExtrasSource {
  static final _logger = Logger();

  // Static extras data - Express Workouts
  static const String _expressWorkoutsJson = '''
[
  {
    "id": "express_cardio_15",
    "title": "15-Min Cardio Blast",
    "description": "High-intensity cardio circuit to boost endurance and agility",
    "type": "express_workout",
    "xpReward": 50,
    "duration": 15,
    "difficulty": "medium",
    "blocks": [
      {"exerciseId": "jumping_jacks"},
      {"exerciseId": "burpees"},
      {"exerciseId": "mountain_climbers"},
      {"exerciseId": "high_knees"}
    ]
  },
  {
    "id": "express_strength_20",
    "title": "20-Min Strength Circuit",
    "description": "Full-body strength workout for hockey power development",
    "type": "express_workout",
    "xpReward": 75,
    "duration": 20,
    "difficulty": "hard",
    "blocks": [
      {"exerciseId": "push_ups"},
      {"exerciseId": "squats"},
      {"exerciseId": "lunges"},
      {"exerciseId": "plank"},
      {"exerciseId": "russian_twists"}
    ]
  },
  {
    "id": "express_agility_15",
    "title": "15-Min Agility Focus",
    "description": "Quick agility and coordination drills for better on-ice movement",
    "type": "express_workout",
    "xpReward": 60,
    "duration": 15,
    "difficulty": "easy",
    "blocks": [
      {"exerciseId": "ladder_drills"},
      {"exerciseId": "cone_weaves"},
      {"exerciseId": "lateral_shuffles"},
      {"exerciseId": "quick_feet"}
    ]
  }
]
''';

  // Static extras data - Bonus Challenges
  static const String _bonusChallengesJson = '''
[
  {
    "id": "challenge_100_pushups",
    "title": "100 Push-ups Challenge",
    "description": "Complete 100 push-ups in one session. Break them into sets as needed!",
    "type": "bonus_challenge",
    "xpReward": 100,
    "duration": 30,
    "difficulty": "hard",
    "blocks": [
      {"exerciseId": "push_ups"}
    ]
  },
  {
    "id": "challenge_plank_5min",
    "title": "5-Minute Plank Hold",
    "description": "Hold a plank position for 5 minutes total. Rest breaks allowed!",
    "type": "bonus_challenge",
    "xpReward": 80,
    "duration": 10,
    "difficulty": "medium",
    "blocks": [
      {"exerciseId": "plank"}
    ]
  },
  {
    "id": "challenge_burpee_ladder",
    "title": "Burpee Ladder",
    "description": "Do 1 burpee, then 2, then 3... up to 10, then back down to 1",
    "type": "bonus_challenge",
    "xpReward": 120,
    "duration": 25,
    "difficulty": "hard",
    "blocks": [
      {"exerciseId": "burpees"}
    ]
  }
]
''';

  // Static extras data - Mobility & Recovery
  static const String _mobilityRecoveryJson = '''
[
  {
    "id": "mobility_hip_flow",
    "title": "Hip Mobility Flow",
    "description": "Essential hip stretches and mobility work for hockey players",
    "type": "mobility_recovery",
    "xpReward": 25,
    "duration": 10,
    "difficulty": "easy",
    "blocks": [
      {"exerciseId": "hip_circles"},
      {"exerciseId": "leg_swings"},
      {"exerciseId": "hip_flexor_stretch"},
      {"exerciseId": "pigeon_stretch"}
    ]
  },
  {
    "id": "mobility_ankle_prep",
    "title": "Ankle Preparation",
    "description": "Pre-skate ankle mobility and strengthening routine",
    "type": "mobility_recovery",
    "xpReward": 20,
    "duration": 8,
    "difficulty": "easy",
    "blocks": [
      {"exerciseId": "ankle_circles"},
      {"exerciseId": "calf_raises"},
      {"exerciseId": "ankle_dorsiflexion"},
      {"exerciseId": "toe_raises"}
    ]
  },
  {
    "id": "mobility_cool_down",
    "title": "Post-Training Cool Down",
    "description": "Full-body stretching sequence for recovery",
    "type": "mobility_recovery",
    "xpReward": 30,
    "duration": 15,
    "difficulty": "easy",
    "blocks": [
      {"exerciseId": "quad_stretch"},
      {"exerciseId": "hamstring_stretch"},
      {"exerciseId": "shoulder_stretch"},
      {"exerciseId": "back_stretch"},
      {"exerciseId": "neck_rolls"}
    ]
  }
]
''';

  /// Gets all available extras
  Future<List<ExtraItem>> getAllExtras() async {
    try {
      _logger.d('LocalExtrasSource: Loading all extras');

      final extras = <ExtraItem>[];

      // Load express workouts
      final expressWorkouts = await _loadExpressWorkouts();
      extras.addAll(expressWorkouts);

      // Load bonus challenges
      final bonusChallenges = await _loadBonusChallenges();
      extras.addAll(bonusChallenges);

      // Load mobility & recovery
      final mobilityRecovery = await _loadMobilityRecovery();
      extras.addAll(mobilityRecovery);

      _logger.d('LocalExtrasSource: Loaded ${extras.length} extras');
      return extras;
    } catch (e, stackTrace) {
      _logger.e('LocalExtrasSource: Failed to load extras',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Gets extras by type
  Future<List<ExtraItem>> getExtrasByType(ExtraType type) async {
    final allExtras = await getAllExtras();
    return allExtras.where((extra) => extra.type == type).toList();
  }

  /// Gets a specific extra by ID
  Future<ExtraItem?> getExtraById(String id) async {
    final allExtras = await getAllExtras();
    try {
      return allExtras.firstWhere((extra) => extra.id == id);
    } catch (e) {
      _logger.w('LocalExtrasSource: Extra not found with id: $id');
      return null;
    }
  }

  Future<List<ExtraItem>> _loadExpressWorkouts() async {
    try {
      final List<dynamic> jsonList = json.decode(_expressWorkoutsJson);
      return jsonList
          .map((json) => ExtraItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      _logger.e('LocalExtrasSource: Failed to parse express workouts JSON',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<List<ExtraItem>> _loadBonusChallenges() async {
    try {
      final List<dynamic> jsonList = json.decode(_bonusChallengesJson);
      return jsonList
          .map((json) => ExtraItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      _logger.e('LocalExtrasSource: Failed to parse bonus challenges JSON',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<List<ExtraItem>> _loadMobilityRecovery() async {
    try {
      final List<dynamic> jsonList = json.decode(_mobilityRecoveryJson);
      return jsonList
          .map((json) => ExtraItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      _logger.e('LocalExtrasSource: Failed to parse mobility & recovery JSON',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }
}
