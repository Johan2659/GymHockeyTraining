import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di.dart';
import '../../../core/models/models.dart';
import '../../../core/services/logger_service.dart';

part 'auth_controller.g.dart';

/// Provider for the current authenticated user
@riverpod
Stream<UserProfile?> currentAuthUser(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.watchCurrentUser();
}

/// Provider to check if a user is logged in
@riverpod
Future<bool> isUserLoggedIn(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.isLoggedIn();
}

/// Provider for getting current user synchronously from async provider
@riverpod
Future<UserProfile?> currentUserProfile(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
}

/// Authentication state controller
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() async {
    // Initialize auth state
  }

  /// Login with existing username
  Future<UserProfile?> login(String username) async {
    final repository = ref.read(authRepositoryProvider);
    
    LoggerService.instance.info(
      'Attempting login for: $username',
      source: 'AuthController',
    );

    final profile = await repository.login(username);
    
    if (profile != null) {
      LoggerService.instance.info(
        'Login successful for: $username',
        source: 'AuthController',
      );
      // Invalidate related providers to refresh state
      ref.invalidate(currentAuthUserProvider);
      ref.invalidate(isUserLoggedInProvider);
      ref.invalidate(currentUserProfileProvider);
    } else {
      LoggerService.instance.warning(
        'Login failed for: $username',
        source: 'AuthController',
      );
    }
    
    return profile;
  }

  /// Sign up with new username
  Future<UserProfile?> signUp(String username) async {
    final repository = ref.read(authRepositoryProvider);
    
    LoggerService.instance.info(
      'Attempting sign up for: $username',
      source: 'AuthController',
    );

    final profile = await repository.signUp(username);
    
    if (profile != null) {
      LoggerService.instance.info(
        'Sign up successful for: $username',
        source: 'AuthController',
      );
      // Invalidate related providers to refresh state
      ref.invalidate(currentAuthUserProvider);
      ref.invalidate(isUserLoggedInProvider);
      ref.invalidate(currentUserProfileProvider);
    } else {
      LoggerService.instance.warning(
        'Sign up failed for: $username',
        source: 'AuthController',
      );
    }
    
    return profile;
  }

  /// Logout current user
  Future<bool> logout() async {
    final repository = ref.read(authRepositoryProvider);
    
    LoggerService.instance.info(
      'Logging out current user',
      source: 'AuthController',
    );

    final success = await repository.logout();
    
    if (success) {
      LoggerService.instance.info(
        'Logout successful',
        source: 'AuthController',
      );
      // Invalidate all providers to clear state
      ref.invalidate(currentAuthUserProvider);
      ref.invalidate(isUserLoggedInProvider);
      ref.invalidate(currentUserProfileProvider);
    }
    
    return success;
  }

  /// Check if username exists
  Future<bool> usernameExists(String username) async {
    final repository = ref.read(authRepositoryProvider);
    return await repository.usernameExists(username);
  }

  /// Update current user profile
  Future<bool> updateProfile(UserProfile profile) async {
    final repository = ref.read(authRepositoryProvider);
    
    LoggerService.instance.info(
      'Updating profile for: ${profile.username}',
      source: 'AuthController',
    );

    final success = await repository.updateUserProfile(profile);
    
    if (success) {
      // Invalidate providers to refresh
      ref.invalidate(currentAuthUserProvider);
      ref.invalidate(currentUserProfileProvider);
    }
    
    return success;
  }
}
