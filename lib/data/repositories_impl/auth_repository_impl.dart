import 'dart:async';
import 'package:uuid/uuid.dart';

import '../../core/logging/logger_config.dart';
import '../../core/models/models.dart';
import '../../core/repositories/auth_repository.dart';
import '../datasources/local_auth_source.dart';

/// Implementation of AuthRepository using local data source
class AuthRepositoryImpl implements AuthRepository {
  final LocalAuthSource _authSource;
  static final _logger = AppLogger.getLogger();
  static const _uuid = Uuid();

  AuthRepositoryImpl({LocalAuthSource? authSource})
      : _authSource = authSource ?? LocalAuthSource();

  @override
  Future<UserProfile?> getCurrentUser() async {
    try {
      final userId = await _authSource.getCurrentUserId();
      if (userId == null) {
        return null;
      }
      
      return await _authSource.getUserProfile(userId);
    } catch (e, stackTrace) {
      _logger.e('AuthRepository: Failed to get current user',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Stream<UserProfile?> watchCurrentUser() {
    return _authSource.watchAuthState().asyncMap((userId) async {
      if (userId == null) {
        return null;
      }
      return await _authSource.getUserProfile(userId);
    });
  }

  @override
  Future<bool> isLoggedIn() async {
    final userId = await _authSource.getCurrentUserId();
    return userId != null;
  }

  @override
  Future<UserProfile?> login(String username) async {
    try {
      _logger.i('AuthRepository: Attempting login for: $username');

      // Check if user exists
      final userId = await _authSource.getUserIdByUsername(username);
      if (userId == null) {
        _logger.w('AuthRepository: User not found: $username');
        return null;
      }

      // Get user profile
      final profile = await _authSource.getUserProfile(userId);
      if (profile == null) {
        _logger.e('AuthRepository: Profile data missing for user: $userId');
        return null;
      }

      // Set as current user
      final success = await _authSource.setCurrentUserId(userId);
      if (!success) {
        _logger.e('AuthRepository: Failed to set current user');
        return null;
      }

      _logger.i('AuthRepository: Login successful for: $username');
      return profile;
    } catch (e, stackTrace) {
      _logger.e('AuthRepository: Login failed',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<UserProfile?> signUp(String username) async {
    try {
      _logger.i('AuthRepository: Attempting sign up for: $username');

      // Check if username already exists
      if (await _authSource.usernameExists(username)) {
        _logger.w('AuthRepository: Username already exists: $username');
        return null;
      }

      // Create new user profile with partial data
      // User will complete onboarding flow to set role and goal
      final userId = _uuid.v4();
      final profile = UserProfile(
        id: userId,
        username: username,
        role: PlayerRole.forward, // Default, will be updated in onboarding
        goal: TrainingGoal.strength, // Default, will be updated in onboarding
        onboardingCompleted: false,
        createdAt: DateTime.now(),
      );

      // Save profile
      final success = await _authSource.saveUserProfile(profile);
      if (!success) {
        _logger.e('AuthRepository: Failed to save new user profile');
        return null;
      }

      // Set as current user
      await _authSource.setCurrentUserId(userId);

      _logger.i('AuthRepository: Sign up successful for: $username');
      return profile;
    } catch (e, stackTrace) {
      _logger.e('AuthRepository: Sign up failed',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      _logger.i('AuthRepository: Logging out');
      return await _authSource.clearCurrentUserId();
    } catch (e, stackTrace) {
      _logger.e('AuthRepository: Logout failed',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<Map<String, String>> getAllUsers() async {
    return await _authSource.getAllUsers();
  }

  @override
  Future<bool> usernameExists(String username) async {
    return await _authSource.usernameExists(username);
  }

  @override
  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      _logger.i('AuthRepository: Updating profile for: ${profile.username}');
      return await _authSource.saveUserProfile(profile);
    } catch (e, stackTrace) {
      _logger.e('AuthRepository: Update profile failed',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> deleteUser(String userId) async {
    try {
      _logger.w('AuthRepository: Deleting user: $userId');
      return await _authSource.deleteUserProfile(userId);
    } catch (e, stackTrace) {
      _logger.e('AuthRepository: Delete user failed',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
