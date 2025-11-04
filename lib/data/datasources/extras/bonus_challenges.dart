import 'dart:convert';
import 'package:logger/logger.dart';
import '../../../core/models/models.dart';

/// Bonus challenge extras - achievement-based fitness challenges
class BonusChallengesData {
  static final _logger = Logger();

  // =============================================================================
  // BONUS CHALLENGES
  // =============================================================================

  static const Map<String, String> _bonusChallenges = {
    'challenge_100_pushups': '''
{
  "id": "challenge_100_pushups",
  "title": "100 Push-ups Challenge",
  "description": "Complete 100 push-ups in one session. Break them into sets as needed!",
  "type": "bonus_challenge",
  "xpReward": 100,
  "duration": 30,
  "difficulty": "hard",
  "blocks": [
    {"exerciseId": "push_ups_weighted"}
  ]
}
''',
    'challenge_plank_5min': '''
{
  "id": "challenge_plank_5min",
  "title": "5-Minute Plank Hold",
  "description": "Hold a plank position for 5 minutes total. Rest breaks allowed!",
  "type": "bonus_challenge",
  "xpReward": 80,
  "duration": 10,
  "difficulty": "medium",
  "blocks": [
    {"exerciseId": "side_plank_reach"}
  ]
}
''',
    'challenge_burpee_ladder': '''
{
  "id": "challenge_burpee_ladder",
  "title": "Burpee Ladder",
  "description": "Do 1 burpee, then 2, then 3... up to 10, then back down to 1",
  "type": "bonus_challenge",
  "xpReward": 120,
  "duration": 25,
  "difficulty": "hard",
  "blocks": [
    {"exerciseId": "burpee_intervals"}
  ]
}
''',
  };

  // =============================================================================
  // PUBLIC METHODS
  // =============================================================================

  /// Gets all bonus challenge extras
  static Future<List<ExtraItem>> getAllBonusChallenges() async {
    try {
      _logger.d('BonusChallengesData: Loading all bonus challenges');

      final extras = <ExtraItem>[];

      for (final entry in _bonusChallenges.entries) {
        final extra = await _loadExtra(entry.key, entry.value);
        if (extra != null) {
          extras.add(extra);
        }
      }

      _logger.i(
          'BonusChallengesData: Loaded ${extras.length} bonus challenges');
      return extras;
    } catch (e, stackTrace) {
      _logger.e('BonusChallengesData: Failed to load bonus challenges',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets a specific bonus challenge by ID
  static Future<ExtraItem?> getBonusChallengeById(String id) async {
    try {
      _logger.d('BonusChallengesData: Loading bonus challenge with ID: $id');

      final extraJson = _bonusChallenges[id];
      if (extraJson == null) {
        _logger.w('BonusChallengesData: Bonus challenge not found: $id');
        return null;
      }

      return await _loadExtra(id, extraJson);
    } catch (e, stackTrace) {
      _logger.e('BonusChallengesData: Failed to load bonus challenge $id',
          error: e, stackTrace: stackTrace);
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
          'BonusChallengesData: Successfully loaded bonus challenge: ${extra.title}');
      return extra;
    } catch (e, stackTrace) {
      _logger.e(
          'BonusChallengesData: Failed to parse extra JSON for $id',
          error: e,
          stackTrace: stackTrace);
      return null;
    }
  }
}
