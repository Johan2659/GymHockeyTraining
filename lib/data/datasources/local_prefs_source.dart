import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/models.dart';
import '../../core/storage/hive_boxes.dart';
import '../../core/storage/local_kv_store.dart';
import '../../core/persistence/persistence_service.dart';

/// Local data source for user preferences and profile data
/// Handles profile storage and program state management
class LocalPrefsSource {
  static final _logger = Logger();
  static const String _profileKey = 'user_profile';
  static const String _programStateKey = 'program_state';

  // Stream controllers for watching changes
  static final _profileController = StreamController<Profile?>.broadcast();
  static final _programStateController =
      StreamController<ProgramState?>.broadcast();

  /// Gets the user profile with fallback support
  Future<Profile?> getProfile() async {
    try {
      _logger.d('LocalPrefsSource: Loading user profile');

      // Use PersistenceService for enhanced read with fallback
      final profileJson = await PersistenceService.readWithFallback(
          HiveBoxes.profile, _profileKey);
      if (profileJson == null) {
        _logger.d('LocalPrefsSource: No profile found');
        return null;
      }

      final profileData = jsonDecode(profileJson) as Map<String, dynamic>;
      final profile = Profile.fromJson(profileData);

      _logger.d('LocalPrefsSource: Successfully loaded profile');
      return profile;
    } catch (e, stackTrace) {
      _logger.e('LocalPrefsSource: Failed to load profile',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Saves the user profile with enhanced persistence and fallback
  Future<bool> saveProfile(Profile profile) async {
    try {
      _logger.d('LocalPrefsSource: Saving user profile');
      PersistenceService.logStateChange('User profile updated');

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

  /// Gets the program state with fallback support
  Future<ProgramState?> getProgramState() async {
    try {
      _logger.d('LocalPrefsSource: Loading program state');

      // Use PersistenceService for enhanced read with fallback
      final stateJson = await PersistenceService.readWithFallback(
          HiveBoxes.settings, _programStateKey);
      if (stateJson == null) {
        _logger.d('LocalPrefsSource: No program state found');
        return null;
      }

      final stateData = jsonDecode(stateJson) as Map<String, dynamic>;
      final state = ProgramState.fromJson(stateData);

      _logger.d('LocalPrefsSource: Successfully loaded program state');
      return state;
    } catch (e, stackTrace) {
      _logger.e('LocalPrefsSource: Failed to load program state',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Saves the program state with enhanced persistence and fallback
  Future<bool> saveProgramState(ProgramState state) async {
    try {
      _logger.d('LocalPrefsSource: Saving program state');
      PersistenceService.logStateChange(
          'Program state updated - Week: ${state.currentWeek}, Session: ${state.currentSession}');

      final stateJson = jsonEncode(state.toJson());

      // Use PersistenceService for enhanced write with fallback
      final success = await PersistenceService.writeWithFallback(
        HiveBoxes.settings,
        _programStateKey,
        stateJson,
      );

      if (success) {
        _logger.i('LocalPrefsSource: Successfully saved program state');
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

  /// Clears the program state
  Future<bool> clearProgramState() async {
    try {
      _logger.w('LocalPrefsSource: Clearing program state');

      // Use PersistenceService to clear from both Hive and SharedPreferences
      final success = await PersistenceService.clearWithFallback(
          HiveBoxes.settings, _programStateKey);

      if (success) {
        _logger.w('LocalPrefsSource: Successfully cleared program state');
        _notifyProgramStateChanged();
      }

      return success;
    } catch (e, stackTrace) {
      _logger.e('LocalPrefsSource: Failed to clear program state',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Provides a stream of program state changes
  Stream<ProgramState?> watchProgramState() {
    // Emit current state immediately
    getProgramState().then((state) {
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
  void _notifyProgramStateChanged() async {
    try {
      final state = await getProgramState();
      if (!_programStateController.isClosed) {
        _programStateController.add(state);
      }
    } catch (e) {
      _logger.e('LocalPrefsSource: Error notifying program state changes',
          error: e);
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
}
