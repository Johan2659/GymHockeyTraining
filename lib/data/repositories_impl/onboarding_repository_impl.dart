import 'dart:async';
import 'dart:convert';

import '../../core/logging/logger_config.dart';
import '../../core/models/models.dart';
import '../../core/repositories/onboarding_repository.dart';
import '../../core/storage/hive_boxes.dart';
import '../../core/storage/local_kv_store.dart';
import '../../core/persistence/persistence_service.dart';

/// Implementation of OnboardingRepository using local data source
class OnboardingRepositoryImpl implements OnboardingRepository {
  static final _logger = AppLogger.getLogger();
  static const String _userProfileKey = 'user_profile';

  // Stream controller for watching changes
  static final _profileController = StreamController<UserProfile?>.broadcast();

  @override
  Future<UserProfile?> getUserProfile() async {
    try {
      _logger.d('OnboardingRepository: Getting user profile');

      // Use PersistenceService for enhanced read with fallback
      final profileJson = await PersistenceService.readWithFallback(
          HiveBoxes.profile, _userProfileKey);
      
      if (profileJson == null) {
        _logger.d('OnboardingRepository: No user profile found');
        return null;
      }

      final profileData = jsonDecode(profileJson) as Map<String, dynamic>;
      final profile = UserProfile.fromJson(profileData);

      _logger.i('OnboardingRepository: Found user profile');
      return profile;
    } catch (e, stackTrace) {
      _logger.e('OnboardingRepository: Failed to get user profile',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      _logger.d('OnboardingRepository: Saving user profile');

      final profileJson = jsonEncode(profile.toJson());

      // Use PersistenceService for enhanced write with fallback
      final success = await PersistenceService.writeWithFallback(
        HiveBoxes.profile,
        _userProfileKey,
        profileJson,
      );

      if (success) {
        _logger.i('OnboardingRepository: Successfully saved user profile');
        _notifyProfileChanged();
        return true;
      } else {
        _logger.e('OnboardingRepository: Failed to save user profile');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e('OnboardingRepository: Error saving user profile',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    try {
      final profile = await getUserProfile();
      return profile?.onboardingCompleted ?? false;
    } catch (e, stackTrace) {
      _logger.e('OnboardingRepository: Error checking onboarding status',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Stream<UserProfile?> watchUserProfile() {
    // Emit current state immediately
    getUserProfile().then((profile) {
      if (!_profileController.isClosed) {
        _profileController.add(profile);
      }
    }).catchError((e) {
      _logger.e('OnboardingRepository: Error in initial profile stream emission',
          error: e);
    });

    return _profileController.stream;
  }

  @override
  Future<bool> clearUserProfile() async {
    try {
      _logger.w('OnboardingRepository: Clearing user profile');

      final success = await LocalKVStore.delete(HiveBoxes.profile, _userProfileKey);

      if (success) {
        _logger.w('OnboardingRepository: Successfully cleared user profile');
        _notifyProfileChanged();
      }

      return success;
    } catch (e, stackTrace) {
      _logger.e('OnboardingRepository: Failed to clear user profile',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Notifies listeners that the profile has changed
  void _notifyProfileChanged() {
    getUserProfile().then((profile) {
      if (!_profileController.isClosed) {
        _profileController.add(profile);
      }
    }).catchError((e) {
      _logger.e('OnboardingRepository: Error notifying profile change',
          error: e);
    });
  }
}
