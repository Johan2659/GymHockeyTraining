import '../../core/logging/logger_config.dart';
import '../../core/models/models.dart';
import 'extras/express_workouts.dart';
import 'extras/bonus_challenges.dart';
import 'extras/mobility_recovery.dart';

/// Central database for all extras (express workouts, challenges, mobility)
/// Organized by category similar to program structure
class ExtrasDatabase {
  static final _logger = AppLogger.getLogger();

  // =============================================================================
  // PUBLIC METHODS
  // =============================================================================

  /// Gets all extras from all categories
  static Future<List<ExtraItem>> getAllExtras() async {
    try {
      _logger.d('ExtrasDatabase: Loading all extras from all categories');

      final allExtras = <ExtraItem>[];

      // Load from all category sources
      final expressWorkouts = await ExpressWorkoutsData.getAllExpressWorkouts();
      final bonusChallenges = await BonusChallengesData.getAllBonusChallenges();
      final mobilityRecovery =
          await MobilityRecoveryData.getAllMobilityRecovery();

      allExtras.addAll(expressWorkouts);
      allExtras.addAll(bonusChallenges);
      allExtras.addAll(mobilityRecovery);

      _logger.i('ExtrasDatabase: Loaded ${allExtras.length} total extras');
      _logger.d(
          'ExtrasDatabase: ${expressWorkouts.length} express workouts, '
          '${bonusChallenges.length} bonus challenges, '
          '${mobilityRecovery.length} mobility/recovery');

      return allExtras;
    } catch (e, stackTrace) {
      _logger.e('ExtrasDatabase: Failed to load extras',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets extras filtered by type
  static Future<List<ExtraItem>> getExtrasByType(ExtraType type) async {
    try {
      _logger.d('ExtrasDatabase: Loading extras for type: ${type.name}');

      List<ExtraItem> extras;

      switch (type) {
        case ExtraType.expressWorkout:
          extras = await ExpressWorkoutsData.getAllExpressWorkouts();
          break;
        case ExtraType.bonusChallenge:
          extras = await BonusChallengesData.getAllBonusChallenges();
          break;
        case ExtraType.mobilityRecovery:
          extras = await MobilityRecoveryData.getAllMobilityRecovery();
          break;
      }

      _logger.d(
          'ExtrasDatabase: Found ${extras.length} extras for type ${type.name}');
      return extras;
    } catch (e, stackTrace) {
      _logger.e('ExtrasDatabase: Failed to load extras for type ${type.name}',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets a specific extra by ID
  static Future<ExtraItem?> getExtraById(String id) async {
    try {
      _logger.d('ExtrasDatabase: Loading extra with ID: $id');

      // Try loading from each category source
      ExtraItem? extra;

      extra = await ExpressWorkoutsData.getExpressWorkoutById(id);
      if (extra != null) return extra;

      extra = await BonusChallengesData.getBonusChallengeById(id);
      if (extra != null) return extra;

      extra = await MobilityRecoveryData.getMobilityRecoveryById(id);
      if (extra != null) return extra;

      _logger.w('ExtrasDatabase: Extra not found: $id');
      return null;
    } catch (e, stackTrace) {
      _logger.e('ExtrasDatabase: Failed to load extra $id',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }
}
