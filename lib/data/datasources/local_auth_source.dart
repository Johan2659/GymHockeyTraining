import 'dart:async';
import 'dart:convert';
import '../../core/logging/logger_config.dart';
import '../../core/models/models.dart';
import '../../core/storage/hive_boxes.dart';
import '../../core/storage/local_kv_store.dart';
import '../../core/persistence/persistence_service.dart';

/// Local data source for authentication and user management
/// Handles multiple user profiles and current logged-in user
class LocalAuthSource {
  static final _logger = AppLogger.getLogger();
  static const String _currentUserIdKey = 'current_user_id';
  static const String _usersListKey = 'users_list';

  // Stream controller for watching auth changes
  static final _authStateController = StreamController<String?>.broadcast();

  /// Gets the currently logged-in user ID
  Future<String?> getCurrentUserId() async {
    try {
      final userId = await PersistenceService.readWithFallback(
          HiveBoxes.profile, _currentUserIdKey);
      _logger.d('LocalAuthSource: Current user ID: $userId');
      return userId;
    } catch (e, stackTrace) {
      _logger.e('Failed to get current user ID',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Sets the currently logged-in user
  Future<bool> setCurrentUserId(String userId) async {
    try {
      final success = await PersistenceService.writeWithFallback(
        HiveBoxes.profile,
        _currentUserIdKey,
        userId,
      );

      if (success) {
        _logger.i('LocalAuthSource: Set current user to: $userId');
        _notifyAuthChanged(userId);
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      _logger.e('Failed to set current user ID',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Clears the current user (logout)
  Future<bool> clearCurrentUserId() async {
    try {
      // Clear from both Hive and SharedPreferences fallback
      final success = await PersistenceService.clearWithFallback(
        HiveBoxes.profile,
        _currentUserIdKey,
      );
      
      if (success) {
        _logger.i('LocalAuthSource: Cleared current user (logged out) from all storage');
        _notifyAuthChanged(null);
      }
      return success;
    } catch (e, stackTrace) {
      _logger.e('Failed to clear current user',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Gets a specific user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final key = _userProfileKey(userId);
      final profileJson = await PersistenceService.readWithFallback(
          HiveBoxes.profile, key);
      
      if (profileJson == null) {
        _logger.d('LocalAuthSource: No profile found for user: $userId');
        return null;
      }

      final profileData = jsonDecode(profileJson) as Map<String, dynamic>;
      return UserProfile.fromJson(profileData);
    } catch (e, stackTrace) {
      _logger.e('Failed to get user profile',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Saves a user profile
  Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      final key = _userProfileKey(profile.id);
      final profileJson = jsonEncode(profile.toJson());

      final success = await PersistenceService.writeWithFallback(
        HiveBoxes.profile,
        key,
        profileJson,
      );

      if (success) {
        _logger.i('LocalAuthSource: Saved profile for user: ${profile.id}');
        // Add to users list
        await _addToUsersList(profile.id, profile.username);
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      _logger.e('Failed to save user profile',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Gets all registered usernames and IDs
  Future<Map<String, String>> getAllUsers() async {
    try {
      final usersJson = await PersistenceService.readWithFallback(
          HiveBoxes.profile, _usersListKey);
      
      if (usersJson == null) {
        return {};
      }

      final usersData = jsonDecode(usersJson) as Map<String, dynamic>;
      return usersData.map((key, value) => MapEntry(key, value.toString()));
    } catch (e, stackTrace) {
      _logger.e('Failed to get all users',
          error: e, stackTrace: stackTrace);
      return {};
    }
  }

  /// Checks if a username already exists
  Future<bool> usernameExists(String username) async {
    final users = await getAllUsers();
    return users.values.any((name) => 
        name.toLowerCase() == username.toLowerCase());
  }

  /// Gets user ID by username
  Future<String?> getUserIdByUsername(String username) async {
    final users = await getAllUsers();
    final entry = users.entries.firstWhere(
      (entry) => entry.value.toLowerCase() == username.toLowerCase(),
      orElse: () => const MapEntry('', ''),
    );
    return entry.key.isEmpty ? null : entry.key;
  }

  /// Watches for authentication state changes
  Stream<String?> watchAuthState() {
    // Emit current state immediately
    getCurrentUserId().then((userId) {
      if (!_authStateController.isClosed) {
        _authStateController.add(userId);
      }
    });

    return _authStateController.stream;
  }

  /// Deletes a user profile (for testing/admin)
  Future<bool> deleteUserProfile(String userId) async {
    try {
      final key = _userProfileKey(userId);
      final success = await LocalKVStore.delete(HiveBoxes.profile, key);
      
      if (success) {
        await _removeFromUsersList(userId);
        _logger.w('LocalAuthSource: Deleted user profile: $userId');
      }
      
      return success;
    } catch (e, stackTrace) {
      _logger.e('Failed to delete user profile',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Private helpers

  String _userProfileKey(String userId) => 'user_profile_$userId';

  Future<void> _addToUsersList(String userId, String username) async {
    try {
      final users = await getAllUsers();
      users[userId] = username;

      final usersJson = jsonEncode(users);
      await PersistenceService.writeWithFallback(
        HiveBoxes.profile,
        _usersListKey,
        usersJson,
      );
    } catch (e) {
      _logger.e('Failed to add user to list', error: e);
    }
  }

  Future<void> _removeFromUsersList(String userId) async {
    try {
      final users = await getAllUsers();
      users.remove(userId);

      final usersJson = jsonEncode(users);
      await PersistenceService.writeWithFallback(
        HiveBoxes.profile,
        _usersListKey,
        usersJson,
      );
    } catch (e) {
      _logger.e('Failed to remove user from list', error: e);
    }
  }

  void _notifyAuthChanged(String? userId) {
    if (!_authStateController.isClosed) {
      _authStateController.add(userId);
    }
  }
}
