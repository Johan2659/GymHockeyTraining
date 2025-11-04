import 'dart:async';
import 'dart:convert';
import '../../core/logging/logger_config.dart';
import '../../core/models/models.dart';
import '../../core/storage/hive_boxes.dart';
import '../../core/storage/local_kv_store.dart';
import '../../core/persistence/persistence_service.dart';

/// Local data source for user preferences and profile data
/// Handles profile storage and program state management
class LocalPrefsSource {
  static final _logger = AppLogger.getLogger();
  static const String _profileKey = 'user_profile';
  static const String _programStateKeyPrefix = 'program_state_'; // Changed to prefix for per-user states

  // Stream controllers for watching changes
  static final _profileController = StreamController<Profile?>.broadcast();
  static final _programStateController =
      StreamController<ProgramState?>.broadcast();

  /// Gets the user profile with fallback support
  Future<Profile?> getProfile() async {
    try {
      // Use PersistenceService for enhanced read with fallback
      final profileJson = await PersistenceService.readWithFallback(
          HiveBoxes.profile, _profileKey);
      if (profileJson == null) {
        return null;
      }

      final profileData = jsonDecode(profileJson) as Map<String, dynamic>;
      return Profile.fromJson(profileData);
    } catch (e, stackTrace) {
      _logger.e('Failed to load profile',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Saves the user profile with enhanced persistence and fallback
  Future<bool> saveProfile(Profile profile) async {
    try {
      final profileJson = jsonEncode(profile.toJson());

      // Use PersistenceService for enhanced write with fallback
      final success = await PersistenceService.writeWithFallback(
        HiveBoxes.profile,
        _profileKey,
        profileJson,
      );

      if (success) {
        _logger.i('LocalPrefsSource: Successfully saved profile');
        _notifyProfileChanged();
        return true;
      } else {
        _logger.e('LocalPrefsSource: Failed to save profile');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e('LocalPrefsSource: Error saving profile',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Checks if a profile exists
  Future<bool> profileExists() async {
    try {
      return await LocalKVStore.exists(HiveBoxes.profile, _profileKey);
    } catch (e) {
      _logger.e('LocalPrefsSource: Error checking profile existence', error: e);
      return false;
    }
  }

  /// Clears the user profile
  Future<bool> clearProfile() async {
    try {
      _logger.w('LocalPrefsSource: Clearing user profile');

      final success = await LocalKVStore.delete(HiveBoxes.profile, _profileKey);

      if (success) {
        _logger.w('LocalPrefsSource: Successfully cleared profile');
        _notifyProfileChanged();
      }

      return success;
    } catch (e, stackTrace) {
      _logger.e('LocalPrefsSource: Failed to clear profile',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Provides a stream of profile changes
  Stream<Profile?> watchProfile() {
    // Emit current state immediately
    getProfile().then((profile) {
      if (!_profileController.isClosed) {
        _profileController.add(profile);
      }
    }).catchError((e) {
      _logger.e('LocalPrefsSource: Error in initial profile stream emission',
          error: e);
    });

    return _profileController.stream;
  }

  /// Gets the program state with fallback support (user-specific)
  Future<ProgramState?> getProgramState(String userId) async {
    try {
      _logger.d('LocalPrefsSource: Loading program state for user $userId');

      final key = _programStateKey(userId);
      // Use PersistenceService for enhanced read with fallback
      final stateJson = await PersistenceService.readWithFallback(
          HiveBoxes.settings, key);
      if (stateJson == null) {
        _logger.d('LocalPrefsSource: No program state found for user $userId');
        return null;
      }

      final stateData = jsonDecode(stateJson) as Map<String, dynamic>;
      final state = ProgramState.fromJson(stateData);

      _logger.d('LocalPrefsSource: Successfully loaded program state for user $userId');
      return state;
    } catch (e, stackTrace) {
      _logger.e('LocalPrefsSource: Failed to load program state',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Saves the program state with enhanced persistence and fallback (user-specific)
  Future<bool> saveProgramState(ProgramState state) async {
    try {
      _logger.d('LocalPrefsSource: Saving program state for user ${state.userId}');
      PersistenceService.logStateChange(
          'Program state updated - User: ${state.userId}, Week: ${state.currentWeek}, Session: ${state.currentSession}');

      final stateJson = jsonEncode(state.toJson());
      final key = _programStateKey(state.userId);

      // Use PersistenceService for enhanced write with fallback
      final success = await PersistenceService.writeWithFallback(
        HiveBoxes.settings,
        key,
        stateJson,
      );

      if (success) {
        _logger.i('LocalPrefsSource: Successfully saved program state for user ${state.userId}');
        _notifyProgramStateChanged();
        return true;
      } else {
        _logger.e('LocalPrefsSource: Failed to save program state');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e('LocalPrefsSource: Error saving program state',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Clears the program state for a specific user
  Future<bool> clearProgramState(String userId) async {
    try {
      _logger.w('LocalPrefsSource: Clearing program state for user $userId');

      final key = _programStateKey(userId);
      // Use PersistenceService to clear from both Hive and SharedPreferences
      final success = await PersistenceService.clearWithFallback(
          HiveBoxes.settings, key);

      if (success) {
        _logger.w('LocalPrefsSource: Successfully cleared program state for user $userId');
        _notifyProgramStateChanged();
      }

      return success;
    } catch (e, stackTrace) {
      _logger.e('LocalPrefsSource: Failed to clear program state',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Provides a stream of program state changes for a specific user
  Stream<ProgramState?> watchProgramState(String userId) {
    // Emit current state immediately
    getProgramState(userId).then((state) {
      if (!_programStateController.isClosed) {
        _programStateController.add(state);
      }
    }).catchError((e) {
      _logger.e(
          'LocalPrefsSource: Error in initial program state stream emission',
          error: e);
    });

    return _programStateController.stream;
  }

  /// Notifies stream listeners of profile changes
  void _notifyProfileChanged() async {
    try {
      final profile = await getProfile();
      if (!_profileController.isClosed) {
        _profileController.add(profile);
      }
    } catch (e) {
      _logger.e('LocalPrefsSource: Error notifying profile changes', error: e);
    }
  }

  /// Notifies stream listeners of program state changes
  /// Note: This emits null since we don't know which user's state changed
  /// Consumers should re-query with their userId
  void _notifyProgramStateChanged() {
    if (!_programStateController.isClosed) {
      _programStateController.add(null); // Signal change, consumers re-query
    }
  }

  /// Disposes the stream controllers (call on app shutdown)
  static void dispose() {
    if (!_profileController.isClosed) {
      _profileController.close();
    }
    if (!_programStateController.isClosed) {
      _programStateController.close();
    }
  }

  // Helper method to generate user-specific key
  String _programStateKey(String userId) => '${_programStateKeyPrefix}$userId';
}
