import 'dart:convert';
import '../../../core/logging/logger_config.dart';
import '../../../core/models/models.dart';

/// Mobility and recovery extras - stretching and mobility work
class MobilityRecoveryData {
  static final _logger = AppLogger.getLogger();

  // =============================================================================
  // MOBILITY & RECOVERY
  // =============================================================================

  static const Map<String, String> _mobilityRecovery = {
    'mobility_hip_flow': '''
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
}
''',
    'mobility_ankle_prep': '''
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
}
''',
    'mobility_cool_down': '''
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
''',
  };

  // =============================================================================
  // PUBLIC METHODS
  // =============================================================================

  /// Gets all mobility and recovery extras
  static Future<List<ExtraItem>> getAllMobilityRecovery() async {
    try {
      _logger.d('MobilityRecoveryData: Loading all mobility/recovery extras');

      final extras = <ExtraItem>[];

      for (final entry in _mobilityRecovery.entries) {
        final extra = await _loadExtra(entry.key, entry.value);
        if (extra != null) {
          extras.add(extra);
        }
      }

      _logger.i(
          'MobilityRecoveryData: Loaded ${extras.length} mobility/recovery extras');
      return extras;
    } catch (e, stackTrace) {
      _logger.e(
          'MobilityRecoveryData: Failed to load mobility/recovery extras',
          error: e,
          stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets a specific mobility/recovery extra by ID
  static Future<ExtraItem?> getMobilityRecoveryById(String id) async {
    try {
      _logger.d(
          'MobilityRecoveryData: Loading mobility/recovery extra with ID: $id');

      final extraJson = _mobilityRecovery[id];
      if (extraJson == null) {
        _logger
            .w('MobilityRecoveryData: Mobility/recovery extra not found: $id');
        return null;
      }

      return await _loadExtra(id, extraJson);
    } catch (e, stackTrace) {
      _logger.e(
          'MobilityRecoveryData: Failed to load mobility/recovery extra $id',
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
          'MobilityRecoveryData: Successfully loaded mobility/recovery extra: ${extra.title}');
      return extra;
    } catch (e, stackTrace) {
      _logger.e(
          'MobilityRecoveryData: Failed to parse extra JSON for $id',
          error: e,
          stackTrace: stackTrace);
      return null;
    }
  }
}
